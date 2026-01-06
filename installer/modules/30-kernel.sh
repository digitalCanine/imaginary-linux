#!/bin/bash
# Module 30: Kernel Selection and Installation
# Allows user to choose and install their preferred kernel

# Colors
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

print_warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
  echo -e "${RED}[✗]${NC} $1"
}

list_kernels() {
  echo ""
  echo -e "${BLUE}╔═══════════════════════════════════════════╗${NC}"
  echo -e "${BLUE}║         Kernel Selection                  ║${NC}"
  echo -e "${BLUE}╚═══════════════════════════════════════════╝${NC}"
  echo ""
  echo "1) linux          - Default Arch kernel (recommended)"
  echo "                    Balanced, well-tested, frequent updates"
  echo ""
  echo "2) linux-lts      - Long Term Support kernel"
  echo "                    Maximum stability, slower updates"
  echo ""
  echo "3) linux-zen      - Performance-optimized kernel"
  echo "                    Better for desktop/gaming, higher throughput"
  echo ""
  echo "4) linux-hardened - Security-hardened kernel"
  echo "                    Enhanced security, may break some software"
  echo ""
}

select_kernel() {
  list_kernels

  while true; do
    read -p "Select kernel [1-4]: " choice

    case $choice in
    1)
      SELECTED_KERNEL="linux"
      KERNEL_NAME="Default (linux)"
      break
      ;;
    2)
      SELECTED_KERNEL="linux-lts"
      KERNEL_NAME="Long Term Support (linux-lts)"
      break
      ;;
    3)
      SELECTED_KERNEL="linux-zen"
      KERNEL_NAME="Performance (linux-zen)"
      break
      ;;
    4)
      SELECTED_KERNEL="linux-hardened"
      KERNEL_NAME="Hardened (linux-hardened)"
      print_warning "Hardened kernel may have compatibility issues"
      print_warning "Some software may not work correctly"
      echo ""
      read -p "Continue with hardened kernel? (y/N): " -n 1 -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        break
      else
        print_info "Selecting different kernel..."
        continue
      fi
      ;;
    *)
      print_error "Invalid selection"
      continue
      ;;
    esac
  done

  print_success "Selected: $KERNEL_NAME"
  export SELECTED_KERNEL
  export KERNEL_NAME
}

install_kernel() {
  print_info "Installing kernel: $KERNEL_NAME"

  # Install kernel and headers
  arch-chroot /mnt pacman -S --noconfirm --needed "$SELECTED_KERNEL" "${SELECTED_KERNEL}-headers"

  if [ $? -eq 0 ]; then
    print_success "Kernel installed successfully"
  else
    print_error "Failed to install kernel"
    return 1
  fi

  return 0
}

configure_mkinitcpio() {
  print_info "Configuring initramfs..."

  # Ensure /etc/vconsole.conf exists with default keymap
  if [ ! -f /mnt/etc/vconsole.conf ]; then
    echo "KEYMAP=us" >/mnt/etc/vconsole.conf
  fi

  # Check if btrfs was used
  if mount | grep -q btrfs; then
    print_info "Adding btrfs support to initramfs..."
    arch-chroot /mnt sed -i 's/^MODULES=.*/MODULES=(btrfs)/' /etc/mkinitcpio.conf
  fi

  # Generate initramfs
  print_info "Generating initramfs (this may take a minute)..."
  arch-chroot /mnt mkinitcpio -P

  if [ $? -eq 0 ]; then
    print_success "Initramfs generated successfully"
  else
    print_error "Failed to generate initramfs"
    return 1
  fi

  return 0
}

apply_kernel_parameters() {
  print_info "Configuring kernel parameters..."

  # Base parameters
  local kernel_params="quiet splash"

  # Add encryption parameters if needed
  if [ "$ENCRYPTED_ROOT" = "true" ] && [ -n "$ROOT_UUID" ]; then
    kernel_params="$kernel_params cryptdevice=UUID=$ROOT_UUID:cryptroot root=/dev/mapper/cryptroot"
  fi

  # Save for bootloader module
  export KERNEL_PARAMS="$kernel_params"

  print_success "Kernel parameters configured"
}

display_summary() {
  echo ""
  echo -e "${BLUE}═══════════════════════════════════════${NC}"
  echo -e "${BLUE}    Kernel Installation Summary${NC}"
  echo -e "${BLUE}═══════════════════════════════════════${NC}"
  echo -e "Kernel:       ${GREEN}$KERNEL_NAME${NC}"
  echo -e "Headers:      ${GREEN}Installed${NC}"
  echo -e "Initramfs:    ${GREEN}Generated${NC}"
  echo -e "${BLUE}═══════════════════════════════════════${NC}"
  echo ""
}

main() {
  echo -e "${BLUE}"
  echo "╔═══════════════════════════════════════════╗"
  echo "║       Kernel Installation                 ║"
  echo "╚═══════════════════════════════════════════╝"
  echo -e "${NC}"

  # Select kernel
  select_kernel

  # Confirm selection
  echo ""
  read -p "Install $KERNEL_NAME? (Y/n): " -n 1 -r
  echo

  if [[ $REPLY =~ ^[Nn]$ ]]; then
    print_info "Kernel installation cancelled"
    return 1
  fi

  # Install kernel
  install_kernel || return 1

  # Configure initramfs
  configure_mkinitcpio || return 1

  # Apply kernel parameters
  apply_kernel_parameters

  # Display summary
  display_summary

  print_success "Kernel installation complete!"

  return 0
}

# Run if executed directly
if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
  main "$@"
fi
