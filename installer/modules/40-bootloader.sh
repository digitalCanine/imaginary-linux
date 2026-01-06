#!/bin/bash
# Module 40: Bootloader Installation
# Installs and configures bootloader (GRUB, systemd-boot, or libreboot)

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

list_bootloaders() {
  echo ""
  echo -e "${BLUE}╔═══════════════════════════════════════════╗${NC}"
  echo -e "${BLUE}║         Bootloader Selection              ║${NC}"
  echo -e "${BLUE}╚═══════════════════════════════════════════╝${NC}"
  echo ""

  if [ "$BOOT_MODE" = "UEFI" ]; then
    echo "UEFI mode detected - Available bootloaders:"
    echo ""
    echo "1) systemd-boot   - Simple, fast (recommended for UEFI)"
    echo "                    Minimal, integrated with systemd"
    echo ""
    echo "2) GRUB           - Traditional, feature-rich"
    echo "                    Better for dual-boot, theme support"
    echo ""
    echo "3) libreboot      - Free BIOS replacement (advanced)"
    echo "                    Requires compatible hardware"
    echo ""
  else
    echo "BIOS mode detected - Available bootloaders:"
    echo ""
    echo "1) GRUB           - Standard BIOS bootloader"
    echo "                    Reliable and widely supported"
    echo ""
    print_warning "systemd-boot requires UEFI"
    print_warning "libreboot requires specific hardware"
  fi
}

select_bootloader() {
  list_bootloaders

  while true; do
    if [ "$BOOT_MODE" = "UEFI" ]; then
      read -p "Select bootloader [1-3]: " choice
    else
      read -p "Select bootloader [1]: " choice
      choice=1 # Force GRUB for BIOS
    fi

    case $choice in
    1)
      if [ "$BOOT_MODE" = "UEFI" ]; then
        SELECTED_BOOTLOADER="systemd-boot"
        BOOTLOADER_NAME="systemd-boot"
      else
        SELECTED_BOOTLOADER="grub"
        BOOTLOADER_NAME="GRUB"
      fi
      break
      ;;
    2)
      if [ "$BOOT_MODE" = "UEFI" ]; then
        SELECTED_BOOTLOADER="grub"
        BOOTLOADER_NAME="GRUB"
        break
      else
        print_error "Invalid selection for BIOS mode"
        continue
      fi
      ;;
    3)
      if [ "$BOOT_MODE" = "UEFI" ]; then
        SELECTED_BOOTLOADER="libreboot"
        BOOTLOADER_NAME="libreboot"
        print_warning "libreboot requires compatible hardware"
        echo ""
        read -p "Is your system libreboot-compatible? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
          break
        else
          print_info "Please select a different bootloader"
          continue
        fi
      else
        print_error "Invalid selection for BIOS mode"
        continue
      fi
      ;;
    *)
      print_error "Invalid selection"
      continue
      ;;
    esac
  done

  print_success "Selected: $BOOTLOADER_NAME"
  export SELECTED_BOOTLOADER
  export BOOTLOADER_NAME
}

find_root_device() {
  print_info "Detecting root device..."

  # Find root partition
  ROOT_PART=$(mount | grep "on /mnt " | awk '{print $1}')

  if [ -z "$ROOT_PART" ]; then
    print_error "Could not detect root partition"
    return 1
  fi

  # Get UUID
  ROOT_UUID=$(blkid -s UUID -o value "$ROOT_PART")

  if [ -z "$ROOT_UUID" ]; then
    print_error "Could not get root partition UUID"
    return 1
  fi

  print_success "Root partition: $ROOT_PART (UUID: $ROOT_UUID)"
  export ROOT_PART
  export ROOT_UUID

  return 0
}

find_efi_partition() {
  print_info "Detecting EFI partition..."

  # Find EFI partition
  EFI_PART=$(mount | grep "on /mnt/boot " | awk '{print $1}')

  if [ -z "$EFI_PART" ]; then
    print_warning "EFI partition not mounted at /mnt/boot"
    print_info "Looking for /mnt/efi..."
    EFI_PART=$(mount | grep "on /mnt/efi " | awk '{print $1}')
  fi

  if [ -z "$EFI_PART" ]; then
    print_error "Could not detect EFI partition"
    return 1
  fi

  print_success "EFI partition: $EFI_PART"
  export EFI_PART

  return 0
}

install_systemd_boot() {
  print_info "Installing systemd-boot..."

  # Find EFI partition
  find_efi_partition || return 1

  # Install bootloader
  arch-chroot /mnt bootctl install

  if [ $? -ne 0 ]; then
    print_error "Failed to install systemd-boot"
    return 1
  fi

  print_success "systemd-boot installed"

  # Configure loader
  print_info "Configuring systemd-boot..."

  cat >/mnt/boot/loader/loader.conf <<EOF
default  imaginary.conf
timeout  4
console-mode max
editor   no
EOF

  # Create boot entry
  local root_param="root=UUID=$ROOT_UUID"

  # Add encryption parameters if needed
  if [ "$ENCRYPTED_ROOT" = "true" ]; then
    root_param="cryptdevice=UUID=$ROOT_UUID:cryptroot root=/dev/mapper/cryptroot"
  fi

  cat >/mnt/boot/loader/entries/imaginary.conf <<EOF
title   Imaginary Linux
linux   /vmlinuz-$SELECTED_KERNEL
initrd  /initramfs-$SELECTED_KERNEL.img
options $root_param rw quiet splash
EOF

  # Add fallback entry
  cat >/mnt/boot/loader/entries/imaginary-fallback.conf <<EOF
title   Imaginary Linux (fallback)
linux   /vmlinuz-$SELECTED_KERNEL
initrd  /initramfs-$SELECTED_KERNEL-fallback.img
options $root_param rw
EOF

  print_success "systemd-boot configured"

  return 0
}

install_grub_uefi() {
  print_info "Installing GRUB for UEFI..."

  # Find EFI partition
  find_efi_partition || return 1

  # Install GRUB packages
  arch-chroot /mnt pacman -S --noconfirm --needed grub efibootmgr

  # Install GRUB to EFI
  arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=IMAGINARY

  if [ $? -ne 0 ]; then
    print_error "Failed to install GRUB"
    return 1
  fi

  print_success "GRUB installed"

  # Configure GRUB
  configure_grub

  return 0
}

install_grub_bios() {
  print_info "Installing GRUB for BIOS..."

  # Get disk device (not partition)
  local disk_device=$(lsblk -no pkname "$ROOT_PART" | head -1)
  disk_device="/dev/$disk_device"

  print_info "Installing GRUB to: $disk_device"

  # Install GRUB packages
  arch-chroot /mnt pacman -S --noconfirm --needed grub

  # Install GRUB to disk
  arch-chroot /mnt grub-install --target=i386-pc "$disk_device"

  if [ $? -ne 0 ]; then
    print_error "Failed to install GRUB"
    return 1
  fi

  print_success "GRUB installed"

  # Configure GRUB
  configure_grub

  return 0
}

configure_grub() {
  print_info "Configuring GRUB..."

  # Update GRUB configuration
  if [ "$ENCRYPTED_ROOT" = "true" ]; then
    # Add encryption support
    arch-chroot /mnt sed -i "s|^GRUB_CMDLINE_LINUX=.*|GRUB_CMDLINE_LINUX=\"cryptdevice=UUID=$ROOT_UUID:cryptroot\"|" /etc/default/grub
  fi

  # Enable os-prober for dual boot detection
  echo "GRUB_DISABLE_OS_PROBER=false" >>/mnt/etc/default/grub
  arch-chroot /mnt pacman -S --noconfirm --needed os-prober

  # Generate GRUB config
  arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

  if [ $? -eq 0 ]; then
    print_success "GRUB configured"
  else
    print_error "Failed to generate GRUB config"
    return 1
  fi

  return 0
}

install_libreboot() {
  print_info "Installing libreboot..."

  print_warning "libreboot installation requires manual configuration"
  print_warning "This installer will prepare the system, but you must:"
  print_warning "  1. Flash libreboot to your device separately"
  print_warning "  2. Configure payload manually"

  echo ""
  read -p "Continue with libreboot preparation? (y/N): " -n 1 -r
  echo

  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "Switching to GRUB instead..."
    SELECTED_BOOTLOADER="grub"
    install_grub_uefi
    return $?
  fi

  # Install GRUB as fallback
  print_info "Installing GRUB as fallback bootloader..."
  arch-chroot /mnt pacman -S --noconfirm --needed grub efibootmgr

  print_success "System prepared for libreboot"
  print_info "Manual steps required:"
  print_info "  1. Flash libreboot firmware to your device"
  print_info "  2. Configure GRUB payload in libreboot"
  print_info "  3. Update boot configuration"

  return 0
}

display_summary() {
  echo ""
  echo -e "${BLUE}═══════════════════════════════════════${NC}"
  echo -e "${BLUE}    Bootloader Installation Summary${NC}"
  echo -e "${BLUE}═══════════════════════════════════════${NC}"
  echo -e "Boot Mode:    ${GREEN}$BOOT_MODE${NC}"
  echo -e "Bootloader:   ${GREEN}$BOOTLOADER_NAME${NC}"
  echo -e "Root Device:  ${GREEN}$ROOT_PART${NC}"
  if [ "$BOOT_MODE" = "UEFI" ]; then
    echo -e "EFI Partition: ${GREEN}$EFI_PART${NC}"
  fi
  echo -e "${BLUE}═══════════════════════════════════════${NC}"
  echo ""
}

main() {
  echo -e "${BLUE}"
  echo "╔═══════════════════════════════════════════╗"
  echo "║       Bootloader Installation             ║"
  echo "╚═══════════════════════════════════════════╝"
  echo -e "${NC}"

  # Check if BOOT_MODE is set
  if [ -z "$BOOT_MODE" ]; then
    print_error "BOOT_MODE not set"
    print_info "Please run 00-checks.sh first"
    return 1
  fi

  # Find root device
  find_root_device || return 1

  # Select bootloader
  select_bootloader

  # Confirm selection
  echo ""
  read -p "Install $BOOTLOADER_NAME? (Y/n): " -n 1 -r
  echo

  if [[ $REPLY =~ ^[Nn]$ ]]; then
    print_info "Bootloader installation cancelled"
    return 1
  fi

  # Install selected bootloader
  case "$SELECTED_BOOTLOADER" in
  systemd-boot)
    install_systemd_boot || return 1
    ;;
  grub)
    if [ "$BOOT_MODE" = "UEFI" ]; then
      install_grub_uefi || return 1
    else
      install_grub_bios || return 1
    fi
    ;;
  libreboot)
    install_libreboot || return 1
    ;;
  *)
    print_error "Unknown bootloader: $SELECTED_BOOTLOADER"
    return 1
    ;;
  esac

  # Display summary
  display_summary

  print_success "Bootloader installation complete!"

  return 0
}

# Run if executed directly
if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
  main "$@"
fi
