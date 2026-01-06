#!/bin/bash
# Module 30: Kernel Selection and Installation
# Installs kernel and generates a valid initramfs

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[✓]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[✗]${NC} $1"; }

select_kernel() {
  echo ""
  echo "1) linux"
  echo "2) linux-lts"
  echo "3) linux-zen"
  echo "4) linux-hardened"
  echo ""

  while true; do
    read -p "Select kernel [1-4]: " choice
    case $choice in
    1)
      SELECTED_KERNEL="linux"
      break
      ;;
    2)
      SELECTED_KERNEL="linux-lts"
      break
      ;;
    3)
      SELECTED_KERNEL="linux-zen"
      break
      ;;
    4)
      SELECTED_KERNEL="linux-hardened"
      break
      ;;
    *) print_error "Invalid selection" ;;
    esac
  done

  export SELECTED_KERNEL
  print_success "Selected kernel: $SELECTED_KERNEL"
}

install_kernel() {
  print_info "Installing kernel and headers..."
  arch-chroot /mnt pacman -S --noconfirm --needed \
    "$SELECTED_KERNEL" "$SELECTED_KERNEL-headers" || return 1
}

configure_mkinitcpio() {
  print_info "Configuring mkinitcpio..."

  local mk="/mnt/etc/mkinitcpio.conf"

  # Detect filesystem used for /
  ROOT_FS=$(findmnt -n -o FSTYPE /mnt)

  # Base hooks
  HOOKS="base udev autodetect modconf block filesystems keyboard fsck"

  # Encryption support
  if [ "$ENCRYPTED_ROOT" = "true" ]; then
    HOOKS="base udev autodetect keyboard keymap consolefont modconf block encrypt filesystems fsck"
  fi

  # btrfs support (NO MODULE overwrite)
  if [ "$ROOT_FS" = "btrfs" ]; then
    print_info "Detected btrfs root"
    sed -i 's/^#MODULES=.*/MODULES=(btrfs)/' "$mk"
  fi

  # Apply hooks safely
  sed -i "s/^HOOKS=.*/HOOKS=($HOOKS)/" "$mk"

  print_success "mkinitcpio configured"
}

generate_initramfs() {
  print_info "Generating initramfs..."
  arch-chroot /mnt mkinitcpio -P || return 1
}

main() {
  echo -e "${BLUE}"
  echo "╔═══════════════════════════════════════════╗"
  echo "║        Kernel & Initramfs Creation        ║"
  echo "╚═══════════════════════════════════════════╝"
  echo -e "${NC}"

  select_kernel
  install_kernel || return 1
  configure_mkinitcpio || return 1
  generate_initramfs || return 1

  # Export kernel identity for bootloader
  export INSTALLED_KERNEL="$SELECTED_KERNEL"

  print_success "Kernel installation complete"
}

if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
  main "$@"
fi
