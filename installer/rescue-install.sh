#!/bin/bash
# Quick diagnostics for failed Imaginary Linux installation
# Run this from the Arch ISO after installation fails

echo "=== Imaginary Linux Installation Diagnostics ==="
echo ""

# Show all block devices
echo "[1] Block Devices:"
lsblk -f
echo ""

# Ask for root partition
read -p "Enter your root partition (e.g., /dev/sda2): " ROOT_PART

if [ ! -b "$ROOT_PART" ]; then
  echo "ERROR: $ROOT_PART does not exist!"
  exit 1
fi

# Mount root
echo ""
echo "[2] Mounting $ROOT_PART..."
mount "$ROOT_PART" /mnt || {
  echo "Failed to mount!"
  exit 1
}
echo "✓ Mounted"

# Check for boot partition
if [ -d /sys/firmware/efi ]; then
  echo ""
  read -p "Enter boot/EFI partition (or press Enter if none): " BOOT_PART
  if [ -n "$BOOT_PART" ] && [ -b "$BOOT_PART" ]; then
    mkdir -p /mnt/boot
    mount "$BOOT_PART" /mnt/boot
    echo "✓ Boot partition mounted"
  fi
fi

echo ""
echo "=== DIAGNOSIS RESULTS ==="
echo ""

# Check 1: fstab
echo "[1] FSTAB CHECK:"
if [ -f /mnt/etc/fstab ]; then
  echo "✓ fstab exists"
  echo "--- Content: ---"
  cat /mnt/etc/fstab
  echo "---------------"

  # Verify UUIDs match actual disks
  echo ""
  echo "Verifying UUIDs..."
  ROOT_UUID_FSTAB=$(grep -E '^\s*UUID=' /mnt/etc/fstab | grep -v swap | grep -v boot | head -1 | awk '{print $1}' | cut -d= -f2)
  ROOT_UUID_ACTUAL=$(blkid -s UUID -o value "$ROOT_PART")

  echo "fstab root UUID:  $ROOT_UUID_FSTAB"
  echo "Actual root UUID: $ROOT_UUID_ACTUAL"

  if [ "$ROOT_UUID_FSTAB" = "$ROOT_UUID_ACTUAL" ]; then
    echo "✓ Root UUID matches"
  else
    echo "✗ UUID MISMATCH! This will cause boot failure!"
  fi
else
  echo "✗ fstab MISSING!"
fi

echo ""
echo "[2] BOOTLOADER CHECK:"

if [ -d /sys/firmware/efi ]; then
  echo "System: UEFI"

  # Check systemd-boot
  if [ -d /mnt/boot/loader ]; then
    echo "✓ systemd-boot directory exists"

    if [ -f /mnt/boot/loader/loader.conf ]; then
      echo "✓ loader.conf exists:"
      cat /mnt/boot/loader/loader.conf
    else
      echo "✗ loader.conf MISSING!"
    fi

    echo ""
    echo "Boot entries:"
    if ls /mnt/boot/loader/entries/*.conf &>/dev/null; then
      for entry in /mnt/boot/loader/entries/*.conf; do
        echo "--- $(basename $entry) ---"
        cat "$entry"
        echo ""

        # Extract and verify root UUID from entry
        ENTRY_UUID=$(grep "^options" "$entry" | grep -oP 'UUID=\K[^ ]+' || grep "^options" "$entry" | grep -oP 'PARTUUID=\K[^ ]+')
        if [ -n "$ENTRY_UUID" ]; then
          echo "Entry UUID: $ENTRY_UUID"
          ACTUAL_UUID=$(blkid -s UUID -o value "$ROOT_PART" || blkid -s PARTUUID -o value "$ROOT_PART")
          echo "Actual UUID: $ACTUAL_UUID"

          if echo "$ENTRY_UUID" | grep -q "$ACTUAL_UUID"; then
            echo "✓ UUID matches"
          else
            echo "✗ UUID MISMATCH in boot entry!"
          fi
        fi
      done
    else
      echo "✗ NO BOOT ENTRIES FOUND!"
    fi
  fi

  # Check GRUB
  if [ -d /mnt/boot/EFI ] || [ -d /mnt/boot/grub ]; then
    echo "✓ GRUB directory exists"

    if [ -f /mnt/boot/grub/grub.cfg ]; then
      echo "✓ grub.cfg exists"
      echo "Checking menuentry..."
      grep -A5 "menuentry" /mnt/boot/grub/grub.cfg | head -20
    else
      echo "✗ grub.cfg MISSING!"
    fi
  fi
else
  echo "System: BIOS"

  if [ -d /mnt/boot/grub ]; then
    echo "✓ GRUB directory exists"

    if [ -f /mnt/boot/grub/grub.cfg ]; then
      echo "✓ grub.cfg exists"
    else
      echo "✗ grub.cfg MISSING!"
    fi
  else
    echo "✗ GRUB not installed!"
  fi
fi

echo ""
echo "[3] KERNEL CHECK:"
if ls /mnt/boot/vmlinuz-* &>/dev/null; then
  echo "✓ Kernel found:"
  ls -lh /mnt/boot/vmlinuz-*
else
  echo "✗ NO KERNEL FOUND!"
fi

echo ""
echo "[4] INITRAMFS CHECK:"
if ls /mnt/boot/initramfs-* &>/dev/null; then
  echo "✓ Initramfs found:"
  ls -lh /mnt/boot/initramfs-*

  # Check if it's not empty
  for initramfs in /mnt/boot/initramfs-*.img; do
    SIZE=$(stat -c%s "$initramfs")
    if [ "$SIZE" -lt 1000000 ]; then
      echo "✗ WARNING: $initramfs is suspiciously small ($SIZE bytes)"
    fi
  done
else
  echo "✗ NO INITRAMFS FOUND!"
fi

echo ""
echo "[5] ROOT FILESYSTEM CHECK:"
echo "Filesystem type: $(df -T /mnt | tail -1 | awk '{print $2}')"
echo "Mount status:"
mount | grep /mnt

echo ""
echo "[6] USER CHECK:"
arch-chroot /mnt bash -c '
if [ -f /etc/passwd ]; then
    echo "Users with home directories:"
    grep "/home" /etc/passwd | cut -d: -f1
else
    echo "✗ /etc/passwd missing!"
fi
'

echo ""
echo "[7] ROOT PASSWORD CHECK:"
arch-chroot /mnt bash -c '
STATUS=$(passwd --status root 2>/dev/null | awk "{print \$2}")
echo "Root password status: $STATUS"
if [ "$STATUS" = "L" ]; then
    echo "✗ ROOT ACCOUNT IS LOCKED!"
elif [ "$STATUS" = "NP" ]; then
    echo "✗ ROOT HAS NO PASSWORD!"
elif [ "$STATUS" = "P" ]; then
    echo "✓ Root password is set"
else
    echo "? Unknown status: $STATUS"
fi
'

echo ""
echo "=== DIAGNOSIS COMPLETE ==="
echo ""
echo "QUICK FIXES:"
echo ""
echo "To regenerate fstab:"
echo "  genfstab -U /mnt > /mnt/etc/fstab"
echo ""
echo "To regenerate initramfs:"
echo "  arch-chroot /mnt mkinitcpio -P"
echo ""
echo "To fix root password:"
echo "  arch-chroot /mnt passwd -u root"
echo "  arch-chroot /mnt passwd root"
echo ""
echo "To reinstall bootloader:"
echo "  # For systemd-boot:"
echo "  arch-chroot /mnt bootctl install"
echo "  # For GRUB UEFI:"
echo "  arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB"
echo "  # For GRUB BIOS:"
echo "  arch-chroot /mnt grub-install --target=i386-pc /dev/sdX"
echo ""

# Keep mounted for fixes
echo "Partitions are still mounted at /mnt"
echo "Run 'umount -R /mnt' when done"
