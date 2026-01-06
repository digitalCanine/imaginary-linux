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

enable_multilib() {
  print_info "Checking multilib repository..."

  # Check if system is 64-bit
  if [ "$(uname -m)" = "x86_64" ]; then
    echo ""
    read -p "Enable multilib repository (32-bit support)? Recommended for gaming. (Y/n): " -n 1 -r
    echo

    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
      print_info "Enabling multilib repository..."
      arch-chroot /mnt sed -i '/^#\[multilib\]/,+1 s/^#//' /etc/pacman.conf
      arch-chroot /mnt pacman -Sy
      print_success "Multilib repository enabled"
    else
      print_info "Multilib repository not enabled"
    fi
  else
    print_info "System is not 64-bit, skipping multilib"
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

configure_firewall() {
  echo ""
  read -p "Enable firewall (UFW)? Recommended for security. (Y/n): " -n 1 -r
  echo

  if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    print_info "Installing and configuring firewall..."

    arch-chroot /mnt pacman -S --noconfirm ufw

    # Enable and configure UFW
    arch-chroot /mnt ufw default deny incoming
    arch-chroot /mnt ufw default allow outgoing
    arch-chroot /mnt ufw enable
    arch-chroot /mnt systemctl enable ufw.service

    print_success "Firewall enabled and configured"
  else
    print_info "Firewall not enabled"
  fi
}

enable_apparmor() {
  # Check if AppArmor is available in kernel
  if arch-chroot /mnt grep -q apparmor /proc/cmdline 2>/dev/null || [ -d /mnt/sys/kernel/security/apparmor ]; then
    echo ""
    read -p "Enable AppArmor (security framework)? (Y/n): " -n 1 -r
    echo

    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
      print_info "Installing AppArmor..."

      arch-chroot /mnt pacman -S --noconfirm apparmor
      arch-chroot /mnt systemctl enable apparmor.service

      print_success "AppArmor enabled"
      print_info "Note: Requires kernel parameter: apparmor=1 security=apparmor"
    else
      print_info "AppArmor not enabled"
    fi
  fi
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
  enable_multilib
  configure_pacman
  install_aur_helper
  configure_firewall
  enable_apparmor
  enable_systemd_services
  create_swap_file
  setup_fastfetch
  cleanup_installation
  generate_install_log

  # Display summary
  display_summary

  print_success "Final configuration complete!"

  return 0
}

# Run if executed directly
if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
  main "$@"
fi
