#!/bin/bash
# Imaginary Linux - Installation Rescue Script
# Use this to fix a failed installation by booting back into the Arch ISO

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
  echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
  echo -e "${RED}[✗]${NC} $1"
}

echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════╗"
echo "║   Imaginary Linux Rescue Tool            ║"
echo "╚═══════════════════════════════════════════╝"
echo -e "${NC}"

# Detect and mount partitions
print_info "Detecting partitions..."
lsblk

echo ""
read -p "Enter root partition (e.g., /dev/sda2): " ROOT_PART

if [ ! -b "$ROOT_PART" ]; then
  print_error "Invalid partition: $ROOT_PART"
  exit 1
fi

print_info "Mounting $ROOT_PART to /mnt..."
mount "$ROOT_PART" /mnt

# Check if boot partition exists
echo ""
read -p "Do you have a separate boot partition? (y/N): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
  read -p "Enter boot partition (e.g., /dev/sda1): " BOOT_PART

  if [ -d /sys/firmware/efi ]; then
    print_info "UEFI detected, mounting to /mnt/boot"
    mkdir -p /mnt/boot
    mount "$BOOT_PART" /mnt/boot
  else
    print_info "BIOS detected, mounting to /mnt/boot"
    mkdir -p /mnt/boot
    mount "$BOOT_PART" /mnt/boot
  fi
fi

print_success "Partitions mounted"

# Chroot into system
print_info "Entering chroot environment..."
arch-chroot /mnt /bin/bash <<'CHROOT_EOF'

echo "============================================"
echo "You are now in the installed system"
echo "============================================"
echo ""

# Fix 1: Unlock root account
echo "[1] Checking root account status..."
passwd_status=$(passwd --status root | awk '{print $2}')

if [ "$passwd_status" != "P" ]; then
    echo "Root account is locked or has no password!"
    echo "Unlocking root account..."
    passwd -u root

    echo "Setting root password..."
    passwd root
else
    echo "✓ Root account is OK (status: $passwd_status)"
fi

# Fix 2: Check user account
echo ""
echo "[2] Checking user accounts..."
cat /etc/passwd | grep -v "^root" | grep "/home" | cut -d: -f1

read -p "Enter your username: " USERNAME

if id "$USERNAME" &>/dev/null; then
    echo "✓ User $USERNAME exists"
    
    # Reset user password
    read -p "Reset password for $USERNAME? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        passwd "$USERNAME"
    fi
else
    echo "✗ User $USERNAME not found!"
    read -p "Create user $USERNAME? (Y/n): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        useradd -m -G wheel,audio,video,optical,storage -s /bin/bash "$USERNAME"
        passwd "$USERNAME"
        echo "✓ User $USERNAME created"
    fi
fi

# Fix 3: Check fstab
echo ""
echo "[3] Checking fstab..."
if [ -f /etc/fstab ] && [ -s /etc/fstab ]; then
    echo "✓ fstab exists:"
    cat /etc/fstab
else
    echo "✗ fstab is missing or empty!"
    echo "You need to regenerate it from the ISO:"
    echo "  exit"
    echo "  genfstab -U /mnt >> /mnt/etc/fstab"
fi

# Fix 4: Check bootloader
echo ""
echo "[4] Checking bootloader..."

if [ -d /sys/firmware/efi ]; then
    echo "UEFI System:"
    
    if [ -d /boot/loader ]; then
        echo "✓ systemd-boot detected"
        echo "Entries:"
        ls -la /boot/loader/entries/
        
        read -p "Reinstall systemd-boot? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            bootctl install
        fi
    elif [ -d /boot/EFI ]; then
        echo "✓ GRUB detected"
        
        read -p "Reinstall GRUB? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
            grub-mkconfig -o /boot/grub/grub.cfg
        fi
    else
        echo "✗ No bootloader found!"
        read -p "Install systemd-boot? (Y/n): " -n 1 -r
        echo
        
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            bootctl install
            # Create entry
            mkdir -p /boot/loader/entries
            PARTUUID=$(blkid -s PARTUUID -o value $(findmnt -n -o SOURCE /))
            cat > /boot/loader/entries/imaginary.conf <<EOF
title   Imaginary Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=PARTUUID=$PARTUUID rw
EOF
            echo "✓ systemd-boot installed"
        fi
    fi
else
    echo "BIOS System:"
    
    if [ -d /boot/grub ]; then
        echo "✓ GRUB detected"
        
        read -p "Reinstall GRUB? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            # Detect disk
            DISK=$(lsblk -ndo PKNAME $(findmnt -n -o SOURCE /))
            grub-install --target=i386-pc /dev/$DISK
            grub-mkconfig -o /boot/grub/grub.cfg
        fi
    else
        echo "✗ GRUB not found!"
        echo "Install GRUB from outside chroot with:"
        echo "  arch-chroot /mnt grub-install --target=i386-pc /dev/sdX"
    fi
fi

# Fix 5: Check kernel and initramfs
echo ""
echo "[5] Checking kernel and initramfs..."
if ls /boot/vmlinuz-* &>/dev/null; then
    echo "✓ Kernel found:"
    ls -lh /boot/vmlinuz-*
else
    echo "✗ No kernel found!"
    echo "Install kernel:"
    echo "  pacman -S linux"
fi

if ls /boot/initramfs-* &>/dev/null; then
    echo "✓ Initramfs found:"
    ls -lh /boot/initramfs-*
else
    echo "✗ No initramfs found!"
fi

read -p "Regenerate initramfs? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    mkinitcpio -P
    echo "✓ Initramfs regenerated"
fi

# Fix 6: Check hostname
echo ""
echo "[6] Checking hostname..."
if [ -f /etc/hostname ]; then
    echo "✓ Hostname: $(cat /etc/hostname)"
else
    echo "✗ No hostname set"
    read -p "Enter hostname: " HOSTNAME
    echo "$HOSTNAME" > /etc/hostname
fi

# Fix 7: Check locale
echo ""
echo "[7] Checking locale..."
if [ -f /etc/locale.conf ]; then
    echo "✓ Locale: $(cat /etc/locale.conf)"
else
    echo "✗ Locale not configured"
    echo "LANG=en_US.UTF-8" > /etc/locale.conf
    sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
    locale-gen
fi

echo ""
echo "============================================"
echo "Rescue complete! Exit and reboot."
echo "============================================"

CHROOT_EOF

# Unmount
print_info "Unmounting partitions..."
umount -R /mnt

print_success "Rescue complete!"
print_info "You can now reboot: reboot"
