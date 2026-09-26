#!/bin/bash
# Module 90: Final Configuration and Cleanup
# Performs final system configuration and cleanup tasks

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

configure_locale() {
  print_info "Configuring locale..."

  # Uncomment en_US.UTF-8
  arch-chroot /mnt sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen

  # Ask user if they want additional locales
  echo ""
  read -p "Add additional locales? (y/N): " -n 1 -r
  echo

  if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "Common locales:"
    print_info "  en_GB.UTF-8 UTF-8 (British English)"
    print_info "  es_ES.UTF-8 UTF-8 (Spanish)"
    print_info "  fr_FR.UTF-8 UTF-8 (French)"
    print_info "  de_DE.UTF-8 UTF-8 (German)"
    print_info "  ja_JP.UTF-8 UTF-8 (Japanese)"
    print_info "  zh_CN.UTF-8 UTF-8 (Chinese)"
    echo ""
    read -p "Enter locale(s) to add (e.g., 'en_GB.UTF-8 UTF-8') or press Enter to skip: " additional_locale

    if [ -n "$additional_locale" ]; then
      arch-chroot /mnt sed -i "s/^#${additional_locale}/${additional_locale}/" /etc/locale.gen
      print_success "Added locale: $additional_locale"
    fi
  fi

  # Generate locales
  arch-chroot /mnt locale-gen

  # Set default locale
  echo "LANG=en_US.UTF-8" >/mnt/etc/locale.conf

  print_success "Locale configured"
}

configure_timezone() {
  print_info "Configuring timezone..."

  # Show current detected timezone
  local current_tz=$(timedatectl show --property=Timezone --value 2>/dev/null || echo "Unknown")
  print_info "Current timezone: $current_tz"

  echo ""
  read -p "Set custom timezone? (y/N): " -n 1 -r
  echo

  if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "List common timezones:"
    echo "  America/New_York"
    echo "  America/Chicago"
    echo "  America/Denver"
    echo "  America/Los_Angeles"
    echo "  Europe/London"
    echo "  Europe/Paris"
    echo "  Europe/Berlin"
    echo "  Asia/Tokyo"
    echo "  Asia/Shanghai"
    echo "  Australia/Sydney"
    echo ""
    print_info "Or list all: ls /usr/share/zoneinfo/"
    echo ""

    while true; do
      read -p "Enter timezone (e.g., America/New_York): " TIMEZONE

      if [ -f "/usr/share/zoneinfo/$TIMEZONE" ]; then
        arch-chroot /mnt ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
        print_success "Timezone set to: $TIMEZONE"
        break
      else
        print_error "Invalid timezone: $TIMEZONE"
      fi
    done
  else
    # Use detected timezone or default to UTC
    if [ "$current_tz" != "Unknown" ] && [ -f "/usr/share/zoneinfo/$current_tz" ]; then
      arch-chroot /mnt ln -sf "/usr/share/zoneinfo/$current_tz" /etc/localtime
      print_success "Using detected timezone: $current_tz"
    else
      arch-chroot /mnt ln -sf /usr/share/zoneinfo/UTC /etc/localtime
      print_success "Using default timezone: UTC"
    fi
  fi

  # Set hardware clock
  arch-chroot /mnt hwclock --systohc

  print_success "Timezone configured"
}

configure_vconsole() {
  print_info "Configuring virtual console..."

  # Set console keymap
  echo "KEYMAP=us" >/mnt/etc/vconsole.conf

  # Ask if user wants different keymap
  echo ""
  read -p "Change console keymap from 'us'? (y/N): " -n 1 -r
  echo

  if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "Common keymaps: us, uk, de, fr, es, dvorak"
    read -p "Enter keymap: " keymap
    echo "KEYMAP=$keymap" >/mnt/etc/vconsole.conf
    print_success "Keymap set to: $keymap"
  else
    print_success "Using default keymap: us"
  fi
}

configure_pacman() {
  print_info "Configuring pacman..."

  # Enable parallel downloads
  arch-chroot /mnt sed -i 's/^#ParallelDownloads = 5/ParallelDownloads = 5/' /etc/pacman.conf

  # Enable color output
  arch-chroot /mnt sed -i 's/^#Color/Color/' /etc/pacman.conf

  # Add ILoveCandy (Easter egg)
  arch-chroot /mnt sed -i '/^Color/a ILoveCandy' /etc/pacman.conf

  print_success "Pacman configured with parallel downloads and color"
}

setup_imaginary_repo() {
  print_info "Setting up Imaginary Linux repository..."

  echo ""
  print_info "The Imaginary repository provides:"
  print_info "  • imaginary-release - OS branding and identification"
  print_info "  • imaginary-angel - System guardian and maintenance tool"
  print_info "  • Future Imaginary-specific utilities"
  echo ""

  read -p "Enable Imaginary Linux repository? (Y/n): " -n 1 -r
  echo

  if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    print_info "Adding Imaginary repository to pacman.conf..."

    # Add repository to pacman.conf
    cat >>/mnt/etc/pacman.conf <<'EOF'

# Imaginary Linux Repository
[imaginary]
SigLevel = Optional TrustAll
Server = https://github.com/digitalcanine/imaginary-repo/releases/download/packages
EOF

    print_success "Imaginary repository added"

    # Update package database
    print_info "Updating package database..."
    arch-chroot /mnt pacman -Sy

    print_success "Repository configured successfully"
  else
    print_info "Imaginary repository not enabled"
    print_info "You can enable it later by adding to /etc/pacman.conf:"
    echo ""
    echo "  [imaginary]"
    echo "  SigLevel = Optional TrustAll"
    echo "  Server = https://github.com/digitalcanine/imaginary-repo/releases/download/packages"
    echo ""
  fi
}

install_imaginary_release() {
  print_info "Installing Imaginary Linux branding..."

  echo ""
  print_info "The imaginary-release package provides:"
  print_info "  • OS branding script (command: imaginary-release)"
  print_info "  • Imaginary Linux identification files"
  print_info "  • Custom ASCII logos"
  print_info "  • Fastfetch configuration"
  echo ""

  read -p "Install imaginary-release package? (Y/n): " -n 1 -r
  echo

  if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    # Check if repository is configured
    if ! arch-chroot /mnt grep -q "\[imaginary\]" /etc/pacman.conf; then
      print_warning "Imaginary repository not configured"
      print_info "Configuring repository first..."
      setup_imaginary_repo
    fi

    # Install imaginary-release package
    print_info "Installing imaginary-release package..."

    if arch-chroot /mnt pacman -S --noconfirm imaginary-release; then
      print_success "imaginary-release package installed!"

      # Now run the branding script
      print_info "Applying Imaginary Linux branding..."

      if arch-chroot /mnt imaginary-release; then
        print_success "Imaginary Linux branding applied successfully!"

        echo ""
        print_info "Your system is now branded as Imaginary Linux!"
        print_info "Run 'fastfetch' after reboot to see the custom logo"
      else
        print_error "Failed to apply branding"
        print_warning "You can apply it manually after rebooting:"
        print_info "  sudo imaginary-release"
      fi
    else
      print_error "Failed to install imaginary-release package"
      print_warning "You can install it manually after rebooting:"
      print_info "  sudo pacman -S imaginary-release"
      print_info "  sudo imaginary-release"
    fi
  else
    print_info "imaginary-release not installed"
    print_info "You can install it later with:"
    print_info "  sudo pacman -S imaginary-release"
    print_info "  sudo imaginary-release"
  fi
}

install_imaginary_angel() {
  print_info "Installing Imaginary Angel..."

  echo ""
  print_info "Imaginary Angel is the system guardian for Imaginary Linux"
  print_info "Features:"
  print_info "  • System health monitoring and auto-repair"
  print_info "  • Security auditing and hardening"
  print_info "  • Network threat detection"
  print_info "  • Process analysis and cleanup"
  print_info "  • System integrity verification"
  echo ""

  read -p "Install Imaginary Angel? (Y/n): " -n 1 -r
  echo

  if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    # Check if repository is configured
    if ! arch-chroot /mnt grep -q "\[imaginary\]" /etc/pacman.conf; then
      print_warning "Imaginary repository not configured"
      print_info "Configuring repository first..."
      setup_imaginary_repo
    fi

    # Install imaginary-angel package
    print_info "Installing imaginary-angel package..."

    if arch-chroot /mnt pacman -S --noconfirm imaginary-angel; then
      print_success "Imaginary Angel installed successfully!"

      echo ""
      print_info "After rebooting:"
      print_info "  • Run 'imaginary-angel' to use the guardian system"
      print_info "  • Configuration: /etc/imaginary-angel.conf"
    else
      print_error "Failed to install imaginary-angel"
      print_warning "You can install it manually after rebooting:"
      print_info "  sudo pacman -S imaginary-angel"
    fi
  else
    print_info "Imaginary Angel not installed"
    print_info "You can install it later with:"
    print_info "  sudo pacman -S imaginary-angel"
  fi
}

install_aur_helper() {
  if [ -z "$AUR_HELPER" ]; then
    print_warning "No AUR helper selected, skipping"
    return 0
  fi

  print_info "Installing AUR helper: $AUR_HELPER"

  case "$AUR_HELPER" in
  paru)
    # Install paru
    arch-chroot /mnt bash -c "cd /tmp && \
                sudo -u $USERNAME git clone https://aur.archlinux.org/paru.git && \
                cd paru && \
                sudo -u $USERNAME makepkg -si --noconfirm"
    ;;
  yay)
    # Install yay
    arch-chroot /mnt bash -c "cd /tmp && \
                sudo -u $USERNAME git clone https://aur.archlinux.org/yay.git && \
                cd yay && \
                sudo -u $USERNAME makepkg -si --noconfirm"
    ;;
  esac

  if [ $? -eq 0 ]; then
    print_success "AUR helper installed: $AUR_HELPER"
  else
    print_warning "Failed to install AUR helper, but continuing"
  fi
}

harden_system() {
  echo ""
  echo -e "${BLUE}╔═══════════════════════════════════════════╗${NC}"
  echo -e "${BLUE}║       System Security Hardening           ║${NC}"
  echo -e "${BLUE}╚═══════════════════════════════════════════╝${NC}"
  echo ""

  # The hardening itself lives in imaginary-angel, so a fresh install and an
  # angel-updated system get exactly the same configuration
  local harden_script="/usr/share/imaginary-angel/hardening/harden.sh"

  if [ ! -f "/mnt${harden_script}" ]; then
    print_warning "Imaginary Angel is not installed, so hardening cannot be applied"
    print_info "After rebooting, install it and run the hardening script:"
    print_info "  sudo pacman -S imaginary-angel"
    print_info "  sudo ${harden_script}"
    return 0
  fi

  print_info "Applies: firewall (UFW), AppArmor, kernel and network hardening,"
  print_info "SSH hardening, core dumps off, su limited to the wheel group"
  echo ""

  read -p "Apply security hardening? (Y/n): " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Nn]$ ]]; then
    print_info "Skipping system hardening"
    print_info "You can apply it later with: sudo ${harden_script}"
    return 0
  fi

  local lock_modules=false
  read -p "Disable kernel module loading after boot? (servers only, desktop users press N) (y/N): " -n 1 -r
  echo
  [[ $REPLY =~ ^[Yy]$ ]] && lock_modules=true

  print_info "Applying system hardening..."
  if arch-chroot /mnt env HARDEN_LOCK_MODULES="$lock_modules" bash "$harden_script"; then
    print_success "System hardening complete!"
  else
    print_warning "Hardening finished with errors (see above); the system will still boot"
    print_info "Re-run it after rebooting with: sudo ${harden_script}"
  fi

  echo ""
  print_info "Hardening settings live in /etc/imaginary-angel.conf"
  print_info "Imaginary Angel can re-apply or update them at any time"
}

enable_systemd_services() {
  print_info "Enabling essential system services..."

  # Enable fstrim for SSD (if applicable)
  if lsblk -d -o name,rota | grep -q '0$'; then
    arch-chroot /mnt systemctl enable fstrim.timer
    print_success "Enabled fstrim.timer (SSD optimization)"
  fi

  # Enable systemd-timesyncd
  arch-chroot /mnt systemctl enable systemd-timesyncd.service
  print_success "Enabled time synchronization"

  print_success "Essential services enabled"
}

create_swap_file() {
  if [ -z "$SWAP_TYPE" ] || [ "$SWAP_TYPE" = "none" ]; then
    print_info "No swap configured, skipping swap file creation"
    return 0
  fi

  if [ "$SWAP_TYPE" = "file" ] && [ -n "$SWAP_SIZE" ]; then
    print_info "Creating swap file (${SWAP_SIZE}GB)..."

    arch-chroot /mnt dd if=/dev/zero of=/swapfile bs=1G count="$SWAP_SIZE" status=progress
    arch-chroot /mnt chmod 600 /swapfile
    arch-chroot /mnt mkswap /swapfile
    arch-chroot /mnt swapon /swapfile

    # Add to fstab
    echo "/swapfile none swap defaults 0 0" >>/mnt/etc/fstab

    print_success "Swap file created and enabled"
  fi
}

setup_fastfetch() {
  print_info "Setting up system info display..."

  # Install fastfetch if not already installed
  if ! arch-chroot /mnt pacman -Q fastfetch &>/dev/null; then
    arch-chroot /mnt pacman -S --noconfirm fastfetch
  fi

  print_success "System info tools configured"
}

cleanup_installation() {
  print_info "Cleaning up installation files..."

  # Clean pacman cache
  arch-chroot /mnt pacman -Sc --noconfirm

  # Remove temporary files
  rm -rf /mnt/tmp/*
  rm -rf /mnt/var/tmp/*

  # Clear bash history
  rm -f /mnt/root/.bash_history
  rm -f /mnt/home/$USERNAME/.bash_history

  print_success "Cleanup complete"
}

generate_install_log() {
  print_info "Generating installation log..."

  local log_file="/mnt/var/log/imaginary-install.log"

  cat >"$log_file" <<EOF
Imaginary Linux Installation Log
=================================
Date: $(date)
Hostname: $HOSTNAME
Username: $USERNAME
Boot Mode: $BOOT_MODE
CPU: $CPU_VENDOR - $CPU_MODEL
GPU: $GPU_VENDOR - $GPU_MODEL
Desktop: ${SELECTED_PROFILE:-Not selected}
Kernel: $(arch-chroot /mnt uname -r)
Installation completed successfully.
EOF

  print_success "Installation log saved to /var/log/imaginary-install.log"
}

verify_installation() {
  echo ""
  echo -e "${YELLOW}═══════════════════════════════════════${NC}"
  echo -e "${YELLOW}    Installation Verification${NC}"
  echo -e "${YELLOW}═══════════════════════════════════════${NC}"

  print_info "Checking critical components..."

  # Check fstab
  if [ -f /mnt/etc/fstab ] && [ -s /mnt/etc/fstab ]; then
    print_success "fstab exists and is not empty"
  else
    print_error "fstab is missing or empty!"
  fi

  # Check user exists
  if arch-chroot /mnt id "$USERNAME" &>/dev/null; then
    print_success "User $USERNAME exists"
  else
    print_error "User $USERNAME not found!"
  fi

  # Check root password
  local root_status=$(arch-chroot /mnt passwd --status root | awk '{print $2}')
  if [ "$root_status" = "P" ]; then
    print_success "Root password is set"
  else
    print_error "Root password not set properly!"
  fi

  # Check bootloader files
  if [ "$BOOT_MODE" = "UEFI" ]; then
    if [ -d /mnt/boot/EFI ] || [ -d /mnt/boot/loader ]; then
      print_success "Bootloader files found"
    else
      print_error "Bootloader files not found!"
    fi
  else
    if [ -d /mnt/boot/grub ]; then
      print_success "GRUB files found"
    else
      print_error "GRUB files not found!"
    fi
  fi

  # Check kernel and initramfs
  if ls /mnt/boot/vmlinuz-* &>/dev/null && ls /mnt/boot/initramfs-* &>/dev/null; then
    print_success "Kernel and initramfs present"
  else
    print_error "Kernel or initramfs missing!"
  fi

  # Check hostname
  if [ -f /mnt/etc/hostname ]; then
    print_success "Hostname configured: $(cat /mnt/etc/hostname)"
  else
    print_error "Hostname not configured!"
  fi

  echo -e "${YELLOW}═══════════════════════════════════════${NC}"
  echo ""

  print_info "Press Enter to continue or Ctrl+C to abort..."
  read
}

display_summary() {
  echo ""
  echo -e "${BLUE}═══════════════════════════════════════${NC}"
  echo -e "${BLUE}    Final Configuration Summary${NC}"
  echo -e "${BLUE}═══════════════════════════════════════${NC}"
  echo -e "Locale:       ${GREEN}en_US.UTF-8${NC}"
  echo -e "Timezone:     ${GREEN}Configured${NC}"
  echo -e "Pacman:       ${GREEN}Optimized${NC}"
  if [ -n "$AUR_HELPER" ]; then
    echo -e "AUR Helper:   ${GREEN}$AUR_HELPER${NC}"
  fi
  echo -e "Services:     ${GREEN}Enabled${NC}"
  echo -e "${BLUE}═══════════════════════════════════════${NC}"
  echo ""
}

main() {
  echo -e "${BLUE}"
  echo "╔═══════════════════════════════════════════╗"
  echo "║      Final System Configuration           ║"
  echo "╚═══════════════════════════════════════════╝"
  echo -e "${NC}"

  # Run configuration tasks
  configure_locale
  configure_timezone
  configure_vconsole
  configure_pacman
  setup_imaginary_repo
  install_imaginary_release
  install_imaginary_angel
  install_aur_helper
  harden_system
  enable_systemd_services
  create_swap_file
  setup_fastfetch
  cleanup_installation
  generate_install_log

  # Display summary
  display_summary

  # Verify installation
  verify_installation

  print_success "Final configuration complete!"

  echo ""
  echo -e "${GREEN}╔═══════════════════════════════════════════╗${NC}"
  echo -e "${GREEN}║    Installation Complete!                ║${NC}"
  echo -e "${GREEN}╚═══════════════════════════════════════════╝${NC}"
  echo ""
  print_info "You can now review any errors above."
  print_info "Check /mnt/var/log/imaginary-install.log for details."
  echo ""
  print_info "When ready to reboot:"
  print_info "  1. Exit the installer"
  print_info "  2. Run: umount -R /mnt"
  print_info "  3. Run: reboot"
  echo ""

  return 0
}

# Run if executed directly
if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
  main "$@"
fi
