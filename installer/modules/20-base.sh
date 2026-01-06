#!/bin/bash
# Module 20: Base System Installation
# Installs core Arch Linux system using pacstrap

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

check_mount() {
  print_info "Checking if target is mounted..."

  if ! mountpoint -q /mnt; then
    print_error "Target directory /mnt is not mounted"
    print_info "Please run disk partitioning module first"
    return 1
  fi

  print_success "Target is mounted at /mnt"
  return 0
}

update_mirrorlist() {
  print_info "Updating pacman mirrorlist..."

  # Backup original mirrorlist
  cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup

  # Update package database first
  print_info "Updating package database..."
  pacman -Sy

  # Ask user if they want to use reflector for fastest mirrors
  echo ""
  read -p "Optimize mirrorlist for fastest mirrors? (Y/n): " -n 1 -r
  echo

  if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    # Install reflector if not present
    if ! command -v reflector &>/dev/null; then
      print_info "Installing reflector..."
      pacman -S --noconfirm reflector
    fi

    if command -v reflector &>/dev/null; then
      print_info "Running reflector to find fastest mirrors (this may take a minute)..."
      reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist || {
        print_warning "Reflector failed, using default mirrorlist"
      }
      print_success "Mirrorlist optimized"
    else
      print_warning "Reflector not available, using default mirrorlist"
    fi
  else
    print_info "Using default mirrorlist"
  fi

  # Update package database again with new mirrors
  pacman -Sy archlinux-keyring
}

install_base_packages() {
  print_info "Installing base system packages..."
  print_warning "This will take several minutes..."

  # Core base packages
  local base_packages=(
    "base"
    "base-devel"
    "linux-firmware"
  )

  # Essential system utilities
  local essential_packages=(
    "sudo"
    "networkmanager"
    "git"
    "vim"
    "nano"
    "wget"
    "curl"
    "man-db"
    "man-pages"
    "texinfo"
  )

  # Filesystem utilities
  local fs_packages=(
    "dosfstools"
    "exfatprogs"
    "ntfs-3g"
    "e2fsprogs"
  )

  # Combine all packages
  local all_packages=("${base_packages[@]}" "${essential_packages[@]}" "${fs_packages[@]}")

  # Install with pacstrap
  print_info "Running pacstrap (this may take 5-10 minutes)..."

  if pacstrap -K /mnt "${all_packages[@]}"; then
    print_success "Base system installed successfully"
  else
    print_error "Failed to install base system"
    return 1
  fi

  return 0
}

generate_fstab() {
  print_info "Generating fstab..."

  genfstab -U /mnt >>/mnt/etc/fstab

  if [ $? -eq 0 ]; then
    print_success "fstab generated"

    # Show fstab for verification
    echo ""
    print_info "Generated fstab:"
    cat /mnt/etc/fstab
    echo ""

    read -p "Does this look correct? (Y/n): " -n 1 -r
    echo

    if [[ $REPLY =~ ^[Nn]$ ]]; then
      print_warning "Please manually edit /mnt/etc/fstab after installation"
    fi
  else
    print_error "Failed to generate fstab"
    return 1
  fi

  return 0
}

configure_pacman_chroot() {
  print_info "Configuring pacman in new system..."

  # Enable parallel downloads
  arch-chroot /mnt sed -i 's/^#ParallelDownloads = 5/ParallelDownloads = 5/' /etc/pacman.conf

  # Enable color
  arch-chroot /mnt sed -i 's/^#Color/Color/' /etc/pacman.conf

  # Add ILoveCandy
  arch-chroot /mnt sed -i '/^Color/a ILoveCandy' /etc/pacman.conf

  print_success "Pacman configured"
}

setup_imaginary_repo() {
  print_info "Imaginary Linux repository (optional)"

  echo ""
  print_info "The Imaginary repository provides updates for:"
  print_info "  - imaginary-angel (system guardian tool)"
  print_info "  - Future Imaginary-specific utilities"
  echo ""
  print_warning "Repository is not yet available in v1.0.0"
  print_info "This will be enabled in a future update"
  echo ""

  # Commented out for now - will be enabled when repo is live
  # read -p "Add Imaginary Linux repository? (y/N): " -n 1 -r
  # echo
  #
  # if [[ $REPLY =~ ^[Yy]$ ]]; then
  #     cat >> /mnt/etc/pacman.conf << 'EOF'
  #
  # # Imaginary Linux Repository
  # [imaginary]
  # SigLevel = Optional TrustAll
  # Server = https://github.com/schizopup/imaginary-repo/releases/download/$arch
  # EOF
  #
  #     print_success "Imaginary Linux repository added"
  # else
  #     print_info "Imaginary repository not added"
  # fi

  print_info "Skipping Imaginary repository (not yet available)"
}

install_additional_tools() {
  print_info "Installing additional system tools..."

  # Install useful utilities
  local tools=(
    "bash-completion"
    "reflector"
    "rsync"
    "htop"
    "fastfetch"
  )

  arch-chroot /mnt pacman -S --noconfirm --needed "${tools[@]}"

  print_success "Additional tools installed"
}

display_summary() {
  echo ""
  echo -e "${BLUE}═══════════════════════════════════════${NC}"
  echo -e "${BLUE}    Base System Installation Summary${NC}"
  echo -e "${BLUE}═══════════════════════════════════════${NC}"
  echo -e "Base System:  ${GREEN}Installed${NC}"
  echo -e "Essential:    ${GREEN}Installed${NC}"
  echo -e "Utilities:    ${GREEN}Installed${NC}"
  echo -e "fstab:        ${GREEN}Generated${NC}"
  echo -e "Pacman:       ${GREEN}Configured${NC}"
  echo -e "${BLUE}═══════════════════════════════════════${NC}"
  echo ""
}

main() {
  echo -e "${BLUE}"
  echo "╔═══════════════════════════════════════════╗"
  echo "║       Base System Installation            ║"
  echo "╚═══════════════════════════════════════════╝"
  echo -e "${NC}"

  # Check prerequisites
  check_mount || return 1

  # Update mirrorlist
  update_mirrorlist

  # Install base system
  install_base_packages || return 1

  # Generate fstab
  generate_fstab || return 1

  # Configure pacman in chroot
  configure_pacman_chroot

  # Setup Imaginary repo
  setup_imaginary_repo

  # Install additional tools
  install_additional_tools

  # Display summary
  display_summary

  print_success "Base system installation complete!"

  return 0
}

# Run if executed directly
if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
  main "$@"
fi
