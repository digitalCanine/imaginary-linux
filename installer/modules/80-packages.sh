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

# Package data as simple arrays (name|description pairs)
get_browsers() {
  echo "firefox|Mozilla Firefox - Popular open source browser"
  echo "chromium|Chromium - Open source base of Chrome"
  echo "brave-bin|Brave Browser - Privacy-focused (AUR)"
  echo "librewolf-bin|LibreWolf - Privacy-hardened Firefox fork (AUR)"
}

get_terminals() {
  echo "kitty|Kitty - GPU accelerated terminal"
  echo "alacritty|Alacritty - Lightweight GPU terminal"
  echo "wezterm|WezTerm - GPU terminal with tmux-like features"
  echo "foot|Foot - Minimal Wayland terminal"
}

get_editors() {
  echo "neovim|Neovim - Modern Vim fork"
  echo "vim|Vim - Classic text editor"
  echo "code|VS Code - Microsoft's editor (AUR)"
  echo "vscodium-bin|VSCodium - VS Code without telemetry (AUR)"
}

get_file_managers() {
  echo "thunar|Thunar - XFCE file manager (lightweight)"
  echo "nautilus|Nautilus - GNOME file manager"
  echo "dolphin|Dolphin - KDE file manager"
  echo "ranger|Ranger - Terminal file manager"
  echo "nnn|nnn - Fast terminal file manager"
}

get_media_players() {
  echo "vlc|VLC - Versatile media player"
  echo "mpv|MPV - Minimal media player"
  echo "celluloid|Celluloid - GTK frontend for MPV"
}

get_graphics() {
  echo "gimp|GIMP - Image editor"
  echo "inkscape|Inkscape - Vector graphics"
  echo "krita|Krita - Digital painting"
  echo "blender|Blender - 3D creation suite"
}

get_communication() {
  echo "discord|Discord - Chat and VoIP"
  echo "telegram-desktop|Telegram - Messaging app"
  echo "signal-desktop|Signal - Private messaging"
  echo "element-desktop|Element - Matrix client"
}

get_development() {
  echo "git|Git - Version control"
  echo "github-cli|GitHub CLI - GitHub from terminal"
  echo "docker|Docker - Containerization"
  echo "base-devel|Base Development - Compilers and build tools"
}

get_productivity() {
  echo "libreoffice-fresh|LibreOffice - Office suite"
  echo "thunderbird|Thunderbird - Email client"
  echo "obsidian|Obsidian - Note taking (AUR)"
  echo "notion-app|Notion - Productivity workspace (AUR)"
}

get_gaming() {
  echo "steam|Steam - Gaming platform"
  echo "lutris|Lutris - Game manager"
  echo "wine|Wine - Windows compatibility"
  echo "gamemode|GameMode - Performance optimization"
}

get_utilities() {
  echo "htop|htop - System monitor"
  echo "btop|btop - Beautiful system monitor"
  echo "neofetch|neofetch - System info"
  echo "fastfetch|fastfetch - Fast system info"
  echo "tmux|tmux - Terminal multiplexer"
}

select_from_category() {
  local category_name=$1
  local get_function=$2

  echo ""
  echo -e "${BLUE}━━━ $category_name ━━━${NC}"
  echo ""

  local -a pkg_names=()
  local -a pkg_descs=()
  local index=1

  # Read packages from function
  while IFS='|' read -r name desc; do
    pkg_names+=("$name")
    pkg_descs+=("$desc")
    printf "  %d) %s\n" "$index" "$name"
    printf "     %s\n" "$desc"
    echo ""
    ((index++))
  done < <($get_function)

  if [ ${#pkg_names[@]} -eq 0 ]; then
    print_warning "No packages in this category"
    return 0
  fi

  echo "  0) Skip this category"
  echo "  a) Install all from this category"
  echo ""

  read -p "Select packages (space-separated numbers, 'a' for all, or '0' to skip): " selection

  # Handle empty input
  if [ -z "$selection" ] || [ "$selection" = "0" ]; then
    return 0
  fi

  local selected_packages=()

  if [ "$selection" = "a" ] || [ "$selection" = "A" ]; then
    selected_packages=("${pkg_names[@]}")
  else
    for num in $selection; do
      if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -gt 0 ] && [ "$num" -le "${#pkg_names[@]}" ]; then
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
  local browser_pkgs=$(select_from_category "Web Browsers" get_browsers)
  all_packages+=($browser_pkgs)

  # Terminal selection
  local terminal_pkgs=$(select_from_category "Terminal Emulators" get_terminals)
  all_packages+=($terminal_pkgs)

  # Editor selection
  local editor_pkgs=$(select_from_category "Text Editors" get_editors)
  all_packages+=($editor_pkgs)

  # File manager selection
  local fm_pkgs=$(select_from_category "File Managers" get_file_managers)
  all_packages+=($fm_pkgs)

  # Media player selection
  local media_pkgs=$(select_from_category "Media Players" get_media_players)
  all_packages+=($media_pkgs)

  # Graphics selection
  local graphics_pkgs=$(select_from_category "Graphics Software" get_graphics)
  all_packages+=($graphics_pkgs)

  # Communication selection
  local comm_pkgs=$(select_from_category "Communication" get_communication)
  all_packages+=($comm_pkgs)

  # Development selection
  local dev_pkgs=$(select_from_category "Development Tools" get_development)
  all_packages+=($dev_pkgs)

  # Productivity selection
  local prod_pkgs=$(select_from_category "Productivity" get_productivity)
  all_packages+=($prod_pkgs)

  # Gaming selection
  local gaming_pkgs=$(select_from_category "Gaming" get_gaming)
  all_packages+=($gaming_pkgs)

  # Utilities selection
  local util_pkgs=$(select_from_category "Utilities" get_utilities)
  all_packages+=($util_pkgs)

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
