#!/bin/bash
# Module 80: Optional Package Installation
# Allows user to select and install additional software

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

print_error() {
  echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

select_browsers() {
  echo ""
  echo "=== Web Browsers ==="
  echo "1) Firefox"
  echo "2) Chromium"
  echo "3) Brave (AUR)"
  echo "4) LibreWolf (AUR)"
  echo "0) Skip"
  echo ""
  read -p "Select (space-separated): " choice

  for num in $choice; do
    case $num in
    1) echo "firefox" ;;
    2) echo "chromium" ;;
    3) echo "brave-bin" ;;
    4) echo "librewolf-bin" ;;
    esac
  done
}

select_terminals() {
  echo ""
  echo "=== Terminal Emulators ==="
  echo "1) Kitty"
  echo "2) Alacritty"
  echo "3) WezTerm"
  echo "4) Foot"
  echo "0) Skip"
  echo ""
  read -p "Select (space-separated): " choice

  for num in $choice; do
    case $num in
    1) echo "kitty" ;;
    2) echo "alacritty" ;;
    3) echo "wezterm" ;;
    4) echo "foot" ;;
    esac
  done
}

select_editors() {
  echo ""
  echo "=== Text Editors ==="
  echo "1) Neovim"
  echo "2) Vim"
  echo "3) VS Code (AUR)"
  echo "4) VSCodium (AUR)"
  echo "0) Skip"
  echo ""
  read -p "Select (space-separated): " choice

  for num in $choice; do
    case $num in
    1) echo "neovim" ;;
    2) echo "vim" ;;
    3) echo "visual-studio-code-bin" ;;
    4) echo "vscodium-bin" ;;
    esac
  done
}

select_file_managers() {
  echo ""
  echo "=== File Managers ==="
  echo "1) Thunar (lightweight)"
  echo "2) Nautilus (GNOME)"
  echo "3) Dolphin (KDE)"
  echo "4) Ranger (terminal)"
  echo "5) nnn (terminal)"
  echo "0) Skip"
  echo ""
  read -p "Select (space-separated): " choice

  for num in $choice; do
    case $num in
    1) echo "thunar" ;;
    2) echo "nautilus" ;;
    3) echo "dolphin" ;;
    4) echo "ranger" ;;
    5) echo "nnn" ;;
    esac
  done
}

select_media() {
  echo ""
  echo "=== Media Players ==="
  echo "1) VLC"
  echo "2) MPV"
  echo "3) Celluloid"
  echo "0) Skip"
  echo ""
  read -p "Select (space-separated): " choice

  for num in $choice; do
    case $num in
    1) echo "vlc" ;;
    2) echo "mpv" ;;
    3) echo "celluloid" ;;
    esac
  done
}

select_graphics() {
  echo ""
  echo "=== Graphics Software ==="
  echo "1) GIMP"
  echo "2) Inkscape"
  echo "3) Krita"
  echo "4) Blender"
  echo "0) Skip"
  echo ""
  read -p "Select (space-separated): " choice

  for num in $choice; do
    case $num in
    1) echo "gimp" ;;
    2) echo "inkscape" ;;
    3) echo "krita" ;;
    4) echo "blender" ;;
    esac
  done
}

select_communication() {
  echo ""
  echo "=== Communication ==="
  echo "1) Discord"
  echo "2) Telegram"
  echo "3) Signal"
  echo "4) Element (Matrix)"
  echo "0) Skip"
  echo ""
  read -p "Select (space-separated): " choice

  for num in $choice; do
    case $num in
    1) echo "discord" ;;
    2) echo "telegram-desktop" ;;
    3) echo "signal-desktop" ;;
    4) echo "element-desktop" ;;
    esac
  done
}

select_development() {
  echo ""
  echo "=== Development Tools ==="
  echo "1) Git"
  echo "2) GitHub CLI"
  echo "3) Docker"
  echo "4) Base Development (build tools)"
  echo "0) Skip"
  echo ""
  read -p "Select (space-separated): " choice

  for num in $choice; do
    case $num in
    1) echo "git" ;;
    2) echo "github-cli" ;;
    3) echo "docker" ;;
    4) echo "base-devel" ;;
    esac
  done
}

select_productivity() {
  echo ""
  echo "=== Productivity ==="
  echo "1) LibreOffice"
  echo "2) Thunderbird"
  echo "3) Obsidian (AUR)"
  echo "4) Notion (AUR)"
  echo "0) Skip"
  echo ""
  read -p "Select (space-separated): " choice

  for num in $choice; do
    case $num in
    1) echo "libreoffice-fresh" ;;
    2) echo "thunderbird" ;;
    3) echo "obsidian" ;;
    4) echo "notion-app" ;;
    esac
  done
}

select_gaming() {
  echo ""
  echo "=== Gaming ==="
  echo "1) Steam"
  echo "2) Lutris"
  echo "3) Wine"
  echo "4) GameMode"
  echo "0) Skip"
  echo ""
  read -p "Select (space-separated): " choice

  for num in $choice; do
    case $num in
    1) echo "steam" ;;
    2) echo "lutris" ;;
    3) echo "wine" ;;
    4) echo "gamemode" ;;
    esac
  done
}

select_utilities() {
  echo ""
  echo "=== Utilities ==="
  echo "1) htop"
  echo "2) btop"
  echo "3) neofetch"
  echo "4) fastfetch"
  echo "5) tmux"
  echo "0) Skip"
  echo ""
  read -p "Select (space-separated): " choice

  for num in $choice; do
    case $num in
    1) echo "htop" ;;
    2) echo "btop" ;;
    3) echo "neofetch" ;;
    4) echo "fastfetch" ;;
    5) echo "tmux" ;;
    esac
  done
}

install_packages() {
  local packages=("$@")

  if [ ${#packages[@]} -eq 0 ]; then
    print_info "No packages selected"
    return 0
  fi

  print_info "Installing selected packages..."

  # Separate AUR and official repo packages
  local repo_packages=()
  local aur_packages=()

  for pkg in "${packages[@]}"; do
    case "$pkg" in
    *-bin | brave-bin | librewolf-bin | vscodium-bin | obsidian | notion-app)
      aur_packages+=("$pkg")
      ;;
    code)
      aur_packages+=("visual-studio-code-bin")
      ;;
    *)
      repo_packages+=("$pkg")
      ;;
    esac
  done

  # Install official repo packages
  if [ ${#repo_packages[@]} -gt 0 ]; then
    print_info "Installing from official repositories..."
    arch-chroot /mnt pacman -S --noconfirm --needed "${repo_packages[@]}"

    if [ $? -eq 0 ]; then
      print_success "Official packages installed"
    else
      print_error "Some official packages failed to install"
    fi
  fi

  # Install AUR packages if AUR helper is available
  if [ ${#aur_packages[@]} -gt 0 ]; then
    if [ -n "$AUR_HELPER" ]; then
      print_info "Installing from AUR..."
      for aur_pkg in "${aur_packages[@]}"; do
        arch-chroot /mnt sudo -u "$USERNAME" "$AUR_HELPER" -S --noconfirm --needed "$aur_pkg"
      done
      print_success "AUR packages installed"
    else
      print_error "AUR helper not available, skipping AUR packages:"
      printf '%s\n' "${aur_packages[@]}"
    fi
  fi
}

select_installation_profile() {
  echo ""
  echo -e "${BLUE}╔═══════════════════════════════════════════╗${NC}"
  echo -e "${BLUE}║    Additional Software Installation       ║${NC}"
  echo -e "${BLUE}╚═══════════════════════════════════════════╝${NC}"
  echo ""

  echo "Choose installation profile:"
  echo "1) Minimal - Only essential tools"
  echo "2) Standard - Common applications"
  echo "3) Full - Everything including gaming and development"
  echo "4) Custom - Pick individual packages"
  echo ""

  read -p "Select profile [1-4]: " profile_choice

  case $profile_choice in
  1)
    INSTALL_PROFILE="minimal"
    ;;
  2)
    INSTALL_PROFILE="standard"
    ;;
  3)
    INSTALL_PROFILE="full"
    ;;
  4)
    INSTALL_PROFILE="custom"
    ;;
  *)
    print_error "Invalid selection, using minimal"
    INSTALL_PROFILE="minimal"
    ;;
  esac

  export INSTALL_PROFILE
}

install_minimal() {
  print_info "Installing minimal package set..."

  local packages=(
    "firefox"
    "git"
    "htop"
    "fastfetch"
    "vim"
  )

  install_packages "${packages[@]}"
}

install_standard() {
  print_info "Installing standard package set..."

  local packages=(
    "firefox"
    "thunderbird"
    "libreoffice-fresh"
    "vlc"
    "gimp"
    "git"
    "github-cli"
    "htop"
    "fastfetch"
    "neovim"
    "discord"
  )

  install_packages "${packages[@]}"
}

install_full() {
  print_info "Installing full package set..."

  local packages=(
    "firefox"
    "chromium"
    "thunderbird"
    "libreoffice-fresh"
    "vlc"
    "mpv"
    "gimp"
    "inkscape"
    "git"
    "github-cli"
    "docker"
    "base-devel"
    "htop"
    "btop"
    "fastfetch"
    "neovim"
    "discord"
    "telegram-desktop"
    "steam"
    "lutris"
    "wine"
    "gamemode"
    "tmux"
  )

  install_packages "${packages[@]}"

  # Enable docker if installed
  if arch-chroot /mnt pacman -Q docker &>/dev/null; then
    arch-chroot /mnt systemctl enable docker.service
    arch-chroot /mnt usermod -aG docker "$USERNAME"
    print_success "Docker enabled and user added to docker group"
  fi
}

install_custom() {
  print_info "Custom package selection..."

  local all_packages=()

  echo ""
  echo "Select packages from each category"
  echo "Enter numbers separated by spaces (e.g., '1 3 5')"
  echo "Enter '0' to skip a category"
  echo ""
  read -p "Press Enter to continue..." dummy

  # Collect selections from each category
  all_packages+=($(select_browsers))
  all_packages+=($(select_terminals))
  all_packages+=($(select_editors))
  all_packages+=($(select_file_managers))
  all_packages+=($(select_media))
  all_packages+=($(select_graphics))
  all_packages+=($(select_communication))
  all_packages+=($(select_development))
  all_packages+=($(select_productivity))
  all_packages+=($(select_gaming))
  all_packages+=($(select_utilities))

  # Install all selected packages
  if [ ${#all_packages[@]} -gt 0 ]; then
    echo ""
    print_info "Selected ${#all_packages[@]} package(s):"
    echo ""

    for pkg in "${all_packages[@]}"; do
      echo "  - $pkg"
    done

    echo ""
    read -p "Proceed with installation? (Y/n): " -n 1 -r
    echo

    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
      install_packages "${all_packages[@]}"
    else
      print_info "Package installation cancelled"
    fi
  else
    print_info "No packages selected"
  fi
}

main() {
  echo -e "${BLUE}"
  echo "╔═══════════════════════════════════════════╗"
  echo "║      Optional Package Installation        ║"
  echo "╚═══════════════════════════════════════════╝"
  echo -e "${NC}"

  # Check if this is a minimal installation (no optional packages)
  if [ "$INSTALLATION_TYPE" = "minimal" ]; then
    print_info "Minimal installation selected, skipping optional packages"
    return 0
  fi

  # Ask if user wants to install additional packages
  echo ""
  read -p "Install additional software? (Y/n): " -n 1 -r
  echo

  if [[ $REPLY =~ ^[Nn]$ ]]; then
    print_info "Skipping additional software installation"
    return 0
  fi

  # Select installation profile
  select_installation_profile

  # Install based on profile
  case "$INSTALL_PROFILE" in
  minimal)
    install_minimal
    ;;
  standard)
    install_standard
    ;;
  full)
    install_full
    ;;
  custom)
    install_custom
    ;;
  esac

  print_success "Optional package installation complete!"

  return 0
}

# Run if executed directly
if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
  main "$@"
fi
