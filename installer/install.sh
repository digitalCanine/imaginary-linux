#!/bin/bash
# Imaginary Linux Installer
# Version 1.0.0 (Shamshel)
# Main installer orchestrator

set -e # Exit on error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES_DIR="$SCRIPT_DIR/modules"
BRANDING_DIR="$SCRIPT_DIR/branding"
ASSETS_DIR="$SCRIPT_DIR/assets"

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

print_step() {
  echo ""
  echo -e "${CYAN}╔═══════════════════════════════════════════╗${NC}"
  echo -e "${CYAN}║  $1${NC}"
  echo -e "${CYAN}╚═══════════════════════════════════════════╝${NC}"
  echo ""
}

show_banner() {
  clear
  echo -e "${MAGENTA}"
  cat <<'EOF'
   ████▓▓▒▒      ▒▒▓▓████
  ████▓▓▓▒▒      ▒▒▓▓▓████
 ████▓▓▓▓▒▒      ▒▒▓▓▓▓████
████▓▓▓▓▒▒   ██   ▒▒▓▓▓▓████
███▓▓▓▒▒     ██     ▒▒▓▓▓███
██▓▓▒▒       ██       ▒▒▓▓██
█▓▒          ██          ▒▓█
▒                          ▒

    IMAGINARY LINUX
    Version 1.0.0 (Shamshel)
    
    A transformative Arch-based system
    with guardian philosophy built-in
EOF
  echo -e "${NC}"
  echo ""
}

show_welcome() {
  show_banner

  echo "Welcome to the Imaginary Linux installer."
  echo ""
  echo "This installer will guide you through:"
  echo "  • System checks and hardware detection"
  echo "  • Disk partitioning and formatting"
  echo "  • Base system installation"
  echo "  • Kernel selection"
  echo "  • Bootloader configuration"
  echo "  • User account creation"
  echo "  • Desktop environment selection"
  echo "  • Driver installation"
  echo "  • Optional software installation"
  echo "  • System finalization"
  echo ""
  echo "This is not an ISO - this is a transformation."
  echo "Your system will be configured with intention and care."
  echo ""
  read -p "Press Enter to begin..."
}

check_prerequisites() {
  print_step "Checking Prerequisites"

  # Check if running as root
  if [ "$EUID" -ne 0 ]; then
    print_error "This installer must be run as root"
    print_info "Please run: sudo ./install.sh"
    exit 1
  fi

  # Check if on Arch Linux
  if [ ! -f /etc/arch-release ]; then
    print_error "This installer must be run from an Arch Linux environment"
    print_info "Please boot from an Arch ISO first"
    exit 1
  fi

  # Check if modules directory exists
  if [ ! -d "$MODULES_DIR" ]; then
    print_error "Modules directory not found: $MODULES_DIR"
    exit 1
  fi

  # Check if all modules exist
  local required_modules=(
    "00-checks.sh"
    "10-disks.sh"
    "20-base.sh"
    "30-kernel.sh"
    "40-bootloader.sh"
    "50-users.sh"
    "60-desktop.sh"
    "70-drivers.sh"
    "80-packages.sh"
    "90-finalize.sh"
  )

  for module in "${required_modules[@]}"; do
    if [ ! -f "$MODULES_DIR/$module" ]; then
      print_error "Required module not found: $module"
      exit 1
    fi
  done

  print_success "All prerequisites satisfied"
}

source_module() {
  local module=$1
  local module_path="$MODULES_DIR/$module"

  if [ ! -f "$module_path" ]; then
    print_error "Module not found: $module"
    return 1
  fi

  # Source the module
  source "$module_path"

  return 0
}

run_module() {
  local module=$1
  local description=$2

  print_step "$description"

  # Source and run the module
  source_module "$module"

  if main; then
    print_success "Module completed: $module"
    return 0
  else
    print_error "Module failed: $module"
    return 1
  fi
}

install_branding() {
  print_step "Installing Imaginary Linux Branding"

  print_info "Installing OS identification files..."

  # Ensure directories exist
  mkdir -p /mnt/usr/lib
  mkdir -p /mnt/etc

  # Canonical os-release (systemd reads THIS)
  cat >/mnt/usr/lib/os-release <<'EOF'
NAME="Imaginary Linux"
PRETTY_NAME="Imaginary Linux"
ID=imaginary
ID_LIKE=arch
BUILD_ID=rolling
VERSION="1.0.0"
VERSION_ID="1.0.0"
VERSION_CODENAME=shamshel
ANSI_COLOR="38;2;139;69;255"
HOME_URL="https://github.com/digitalcanine/imaginary-linux"
DOCUMENTATION_URL="https://github.com/digitalcanine/imaginary-linux"
SUPPORT_URL="https://github.com/digitalcanine/imaginary-linux/issues"
BUG_REPORT_URL="https://github.com/digitalcanine/imaginary-linux/issues"
LOGO=imaginary
EOF

  # /etc/os-release should be a symlink
  ln -sf ../usr/lib/os-release /mnt/etc/os-release

  # Install lsb-release
  cat >/mnt/etc/lsb-release <<'EOF'
DISTRIB_ID=Imaginary
DISTRIB_RELEASE=1.0.0
DISTRIB_CODENAME=shamshel
DISTRIB_DESCRIPTION="Imaginary Linux"
EOF

  # Install imaginary-release
  cat >/mnt/etc/imaginary-release <<'EOF'
IMAGINARY_VERSION="1.0.0"
IMAGINARY_CODENAME="Shamshel"
IMAGINARY_ANGEL="Shamshel"
IMAGINARY_BUILD_DATE="2026-01-07"
IMAGINARY_PHILOSOPHY="Protection through awareness"
EOF

  print_success "OS identification files installed"

  # Install ASCII logos
  print_info "Installing ASCII logos..."

  mkdir -p /mnt/usr/share/imaginary

  # Large logo
  cat >/mnt/usr/share/imaginary/logo.txt <<'EOF'
   ████▓▓▒▒      ▒▒▓▓████
  ████▓▓▓▒▒      ▒▒▓▓▓████
 ████▓▓▓▓▒▒      ▒▒▓▓▓▓████
████▓▓▓▓▒▒   ██   ▒▒▓▓▓▓████
███▓▓▓▒▒     ██     ▒▒▓▓▓███
██▓▓▒▒       ██       ▒▒▓▓██
█▓▒          ██          ▒▓█
▒                          ▒
       IMAGINARY LINUX
EOF

  # Small logo
  cat >/mnt/usr/share/imaginary/logo-small.txt <<'EOF'
█▓▒  ▒▓█
▓▒ IL ▒▓
▒      ▒
EOF

  print_success "ASCII logos installed"

  # Configure fastfetch
  print_info "Configuring fastfetch..."

  mkdir -p /mnt/etc/fastfetch

  cat >/mnt/etc/fastfetch/config.jsonc <<'EOF'
{
    "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
    "logo": {
        "type": "file",
        "source": "/usr/share/imaginary/logo.txt",
        "color": {
            "1": "magenta",
            "2": "blue"
        }
    },
    "display": {
        "separator": " → "
    },
    "modules": [
        {
            "type": "title",
            "format": "{user-name-colored}@{host-name-colored}"
        },
        {
            "type": "separator"
        },
        {
            "type": "os",
            "key": "OS"
        },
        {
            "type": "kernel",
            "key": "Kernel"
        },
        {
            "type": "uptime",
            "key": "Uptime"
        },
        {
            "type": "packages",
            "key": "Packages"
        },
        {
            "type": "shell",
            "key": "Shell"
        },
        {
            "type": "display",
            "key": "Resolution"
        },
        {
            "type": "de",
            "key": "DE"
        },
        {
            "type": "wm",
            "key": "WM"
        },
        {
            "type": "terminal",
            "key": "Terminal"
        },
        {
            "type": "cpu",
            "key": "CPU"
        },
        {
            "type": "gpu",
            "key": "GPU"
        },
        {
            "type": "memory",
            "key": "Memory"
        },
        {
            "type": "disk",
            "key": "Disk"
        },
        {
            "type": "separator"
        },
        {
            "type": "colors",
            "symbol": "circle"
        }
    ]
}
EOF

  print_success "Fastfetch configured"

  # Create MOTD
  print_info "Creating message of the day..."

  cat >/mnt/etc/motd <<'EOF'

   ████▓▓▒▒      ▒▒▓▓████
  ████▓▓▓▒▒      ▒▒▓▓▓████
 ████▓▓▓▓▒▒      ▒▒▓▓▓▓████
████▓▓▓▓▒▒   ██   ▒▒▓▓▓▓████
███▓▓▓▒▒     ██     ▒▒▓▓▓███
██▓▓▒▒       ██       ▒▒▓▓██
█▓▒          ██          ▒▓█
▒                          ▒

       IMAGINARY LINUX
    Version 1.0.0 (Shamshel)

Welcome to Imaginary Linux - A transformative Arch-based system
Documentation: https://github.com/digitalcanine/imaginary-linux

EOF

  print_success "MOTD created"

  # Setup auto-run fastfetch
  print_info "Setting up fastfetch auto-run..."

  cat >/mnt/etc/profile.d/imaginary-fetch.sh <<'EOF'
#!/bin/bash
# Auto-run fastfetch on new interactive shells (once per session)

if [[ $- == *i* ]] && [ -z "$IMAGINARY_FETCH_SHOWN" ]; then
    export IMAGINARY_FETCH_SHOWN=1
    
    if command -v fastfetch &> /dev/null; then
        fastfetch
    fi
fi
EOF

  chmod +x /mnt/etc/profile.d/imaginary-fetch.sh

  print_success "Fastfetch auto-run configured"

  print_success "Branding installation complete!"
}

show_completion() {
  clear
  echo -e "${GREEN}"
  cat <<'EOF'
   ████▓▓▒▒      ▒▒▓▓████
  ████▓▓▓▒▒      ▒▒▓▓▓████
 ████▓▓▓▓▒▒      ▒▒▓▓▓▓████
████▓▓▓▓▒▒   ██   ▒▒▓▓▓▓████
███▓▓▓▒▒     ██     ▒▒▓▓▓███
██▓▓▒▒       ██       ▒▒▓▓██
█▓▒          ██          ▒▓█
▒                          ▒

    INSTALLATION COMPLETE!
    
    Imaginary Linux 1.0.0 (Shamshel)
    has been successfully installed.
EOF
  echo -e "${NC}"
  echo ""
  echo "Your system is ready to use."
  echo ""
  echo "Next steps:"
  echo "  1. Remove the installation media"
  echo "  2. Reboot your system"
  echo "  3. Log in with your created user account"
  echo ""
  echo "On first boot, fastfetch will show your system info."
  echo ""
  echo "Thank you for choosing Imaginary Linux."
  echo "Power should be usable without being reckless."
  echo ""
}

main() {
  # Show welcome
  show_welcome

  # Check prerequisites
  check_prerequisites

  # Run installation modules in order
  run_module "00-checks.sh" "Step 1/10: System Checks" || exit 1
  run_module "10-disks.sh" "Step 2/10: Disk Setup" || exit 1
  run_module "20-base.sh" "Step 3/10: Base System Installation" || exit 1
  run_module "30-kernel.sh" "Step 4/10: Kernel Installation" || exit 1
  run_module "40-bootloader.sh" "Step 5/10: Bootloader Setup" || exit 1
  run_module "50-users.sh" "Step 6/10: User Configuration" || exit 1
  run_module "60-desktop.sh" "Step 7/10: Desktop Environment" || exit 1
  run_module "70-drivers.sh" "Step 8/10: Hardware Drivers" || exit 1
  run_module "80-packages.sh" "Step 9/10: Optional Software" || exit 1

  # Install branding
  install_branding

  # Finalize installation
  run_module "90-finalize.sh" "Step 10/10: Final Configuration" || exit 1

  # Show completion message
  show_completion

  # Ask to reboot
  read -p "Reboot now? (Y/n): " -n 1 -r
  echo

  if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    print_info "Rebooting..."
    umount -R /mnt
    reboot
  else
    print_info "Installation complete. Please reboot manually."
    print_info "Don't forget to remove the installation media!"
  fi
}

# Run main installer
main "$@"
