#!/bin/bash
# Module 60: Desktop Environment Installation
# Installs selected desktop environment or window manager

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
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

# Get script directory to find profiles
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILES_DIR="$SCRIPT_DIR/../profiles"

list_profiles() {
  echo ""
  echo -e "${BLUE}╔═══════════════════════════════════════════╗${NC}"
  echo -e "${BLUE}║    Desktop Environment Selection         ║${NC}"
  echo -e "${BLUE}╚═══════════════════════════════════════════╝${NC}"
  echo ""
  echo -e "${MAGENTA}Full Desktop Environments:${NC}"
  echo "  1) GNOME     - Modern, feature-rich desktop"
  echo "  2) KDE       - Customizable and powerful"
  echo "  3) XFCE      - Lightweight and classic"
  echo "  4) Cinnamon  - Traditional desktop layout"
  echo ""
  echo -e "${MAGENTA}Window Managers (Advanced):${NC}"
  echo "  5) BSPWM     - Binary space partitioning WM"
  echo "  6) i3        - Tiling window manager"
  echo "  7) Hyprland  - Modern Wayland compositor"
  echo ""
  echo "  8) None      - Server/minimal installation"
  echo ""
}

select_desktop() {
  list_profiles

  while true; do
    read -p "Select desktop environment [1-8]: " choice

    case $choice in
    1)
      SELECTED_PROFILE="gnome"
      PROFILE_NAME="GNOME"
      break
      ;;
    2)
      SELECTED_PROFILE="kde"
      PROFILE_NAME="KDE Plasma"
      break
      ;;
    3)
      SELECTED_PROFILE="xfce"
      PROFILE_NAME="XFCE"
      break
      ;;
    4)
      SELECTED_PROFILE="cinnamon"
      PROFILE_NAME="Cinnamon"
      break
      ;;
    5)
      SELECTED_PROFILE="bspwm"
      PROFILE_NAME="BSPWM"
      break
      ;;
    6)
      SELECTED_PROFILE="i3"
      PROFILE_NAME="i3"
      break
      ;;
    7)
      SELECTED_PROFILE="hyprland"
      PROFILE_NAME="Hyprland"
      break
      ;;
    8)
      SELECTED_PROFILE="none"
      PROFILE_NAME="None (Server)"
      print_info "No desktop environment will be installed"
      export SELECTED_PROFILE
      export PROFILE_NAME
      return 0
      ;;
    *)
      print_error "Invalid selection"
      continue
      ;;
    esac
  done

  print_success "Selected: $PROFILE_NAME"
  export SELECTED_PROFILE
  export PROFILE_NAME
}

ask_installation_type() {
  if [ "$SELECTED_PROFILE" = "none" ]; then
    return 0
  fi

  echo ""
  echo "Installation type:"
  echo "1) Minimal  - Only essential packages"
  echo "2) Full     - Includes additional applications"
  echo ""

  while true; do
    read -p "Select installation type [1-2]: " choice

    case $choice in
    1)
      INSTALLATION_TYPE="minimal"
      print_info "Minimal installation selected"
      break
      ;;
    2)
      INSTALLATION_TYPE="full"
      print_info "Full installation selected"
      break
      ;;
    *)
      print_error "Invalid selection"
      ;;
    esac
  done

  export INSTALLATION_TYPE
}

ask_for_rice() {
  if [ "$SELECTED_PROFILE" != "bspwm" ]; then
    return 0
  fi

  echo ""
  print_info "BSPWM Rice Option"
  echo "Would you like to install the Imaginary BSPWM rice?"
  echo "This includes pre-configured dotfiles, themes, and customizations."
  echo ""

  read -p "Install Imaginary BSPWM rice? (Y/n): " -n 1 -r
  echo

  if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    INSTALL_RICE="true"
    print_success "Rice will be installed"
    # Force full installation for rice
    INSTALLATION_TYPE="full"
    print_info "Switching to full installation (required for rice)"
  else
    INSTALL_RICE="false"
    print_info "Using default BSPWM configuration"
  fi

  export INSTALL_RICE
}

select_aur_helper() {
  echo ""
  print_info "AUR Helper Selection"
  echo "AUR helpers allow you to install packages from the Arch User Repository."
  echo ""
  echo "1) paru (recommended) - Feature-rich, fast"
  echo "2) yay               - Popular, well-established"
  echo "3) None              - Don't install an AUR helper"
  echo ""

  while true; do
    read -p "Select AUR helper [1-3]: " choice

    case $choice in
    1)
      AUR_HELPER="paru"
      print_success "Selected: paru"
      break
      ;;
    2)
      AUR_HELPER="yay"
      print_success "Selected: yay"
      break
      ;;
    3)
      AUR_HELPER=""
      print_info "No AUR helper will be installed"
      break
      ;;
    *)
      print_error "Invalid selection"
      ;;
    esac
  done

  export AUR_HELPER
}

install_xorg() {
  # Check if profile needs Xorg (not Hyprland)
  if [ "$SELECTED_PROFILE" = "hyprland" ]; then
    print_info "Wayland profile selected, skipping Xorg"
    return 0
  fi

  print_info "Installing Xorg display server..."

  arch-chroot /mnt pacman -S --noconfirm --needed xorg-server xorg-xinit xorg-xrandr

  print_success "Xorg installed"
}

read_packages_file() {
  local profile=$1
  local packages_file="$PROFILES_DIR/$profile/packages.txt"

  if [ ! -f "$packages_file" ]; then
    print_error "Packages file not found: $packages_file"
    return 1
  fi

  # Read packages, excluding comments and empty lines
  local packages=$(grep -v '^#' "$packages_file" | grep -v '^$' | tr '\n' ' ')
  echo "$packages"
}

install_profile_packages() {
  local profile=$1

  print_info "Installing $PROFILE_NAME packages..."

  # Get package list
  local packages=$(read_packages_file "$profile")

  if [ -z "$packages" ]; then
    print_error "No packages found for profile: $profile"
    return 1
  fi

  # Separate official and AUR packages
  local repo_packages=$(echo "$packages" | tr ' ' '\n' | grep -v '^AUR:' | tr '\n' ' ')
  local aur_packages=$(echo "$packages" | tr ' ' '\n' | grep '^AUR:' | sed 's/^AUR://' | tr '\n' ' ')

  # Install official repo packages
  if [ -n "$repo_packages" ]; then
    print_info "Installing packages from official repositories..."
    arch-chroot /mnt pacman -S --noconfirm --needed $repo_packages

    if [ $? -eq 0 ]; then
      print_success "Official packages installed"
    else
      print_error "Some packages failed to install"
      return 1
    fi
  fi

  # Install AUR packages if AUR helper is available
  if [ -n "$aur_packages" ]; then
    if [ -n "$AUR_HELPER" ]; then
      print_info "Installing AUR packages..."
      for aur_pkg in $aur_packages; do
        print_info "Installing $aur_pkg from AUR..."
        arch-chroot /mnt sudo -u "$USERNAME" "$AUR_HELPER" -S --noconfirm --needed "$aur_pkg" || print_warning "Failed to install $aur_pkg"
      done
      print_success "AUR packages processed"
    else
      print_warning "AUR packages found but no AUR helper installed:"
      echo "$aur_packages"
    fi
  fi

  return 0
}

run_profile_setup() {
  local profile=$1
  local setup_script="$PROFILES_DIR/$profile/setup.sh"

  # Check if setup script exists
  if [ ! -f "$setup_script" ]; then
    print_info "No setup script for $profile, using default configuration"

    # Enable NetworkManager by default
    arch-chroot /mnt systemctl enable NetworkManager

    # Detect and enable display manager
    if arch-chroot /mnt pacman -Q gdm &>/dev/null; then
      arch-chroot /mnt systemctl enable gdm
      print_success "Enabled GDM display manager"
    elif arch-chroot /mnt pacman -Q sddm &>/dev/null; then
      arch-chroot /mnt systemctl enable sddm
      print_success "Enabled SDDM display manager"
    elif arch-chroot /mnt pacman -Q lightdm &>/dev/null; then
      arch-chroot /mnt systemctl enable lightdm
      print_success "Enabled LightDM display manager"
    elif arch-chroot /mnt pacman -Q ly &>/dev/null; then
      arch-chroot /mnt systemctl enable ly
      print_success "Enabled Ly display manager"
    fi

    return 0
  fi

  print_info "Running $PROFILE_NAME setup script..."

  # Export necessary variables for the setup script
  export USERNAME
  export USER_HOME="/home/$USERNAME"
  export INSTALL_RICE

  # Make script executable and run it
  chmod +x "$setup_script"

  # Copy script to chroot and execute
  cp "$setup_script" "/mnt/tmp/profile-setup.sh"
  arch-chroot /mnt bash /tmp/profile-setup.sh

  if [ $? -eq 0 ]; then
    print_success "$PROFILE_NAME setup complete"
  else
    print_error "Setup script failed, but continuing"
  fi

  # Cleanup
  rm -f /mnt/tmp/profile-setup.sh
}

display_summary() {
  echo ""
  echo -e "${BLUE}═══════════════════════════════════════${NC}"
  echo -e "${BLUE}    Desktop Installation Summary${NC}"
  echo -e "${BLUE}═══════════════════════════════════════${NC}"
  echo -e "Profile:      ${GREEN}$PROFILE_NAME${NC}"
  echo -e "Type:         ${GREEN}$INSTALLATION_TYPE${NC}"
  if [ -n "$AUR_HELPER" ]; then
    echo -e "AUR Helper:   ${GREEN}$AUR_HELPER${NC}"
  fi
  if [ "$INSTALL_RICE" = "true" ]; then
    echo -e "Rice:         ${GREEN}Imaginary BSPWM Rice${NC}"
  fi
  echo -e "${BLUE}═══════════════════════════════════════${NC}"
  echo ""
}

main() {
  echo -e "${BLUE}"
  echo "╔═══════════════════════════════════════════╗"
  echo "║    Desktop Environment Installation       ║"
  echo "╚═══════════════════════════════════════════╝"
  echo -e "${NC}"

  # Check if profiles directory exists
  if [ ! -d "$PROFILES_DIR" ]; then
    print_error "Profiles directory not found: $PROFILES_DIR"
    return 1
  fi

  # Get user selections
  select_desktop

  if [ "$SELECTED_PROFILE" = "none" ]; then
    print_success "No desktop environment selected"
    return 0
  fi

  ask_installation_type
  ask_for_rice
  select_aur_helper

  # Display summary and confirm
  display_summary

  read -p "Proceed with installation? (Y/n): " -n 1 -r
  echo

  if [[ $REPLY =~ ^[Nn]$ ]]; then
    print_info "Desktop installation cancelled"
    return 1
  fi

  # Install Xorg if needed
  install_xorg

  # Install profile packages
  install_profile_packages "$SELECTED_PROFILE"

  # Run profile-specific setup
  run_profile_setup "$SELECTED_PROFILE"

  print_success "Desktop environment installation complete!"

  return 0
}

# Run if executed directly
if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
  main "$@"
fi
