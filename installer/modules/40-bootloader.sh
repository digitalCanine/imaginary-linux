#!/bin/bash
# Module 40: Bootloader Installation (systemd-boot)
# Guarantees valid kernel, initramfs, and root parameters

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[✓]${NC} $1"; }
print_error() { echo -e "${RED}[✗]${NC} $1"; }

BOOT_DIR="/mnt/boot"
LOADER_DIR="$BOOT_DIR/loader"
ENTRY_DIR="$LOADER_DIR/entries"

main() {
  print_info "Installing systemd-boot..."

  # Ensure ESP is mounted
  if ! mountpoint -q "$BOOT_DIR"; then
    print_error "/boot is not mounted — EFI system partition missing"
    return 1
  fi

  arch-chroot /mnt bootctl install || {
    print_error "Failed to install systemd-boot"
    return 1
  }

  mkdir -p "$ENTRY_DIR"

  # Detect kernel
  if [ -f "$BOOT_DIR/vmlinuz-linux" ]; then
    KERNEL_IMAGE="/vmlinuz-linux"
    INITRAMFS="/initramfs-linux.img"
    FALLBACK="/initramfs-linux-fallback.img"
    ENTRY_NAME="linux"
  elif [ -f "$BOOT_DIR/vmlinuz-linux-lts" ]; then
    KERNEL_IMAGE="/vmlinuz-linux-lts"
    INITRAMFS="/initramfs-linux-lts.img"
    FALLBACK="/initramfs-linux-lts-fallback.img"
    ENTRY_NAME="linux-lts"
  elif [ -f "$BOOT_DIR/vmlinuz-linux-zen" ]; then
    KERNEL_IMAGE="/vmlinuz-linux-zen"
    INITRAMFS="/initramfs-linux-zen.img"
    FALLBACK="/initramfs-linux-zen-fallback.img"
    ENTRY_NAME="linux-zen"
  else
    print_error "No kernel image found in /boot"
    return 1
  fi

  # Validate initramfs
  if [ ! -f "$BOOT_DIR$INITRAMFS" ]; then
    print_error "Initramfs missing: $INITRAMFS"
    return 1
  fi

  # Detect root UUID
  ROOT_UUID=$(blkid -s UUID -o value "$(findmnt -n -o SOURCE /mnt)") || {
    print_error "Failed to detect root UUID"
    return 1
  }

  KERNEL_OPTS="root=UUID=$ROOT_UUID rw quiet"

  # Encrypted root support
  if [ "$ENCRYPTED_ROOT" = "true" ] && [ -n "$CRYPT_UUID" ]; then
    KERNEL_OPTS="cryptdevice=UUID=$CRYPT_UUID:cryptroot root=/dev/mapper/cryptroot rw quiet"
  fi

  print_info "Writing boot entry..."

  cat >"$ENTRY_DIR/$ENTRY_NAME.conf" <<EOF
title   Linux Imaginary
linux   $KERNEL_IMAGE
initrd  $INITRAMFS
options $KERNEL_OPTS
EOF

  # Optional fallback entry
  if [ -f "$BOOT_DIR$FALLBACK" ]; then
    cat >"$ENTRY_DIR/${ENTRY_NAME}-fallback.conf" <<EOF
title   Linux Imaginary (Fallback)
linux   $KERNEL_IMAGE
initrd  $FALLBACK
options $KERNEL_OPTS
EOF
  fi

  # Loader config
  cat >"$LOADER_DIR/loader.conf" <<EOF
default $ENTRY_NAME
timeout 3
editor  no
EOF

  print_success "systemd-boot installed successfully"
  print_success "Boot entry created for $ENTRY_NAME"
}

if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
  main "$@"
fi
