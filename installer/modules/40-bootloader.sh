#!/bin/bash
# Module 40: Bootloader Installation
# Installs and configures bootloader (GRUB or systemd-boot)

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

select_bootloader() {
  echo ""
  echo -e "${BLUE}╔═══════════════════════════════════════════╗${NC}"
  echo -e "${BLUE}║       Bootloader Selection                ║${NC}"
  echo -e "${BLUE}╚═══════════════════════════════════════════╝${NC}"
  echo ""

  if [ "$BOOT_MODE" = "UEFI" ]; then
    echo "UEFI boot detected. Available bootloaders:"
    echo "1) systemd-boot (recommended for UEFI)"
    echo "2) GRUB"
    echo ""

    while true; do
      read -p "Select bootloader [1-2]: " choice

      case $choice in
      1)
        BOOTLOADER="systemd-boot"
        print_success "Selected: systemd-boot"
        break
        ;;
      2)
        BOOTLOADER="grub"
        print_success "Selected: GRUB"
        break
        ;;
      *)
        print_error "Invalid selection"
        ;;
      esac
    done
  else
    print_info "BIOS boot detected. Using GRUB (only option for BIOS)"
    BOOTLOADER="grub"
  fi

  export BOOTLOADER
}

detect_root_partition() {
  # Get root partition and its UUID
  ROOT_PART=$(findmnt -n -o SOURCE /mnt)
  ROOT_UUID=$(blkid -s UUID -o value "$ROOT_PART")
  ROOT_PARTUUID=$(blkid -s PARTUUID -o value "$ROOT_PART")

  print_info "Root partition: $ROOT_PART"
  print_info "Root UUID: $ROOT_UUID"
  print_info "Root PARTUUID: $ROOT_PARTUUID"

  export ROOT_PART
  export ROOT_UUID
  export ROOT_PARTUUID
}

detect_boot_partition() {
  # Try to detect boot partition
  if [ "$BOOT_MODE" = "UEFI" ]; then
    # Check if /mnt/efi or /mnt/boot is mounted
    if mountpoint -q /mnt/efi; then
      BOOT_MOUNT="/efi"
      BOOT_PART=$(findmnt -n -o SOURCE /mnt/efi)
    elif mountpoint -q /mnt/boot; then
      BOOT_MOUNT="/boot"
      BOOT_PART=$(findmnt -n -o SOURCE /mnt/boot)
    else
      print_warning "No separate boot partition detected"
      BOOT_MOUNT="/boot"
      BOOT_PART=""
    fi
  else
    BOOT_MOUNT="/boot"
    if mountpoint -q /mnt/boot; then
      BOOT_PART=$(findmnt -n -o SOURCE /mnt/boot)
    else
      BOOT_PART=""
    fi
  fi

  if [ -n "$BOOT_PART" ]; then
    print_info "Boot partition: $BOOT_PART mounted at $BOOT_MOUNT"
  else
    print_info "Boot partition: Using root partition"
  fi

  export BOOT_MOUNT
  export BOOT_PART
}

install_systemd_boot() {
  print_info "Installing systemd-boot..."

  # Install systemd-boot to EFI partition
  arch-chroot /mnt bootctl --esp-path="$BOOT_MOUNT" install

  if [ $? -ne 0 ]; then
    print_error "Failed to install systemd-boot"
    return 1
  fi

  print_success "systemd-boot installed"

  # Create loader configuration
  print_info "Configuring systemd-boot..."

  cat >/mnt"$BOOT_MOUNT"/loader/loader.conf <<'EOF'
default  imaginary.conf
timeout  4
console-mode max
editor   no
EOF

  print_success "loader.conf created"

  # Create boot entry
  print_info "Creating boot entry..."

  # Detect kernel
  if ls /mnt/boot/vmlinuz-linux-hardened &>/dev/null; then
    KERNEL_NAME="linux-hardened"
    KERNEL_PATH="/vmlinuz-linux-hardened"
    INITRAMFS_PATH="/initramfs-linux-hardened.img"
  elif ls /mnt/boot/vmlinuz-linux-zen &>/dev/null; then
    KERNEL_NAME="linux-zen"
    KERNEL_PATH="/vmlinuz-linux-zen"
    INITRAMFS_PATH="/initramfs-linux-zen.img"
  elif ls /mnt/boot/vmlinuz-linux-lts &>/dev/null; then
    KERNEL_NAME="linux-lts"
    KERNEL_PATH="/vmlinuz-linux-lts"
    INITRAMFS_PATH="/initramfs-linux-lts.img"
  else
    KERNEL_NAME="linux"
    KERNEL_PATH="/vmlinuz-linux"
    INITRAMFS_PATH="/initramfs-linux.img"
  fi

  print_info "Detected kernel: $KERNEL_NAME"

  # Create entry file
  cat >/mnt"$BOOT_MOUNT"/loader/entries/imaginary.conf <<EOF
title   Imaginary Linux
linux   $KERNEL_PATH
initrd  $INITRAMFS_PATH
options root=PARTUUID=$ROOT_PARTUUID rw quiet loglevel=3
EOF

  print_success "Boot entry created: imaginary.conf"

  # Show the entry
  print_info "Boot entry content:"
  cat /mnt"$BOOT_MOUNT"/loader/entries/imaginary.conf

  return 0
}

install_grub_uefi() {
  print_info "Installing GRUB for UEFI..."

  # Install GRUB package
  arch-chroot /mnt pacman -S --noconfirm --needed grub efibootmgr

  # Install GRUB to EFI partition
  arch-chroot /mnt grub-install \
    --target=x86_64-efi \
    --efi-directory="$BOOT_MOUNT" \
    --bootloader-id=GRUB \
    --recheck

  if [ $? -ne 0 ]; then
    print_error "Failed to install GRUB"
    return 1
  fi

  print_success "GRUB installed to EFI"

  # Generate GRUB config
  print_info "Generating GRUB configuration..."
  arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

  print_success "GRUB configured"

  return 0
}

install_grub_bios() {
  print_info "Installing GRUB for BIOS..."

  # Install GRUB package
  arch-chroot /mnt pacman -S --noconfirm --needed grub

  # Get disk (not partition) for BIOS install
  DISK=$(lsblk -ndo PKNAME "$ROOT_PART" | head -1)

  if [ -z "$DISK" ]; then
    print_error "Could not detect disk for GRUB installation"
    echo "Available disks:"
    lsblk -ndo NAME,SIZE,TYPE | grep disk
    read -p "Enter disk for GRUB (e.g., sda): " DISK
  fi

  print_info "Installing GRUB to /dev/$DISK"

  arch-chroot /mnt grub-install --target=i386-pc --recheck /dev/"$DISK"

  if [ $? -ne 0 ]; then
    print_error "Failed to install GRUB"
    return 1
  fi

  print_success "GRUB installed to /dev/$DISK"

  # Generate GRUB config
  print_info "Generating GRUB configuration..."
  arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

  print_success "GRUB configured"

  return 0
}

verify_bootloader() {
  print_info "Verifying bootloader installation..."

  if [ "$BOOTLOADER" = "systemd-boot" ]; then
    # Check systemd-boot files
    if [ -f /mnt"$BOOT_MOUNT"/loader/loader.conf ] &&
      [ -f /mnt"$BOOT_MOUNT"/loader/entries/imaginary.conf ] &&
      [ -f /mnt"$BOOT_MOUNT"/EFI/systemd/systemd-bootx64.efi ]; then
      print_success "systemd-boot installation verified"
      return 0
    else
      print_error "systemd-boot files incomplete!"
      return 1
    fi
  else
    # Check GRUB files
    if [ "$BOOT_MODE" = "UEFI" ]; then
      if [ -f /mnt"$BOOT_MOUNT"/EFI/GRUB/grubx64.efi ] &&
        [ -f /mnt/boot/grub/grub.cfg ]; then
        print_success "GRUB installation verified"
        return 0
      else
        print_error "GRUB files incomplete!"
        return 1
      fi
    else
      if [ -f /mnt/boot/grub/grub.cfg ]; then
        print_success "GRUB installation verified"
        return 0
      else
        print_error "GRUB config missing!"
        return 1
      fi
    fi
  fi
}

configure_kernel_parameters() {
  echo ""
  print_info "Additional kernel parameters (optional):"
  echo "Examples:"
  echo "  - quiet loglevel=3 (minimal boot messages)"
  echo "  - apparmor=1 security=apparmor (enable AppArmor)"
  echo "  - mitigations=off (disable CPU mitigations for performance)"
  echo ""

  read -p "Add custom kernel parameters? (y/N): " -n 1 -r
  echo

  if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "Enter kernel parameters: " KERNEL_PARAMS

    if [ "$BOOTLOADER" = "systemd-boot" ]; then
      # Update systemd-boot entry
      sed -i "s/options .*/options root=PARTUUID=$ROOT_PARTUUID rw $KERNEL_PARAMS/" \
        /mnt"$BOOT_MOUNT"/loader/entries/imaginary.conf
      print_success "Kernel parameters added to systemd-boot"
    else
      # Update GRUB config
      echo "GRUB_CMDLINE_LINUX=\"$KERNEL_PARAMS\"" >>/mnt/etc/default/grub
      arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
      print_success "Kernel parameters added to GRUB"
    fi
  fi
}

display_summary() {
  echo ""
  echo -e "${BLUE}═══════════════════════════════════════${NC}"
  echo -e "${BLUE}    Bootloader Installation Summary${NC}"
  echo -e "${BLUE}═══════════════════════════════════════${NC}"
  echo -e "Boot Mode:    ${GREEN}$BOOT_MODE${NC}"
  echo -e "Bootloader:   ${GREEN}$BOOTLOADER${NC}"
  echo -e "Root:         $ROOT_PART"
  echo -e "Root UUID:    $ROOT_UUID"
  if [ -n "$BOOT_PART" ]; then
    echo -e "Boot:         $BOOT_PART mounted at $BOOT_MOUNT"
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

  # Detect partitions and boot mode
  detect_root_partition
  detect_boot_partition

  # Select bootloader
  select_bootloader

  # Display summary
  display_summary

  read -p "Proceed with bootloader installation? (Y/n): " -n 1 -r
  echo

  if [[ $REPLY =~ ^[Nn]$ ]]; then
    print_info "Bootloader installation cancelled"
    return 1
  fi

  # Install based on selection
  if [ "$BOOTLOADER" = "systemd-boot" ]; then
    install_systemd_boot
  elif [ "$BOOT_MODE" = "UEFI" ]; then
    install_grub_uefi
  else
    install_grub_bios
  fi

  if [ $? -ne 0 ]; then
    print_error "Bootloader installation failed"
    return 1
  fi

  # Configure kernel parameters
  configure_kernel_parameters

  # Verify installation
  verify_bootloader

  print_success "Bootloader installation complete!"

  return 0
}

# Run if executed directly
if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
  main "$@"
fi
