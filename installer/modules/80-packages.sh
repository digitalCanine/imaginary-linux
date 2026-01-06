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
declare -A BROWSERS
BROWSERS["firefox"]="Mozilla Firefox - Popular open source browser"
BROWSERS["chromium"]="Chromium - Open source base of Chrome"
BROWSERS["brave-bin"]="Brave Browser - Privacy-focused (AUR)"
BROWSERS["librewolf-bin"]="LibreWolf - Privacy-hardened Firefox fork (AUR)"

declare -A TERMINALS
TERMINALS["kitty"]="Kitty - GPU accelerated terminal (default)"
TERMINALS["alacritty"]="Alacritty - Lightweight GPU terminal"
TERMINALS["wezterm"]="WezTerm - GPU terminal with tmux-like features"
TERMINALS["foot"]="Foot - Minimal Wayland terminal"

declare -A EDITORS
EDITORS["neovim"]="Neovim - Modern Vim fork"
EDITORS["vim"]="Vim - Classic text editor"
EDITORS["code"]="VS Code - Microsoft's editor (AUR: visual-studio-code-bin)"
EDITORS["vscodium-bin"]="VSCodium - VS Code without telemetry (AUR)"

declare -A FILE_MANAGERS
FILE_MANAGERS["thunar"]="Thunar - XFCE file manager (lightweight)"
FILE_MANAGERS["nautilus"]="Nautilus - GNOME file manager"
FILE_MANAGERS["dolphin"]="Dolphin - KDE file manager"
FILE_MANAGERS["ranger"]="Ranger - Terminal file manager"
FILE_MANAGERS["nnn"]="nnn - Fast terminal file manager"

declare -A MEDIA_PLAYERS
MEDIA_PLAYERS["vlc"]="VLC - Versatile media player"
MEDIA_PLAYERS["mpv"]="MPV - Minimal media player"
MEDIA_PLAYERS["celluloid"]="Celluloid - GTK frontend for MPV"

declare -A GRAPHICS
GRAPHICS["gimp"]="GIMP - Image editor"
GRAPHICS["inkscape"]="Inkscape - Vector graphics"
GRAPHICS["krita"]="Krita - Digital painting"
GRAPHICS["blender"]="Blender - 3D creation suite"

declare -A COMMUNICATION
COMMUNICATION["discord"]="Discord - Chat and VoIP"
COMMUNICATION["telegram-desktop"]="Telegram - Messaging app"
COMMUNICATION["signal-desktop"]="Signal - Private messaging"
COMMUNICATION["element-desktop"]="Element - Matrix client"

declare -A DEVELOPMENT
DEVELOPMENT["git"]="Git - Version control"
DEVELOPMENT["github-cli"]="GitHub CLI - GitHub from terminal"
DEVELOPMENT["docker"]="Docker - Containerization"
DEVELOPMENT["base-devel"]="Base Development - Compilers and build tools"

declare -A PRODUCTIVITY
PRODUCTIVITY["libreoffice-fresh"]="LibreOffice - Office suite"
PRODUCTIVITY["thunderbird"]="Thunderbird - Email client"
PRODUCTIVITY["obsidian"]="Obsidian - Note taking (AUR)"
PRODUCTIVITY["notion-app"]="Notion - Productivity workspace (AUR)"

declare -A GAMING
GAMING["steam"]="Steam - Gaming platform"
GAMING["lutris"]="Lutris - Game manager"
GAMING["wine"]="Wine - Windows compatibility"
GAMING["gamemode"]="GameMode - Performance optimization"

declare -A UTILITIES
UTILITIES["htop"]="htop - System monitor"
UTILITIES["btop"]="btop - Beautiful system monitor"
UTILITIES["neofetch"]="neofetch - System info"
UTILITIES["fastfetch"]="fastfetch - Fast system info"
UTILITIES["tmux"]="tmux - Terminal multiplexer"

select_from_category() {
    local category_name=$1
    local array_name=$2
    local -n category=$array_name
    
    echo ""
    echo -e "${BLUE}═══ $category_name ═══${NC}"
    echo ""
    
    # Check if category has items
    if [ ${#category[@]} -eq 0 ]; then
        print_warning "No packages in this category"
        return 0
    fi
    
    local index=1
    local -a pkg_names=()
    local -a pkg_descs=()
    
    # Build arrays of package names and descriptions
    for pkg in "${!category[@]}"; do
        pkg_names+=("$pkg")
        pkg_descs+=("${category[$pkg]}")
    done
    
    # Display packages
    for i in "${!pkg_names[@]}"; do
        local num=$((i + 1))
        printf "  %d) %s\n" "$num" "${pkg_names[$i]}"
        printf "     %s\n" "${pkg_descs[$i]}"
        echo ""
    done
    
    echo "  0) Skip this category"
    echo "  a) Install all from this category"
    echo ""
    
    read -p "Select packages (space-separated numbers, 'a' for all, or '0' to skip): " selection
    
    # Handle empty input or skip
    if [ -z "$selection" ] || [ "$selection" = "0" ]; then
        return 0
    fi
    
    # Handle 'install all'
    if [ "$selection" = "a" ] || [ "$selection" = "A" ]; then
        printf "%s\n" "${pkg_names[@]}"
        return 0
    fi
    
    # Handle individual selections
    for num in $selection; do
        if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -gt 0 ] && [ "$num" -le "${#pkg_names[@]}" ]; then
            echo "${pkg_names[$((num-1))]}"
        fi
    done
}

# Remove the array_to_list function as it's no longer needed

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
            *-bin|brave-bin|librewolf-bin|vscodium-bin|obsidian|notion-app)
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
    
    # Debug: Check if arrays are populated
    print_info "Available package categories:"
    echo "  • Browsers: ${#BROWSERS[@]} packages"
    echo "  • Terminals: ${#TERMINALS[@]} packages"
    echo "  • Editors: ${#EDITORS[@]} packages"
    echo "  • File Managers: ${#FILE_MANAGERS[@]} packages"
    echo "  • Media Players: ${#MEDIA_PLAYERS[@]} packages"
    echo "  • Graphics: ${#GRAPHICS[@]} packages"
    echo "  • Communication: ${#COMMUNICATION[@]} packages"
    echo "  • Development: ${#DEVELOPMENT[@]} packages"
    echo "  • Productivity: ${#PRODUCTIVITY[@]} packages"
    echo "  • Gaming: ${#GAMING[@]} packages"
    echo "  • Utilities: ${#UTILITIES[@]} packages"
    echo ""
    
    read -p "Do you want to manually select packages? (Y/n): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        print_info "Skipping custom package selection"
        return 0
    fi
    
    local all_packages=()
    local tmp=()
    
    # Instructions
    echo ""
    echo "For each category:"
    echo "  - Enter numbers separated by spaces (e.g., '1 3 5')"
    echo "  - Enter 'a' to install all from category"
    echo "  - Enter '0' or press Enter to skip category"
    echo ""
    read -p "Press Enter to continue..." dummy
    
    # Web Browsers
    mapfile -t tmp < <(select_from_category "Web Browsers" BROWSERS)
    all_packages+=("${tmp[@]}")
    
    # Terminals
    mapfile -t tmp < <(select_from_category "Terminal Emulators" TERMINALS)
    all_packages+=("${tmp[@]}")
    
    # Editors
    mapfile -t tmp < <(select_from_category "Text Editors" EDITORS)
    all_packages+=("${tmp[@]}")
    
    # File Managers
    mapfile -t tmp < <(select_from_category "File Managers" FILE_MANAGERS)
    all_packages+=("${tmp[@]}")
    
    # Media Players
    mapfile -t tmp < <(select_from_category "Media Players" MEDIA_PLAYERS)
    all_packages+=("${tmp[@]}")
    
    # Graphics
    mapfile -t tmp < <(select_from_category "Graphics Software" GRAPHICS)
    all_packages+=("${tmp[@]}")
    
    # Communication
    mapfile -t tmp < <(select_from_category "Communication" COMMUNICATION)
    all_packages+=("${tmp[@]}")
    
    # Development
    mapfile -t tmp < <(select_from_category "Development Tools" DEVELOPMENT)
    all_packages+=("${tmp[@]}")
    
    # Productivity
    mapfile -t tmp < <(select_from_category "Productivity" PRODUCTIVITY)
    all_packages+=("${tmp[@]}")
    
    # Gaming
    mapfile -t tmp < <(select_from_category "Gaming" GAMING)
    all_packages+=("${tmp[@]}")
    
    # Utilities
    mapfile -t tmp < <(select_from_category "Utilities" UTILITIES)
    all_packages+=("${tmp[@]}")
    
    # Remove duplicates and empty entries
    if [ "${#all_packages[@]}" -gt 0 ]; then
        mapfile -t all_packages < <(printf "%s\n" "${all_packages[@]}" | grep -v '^

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
 | sort -u)
    fi
    
    if [ "${#all_packages[@]}" -eq 0 ]; then
        print_info "No packages selected"
        return 0
    fi
    
    echo ""
    print_info "Selected packages:"
    for pkg in "${all_packages[@]}"; do
        echo "  • $pkg"
    done
    echo ""
    
    read -p "Proceed with installation? (Y/n): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        print_info "Package installation cancelled"
        return 0
    fi
    
    install_packages "${all_packages[@]}"
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
