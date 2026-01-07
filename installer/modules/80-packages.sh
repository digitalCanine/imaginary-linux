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
    1) SELECTED_PACKAGES+=("firefox") ;;
    2) SELECTED_PACKAGES+=("chromium") ;;
    3) SELECTED_PACKAGES+=("brave-bin") ;;
    4) SELECTED_PACKAGES+=("librewolf-bin") ;;
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
    1) SELECTED_PACKAGES+=("kitty") ;;
    2) SELECTED_PACKAGES+=("alacritty") ;;
    3) SELECTED_PACKAGES+=("wezterm") ;;
    4) SELECTED_PACKAGES+=("foot") ;;
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
    1) SELECTED_PACKAGES+=("neovim") ;;
    2) SELECTED_PACKAGES+=("vim") ;;
    3) SELECTED_PACKAGES+=("visual-studio-code-bin") ;;
    4) SELECTED_PACKAGES+=("vscodium-bin") ;;
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
    1) SELECTED_PACKAGES+=("thunar") ;;
    2) SELECTED_PACKAGES+=("nautilus") ;;
    3) SELECTED_PACKAGES+=("dolphin") ;;
    4) SELECTED_PACKAGES+=("ranger") ;;
    5) SELECTED_PACKAGES+=("nnn") ;;
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
    1) SELECTED_PACKAGES+=("vlc") ;;
    2) SELECTED_PACKAGES+=("mpv") ;;
    3) SELECTED_PACKAGES+=("celluloid") ;;
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
    1) SELECTED_PACKAGES+=("gimp") ;;
    2) SELECTED_PACKAGES+=("inkscape") ;;
    3) SELECTED_PACKAGES+=("krita") ;;
    4) SELECTED_PACKAGES+=("blender") ;;
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
    1) SELECTED_PACKAGES+=("discord") ;;
    2) SELECTED_PACKAGES+=("telegram-desktop") ;;
    3) SELECTED_PACKAGES+=("signal-desktop") ;;
    4) SELECTED_PACKAGES+=("element-desktop") ;;
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
    1) SELECTED_PACKAGES+=("git") ;;
    2) SELECTED_PACKAGES+=("github-cli") ;;
    3) SELECTED_PACKAGES+=("docker") ;;
    4) SELECTED_PACKAGES+=("base-devel") ;;
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
    1) SELECTED_PACKAGES+=("libreoffice-fresh") ;;
    2) SELECTED_PACKAGES+=("thunderbird") ;;
    3) SELECTED_PACKAGES+=("obsidian") ;;
    4) SELECTED_PACKAGES+=("notion-app") ;;
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
    1) SELECTED_PACKAGES+=("steam") ;;
    2) SELECTED_PACKAGES+=("lutris") ;;
    3) SELECTED_PACKAGES+=("wine") ;;
    4) SELECTED_PACKAGES+=("gamemode") ;;
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
    1) SELECTED_PACKAGES+=("htop") ;;
    2) SELECTED_PACKAGES+=("btop") ;;
    3) SELECTED_PACKAGES+=("neofetch") ;;
    4) SELECTED_PACKAGES+=("fastfetch") ;;
    5) SELECTED_PACKAGES+=("tmux") ;;
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

  # Initialize global array
  SELECTED_PACKAGES=()

  echo ""
  echo "Select packages from each category"
  echo "Enter numbers separated by spaces (e.g., '1 3 5')"
  echo "Enter '0' to skip a category"
  echo ""
  read -p "Press Enter to continue..." dummy

  # Call each selection function (they append to SELECTED_PACKAGES)
  select_browsers
  select_terminals
  select_editors
  select_file_managers
  select_media
  select_graphics
  select_communication
  select_development
  select_productivity
  select_gaming
  select_utilities

  # Install all selected packages
  if [ ${#SELECTED_PACKAGES[@]} -gt 0 ]; then
    echo ""
    print_info "Selected ${#SELECTED_PACKAGES[@]} package(s):"
    echo ""

    for pkg in "${SELECTED_PACKAGES[@]}"; do
      echo "  - $pkg"
    done

    echo ""
    read -p "Proceed with installation? (Y/n): " -n 1 -r
    echo

    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
      install_packages "${SELECTED_PACKAGES[@]}"
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
