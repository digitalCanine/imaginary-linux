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

# Package categories
declare -A BROWSERS=(
  ["firefox"]="Mozilla Firefox - Popular open source browser"
  ["chromium"]="Chromium - Open source base of Chrome"
  ["brave-bin"]="Brave Browser - Privacy-focused (AUR)"
  ["librewolf-bin"]="LibreWolf - Privacy-hardened Firefox fork (AUR)"
)

declare -A TERMINALS=(
  ["kitty"]="Kitty - GPU accelerated terminal (default)"
  ["alacritty"]="Alacritty - Lightweight GPU terminal"
  ["wezterm"]="WezTerm - GPU terminal with tmux-like features"
  ["foot"]="Foot - Minimal Wayland terminal"
)

declare -A EDITORS=(
  ["neovim"]="Neovim - Modern Vim fork"
  ["vim"]="Vim - Classic text editor"
  ["code"]="VS Code - Microsoft's editor (AUR: visual-studio-code-bin)"
  ["vscodium-bin"]="VSCodium - VS Code without telemetry (AUR)"
)

declare -A FILE_MANAGERS=(
  ["thunar"]="Thunar - XFCE file manager (lightweight)"
  ["nautilus"]="Nautilus - GNOME file manager"
  ["dolphin"]="Dolphin - KDE file manager"
  ["ranger"]="Ranger - Terminal file manager"
  ["nnn"]="nnn - Fast terminal file manager"
)

declare -A MEDIA_PLAYERS=(
  ["vlc"]="VLC - Versatile media player"
  ["mpv"]="MPV - Minimal media player"
  ["celluloid"]="Celluloid - GTK frontend for MPV"
)

declare -A GRAPHICS=(
  ["gimp"]="GIMP - Image editor"
  ["inkscape"]="Inkscape - Vector graphics"
  ["krita"]="Krita - Digital painting"
  ["blender"]="Blender - 3D creation suite"
)

declare -A COMMUNICATION=(
  ["discord"]="Discord - Chat and VoIP"
  ["telegram-desktop"]="Telegram - Messaging app"
  ["signal-desktop"]="Signal - Private messaging"
  ["element-desktop"]="Element - Matrix client"
)

declare -A DEVELOPMENT=(
  ["git"]="Git - Version control"
  ["github-cli"]="GitHub CLI - GitHub from terminal"
  ["docker"]="Docker - Containerization"
  ["base-devel"]="Base Development - Compilers and build tools"
)

declare -A PRODUCTIVITY=(
  ["libreoffice-fresh"]="LibreOffice - Office suite"
  ["thunderbird"]="Thunderbird - Email client"
  ["obsidian"]="Obsidian - Note taking (AUR)"
  ["notion-app"]="Notion - Productivity workspace (AUR)"
)

declare -A GAMING=(
  ["steam"]="Steam - Gaming platform"
  ["lutris"]="Lutris - Game manager"
  ["wine"]="Wine - Windows compatibility"
  ["gamemode"]="GameMode - Performance optimization"
)

declare -A UTILITIES=(
  ["htop"]="htop - System monitor"
  ["btop"]="btop - Beautiful system monitor"
  ["neofetch"]="neofetch - System info"
  ["fastfetch"]="fastfetch - Fast system info"
  ["tmux"]="tmux - Terminal multiplexer"
)

select_from_category() {
  local category_name=$1
  local -n category=$2
  local selected_packages=()

  echo ""
  echo -e "${BLUE}═══ $category_name ═══${NC}"
  echo ""

  local index=1
  local pkg_names=()

  for pkg in "${!category[@]}"; do
    echo "  $index) $pkg"
    echo "     ${category[$pkg]}"
    echo ""
    pkg_names+=("$pkg")
    ((index++))
  done
  echo "  0) Skip this category"
  echo "  a) Install all from this category"
  echo ""

  read -p "Select packages (space-separated numbers, 'a' for all, or '0' to skip): " selection

  if [ "$selection" = "0" ]; then
    return 0
  elif [ "$selection" = "a" ] || [ "$selection" = "A" ]; then
    selected_packages=("${pkg_names[@]}")
  else
    for num in $selection; do
      if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -gt 0 ] && [ "$num" -lt "$index" ]; then
        selected_packages+=("${pkg_names[$((num - 1))]}")
      fi
    done
  fi

  if [ ${#selected_packages[@]} -gt 0 ]; then
    echo "${selected_packages[@]}"
  fi
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

  # Show instructions
  echo ""
  echo "For each category:"
  echo "  - Enter numbers separated by spaces (e.g., '1 3 5')"
  echo "  - Enter 'a' to install all from category"
  echo "  - Enter '0' to skip category"
  echo ""
  read -p "Press Enter to continue..." dummy

  # Browser selection
  if [ ${#BROWSERS[@]} -gt 0 ]; then
    local browser_pkgs=$(select_from_category "Web Browsers" BROWSERS)
    all_packages+=($browser_pkgs)
  fi

  # Terminal selection
  if [ ${#TERMINALS[@]} -gt 0 ]; then
    local terminal_pkgs=$(select_from_category "Terminal Emulators" TERMINALS)
    all_packages+=($terminal_pkgs)
  fi

  # Editor selection
  if [ ${#EDITORS[@]} -gt 0 ]; then
    local editor_pkgs=$(select_from_category "Text Editors" EDITORS)
    all_packages+=($editor_pkgs)
  fi

  # File manager selection
  if [ ${#FILE_MANAGERS[@]} -gt 0 ]; then
    local fm_pkgs=$(select_from_category "File Managers" FILE_MANAGERS)
    all_packages+=($fm_pkgs)
  fi

  # Media player selection
  if [ ${#MEDIA_PLAYERS[@]} -gt 0 ]; then
    local media_pkgs=$(select_from_category "Media Players" MEDIA_PLAYERS)
    all_packages+=($media_pkgs)
  fi

  # Graphics selection
  if [ ${#GRAPHICS[@]} -gt 0 ]; then
    local graphics_pkgs=$(select_from_category "Graphics Software" GRAPHICS)
    all_packages+=($graphics_pkgs)
  fi

  # Communication selection
  if [ ${#COMMUNICATION[@]} -gt 0 ]; then
    local comm_pkgs=$(select_from_category "Communication" COMMUNICATION)
    all_packages+=($comm_pkgs)
  fi

  # Development selection
  if [ ${#DEVELOPMENT[@]} -gt 0 ]; then
    local dev_pkgs=$(select_from_category "Development Tools" DEVELOPMENT)
    all_packages+=($dev_pkgs)
  fi

  # Productivity selection
  if [ ${#PRODUCTIVITY[@]} -gt 0 ]; then
    local prod_pkgs=$(select_from_category "Productivity" PRODUCTIVITY)
    all_packages+=($prod_pkgs)
  fi

  # Gaming selection
  if [ ${#GAMING[@]} -gt 0 ]; then
    local gaming_pkgs=$(select_from_category "Gaming" GAMING)
    all_packages+=($gaming_pkgs)
  fi

  # Utilities selection
  if [ ${#UTILITIES[@]} -gt 0 ]; then
    local util_pkgs=$(select_from_category "Utilities" UTILITIES)
    all_packages+=($util_pkgs)
  fi

  # Install all selected packages
  if [ ${#all_packages[@]} -gt 0 ]; then
    echo ""
    print_info "Selected packages:"
    printf '  - %s\n' "${all_packages[@]}"
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
