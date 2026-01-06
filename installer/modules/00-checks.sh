#!/bin/bash
# Module 00: Pre-flight Checks
# Verifies system requirements before installation

# Source common functions if they exist
if [ -f "$(dirname "$0")/../common.sh" ]; then
  source "$(dirname "$0")/../common.sh"
fi

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

check_root() {
  print_info "Verifying authority..."

  if [ "$EUID" -ne 0 ]; then
    print_error "Insufficient authority to continue"
    print_info "This operation requires elevated permissions"
    return 1
  fi

  print_success "Running with proper authority"
  return 0
}

check_arch_iso() {
  print_info "Confirming origin environment...."

  if [ ! -f /etc/arch-release ]; then
    print_error "This environment is not Arch-based"
    print_info "Imaginary Linux must be invoked from an Arch based foundation"
    return 1
  fi

  print_success "Running on Arch Linux"
  return 0
}

check_internet() {
  print_info "Observing for network connection..."

  if ! ping -c 1 archlinux.org &>/dev/null; then
    print_error "No connection detected"
    print_info "A connection is required to invoke Imaginary Linux"
    print_info "Use 'nmtui' or 'iwctl' to connect"
    return 1
  fi

  print_success "Connection detected"
  return 0
}

check_boot_mode() {
  print_info "Verifying the essence of the environment"

  if [ -d /sys/firmware/efi/efivars ]; then
    export BOOT_MODE="UEFI"
    print_success "UEFI environment confirmed"
  else
    export BOOT_MODE="BIOS"
    print_success "BIOS environment confirmed"
  fi

  return 0
}

check_disk_space() {
  print_info "Observing the space of the body..."

  # Get list of all disks and their sizes
  local disks=$(lsblk -ndo NAME,SIZE,TYPE | grep disk)

  if [ -z "$disks" ]; then
    print_error "No storage found"
    return 1
  fi

  print_success "Available bodies:"
  echo "$disks" | while read disk; do
    echo "  $disk"
  done

  # Check if any disk has at least 20GB
  local has_space=false
  while read -r name size type; do
    # Convert size to GB (rough estimation)
    local size_num=$(echo "$size" | sed 's/[^0-9.]//g')
    local size_unit=$(echo "$size" | sed 's/[0-9.]//g')

    if [[ "$size_unit" == "T"* ]] || [[ "$size_num" =~ ^[2-9][0-9]+$ ]] || [[ "$size_num" =~ ^[0-9]{3,}$ ]]; then
      has_space=true
      break
    fi
  done <<<"$disks"

  if [ "$has_space" = false ]; then
    print_warning "No body with sufficient space detected (minimum 20GB recommended)"
    print_info "You may continue, but the vessel might not be enough"
  fi

  return 0
}

check_memory() {
  print_info "Observing system memory"

  local total_mem=$(free -m | awk '/^Mem:/{print $2}')

  if [ "$total_mem" -lt 1024 ]; then
    print_warning "Low memory detected: ${total_mem}MB"
    print_info "Minimum 1GB recommended, 2GB or more preferred"
  else
    print_success "Available memory: ${total_mem}MB"
  fi

  return 0
}

check_virtualization() {
  print_info "Verifying if ran on a real vessel..."

  if systemd-detect-virt &>/dev/null; then
    local virt_type=$(systemd-detect-virt)
    print_info "Running on a virtual vessel: $virt_type"
    export IS_VM=true
    export VM_TYPE="$virt_type"
  else
    print_info "Running on a physical vessel"
    export IS_VM=false
  fi

  return 0
}

check_cpu() {
  print_info "Detecting the brain..."

  if grep -q "GenuineIntel" /proc/cpuinfo; then
    export CPU_VENDOR="intel"
    print_success "Intel CPU detected"
  elif grep -q "AuthenticAMD" /proc/cpuinfo; then
    export CPU_VENDOR="amd"
    print_success "AMD CPU detected"
  else
    export CPU_VENDOR="generic"
    print_info "Generic CPU detected"
  fi

  # Get CPU model
  export CPU_MODEL=$(grep -m1 "model name" /proc/cpuinfo | cut -d: -f2 | xargs)
  print_info "CPU: $CPU_MODEL"

  return 0
}

check_gpu() {
  print_info "Detecting the eyes..."

  # Check for NVIDIA
  if lspci | grep -i nvidia &>/dev/null; then
    export GPU_VENDOR="nvidia"
    export GPU_MODEL=$(lspci | grep -i nvidia | grep -i vga | cut -d: -f3 | xargs)
    print_success "NVIDIA GPU detected: $GPU_MODEL"
  # Check for AMD
  elif lspci | grep -i amd | grep -i vga &>/dev/null; then
    export GPU_VENDOR="amd"
    export GPU_MODEL=$(lspci | grep -i amd | grep -i vga | cut -d: -f3 | xargs)
    print_success "AMD GPU detected: $GPU_MODEL"
  # Check for Intel
  elif lspci | grep -i intel | grep -i vga &>/dev/null; then
    export GPU_VENDOR="intel"
    export GPU_MODEL=$(lspci | grep -i intel | grep -i vga | cut -d: -f3 | xargs)
    print_success "Intel GPU detected: $GPU_MODEL"
  else
    export GPU_VENDOR="generic"
    export GPU_MODEL="Unknown"
    print_info "Generic/Unknown GPU"
  fi

  return 0
}

update_system_clock() {
  print_info "Giving it a sense of time..."

  timedatectl set-ntp true

  if [ $? -eq 0 ]; then
    print_success "System time synchronized"
  else
    print_warning "Failed to synchronize the time"
  fi

  return 0
}

display_summary() {
  echo ""
  echo -e "${BLUE}═══════════════════════════════════════${NC}"
  echo -e "${BLUE}          System Manifest${NC}"
  echo -e "${BLUE}═══════════════════════════════════════${NC}"
  echo -e "Boot Mode:    ${GREEN}$BOOT_MODE${NC}"
  echo -e "CPU Vendor:   ${GREEN}$CPU_VENDOR${NC}"
  echo -e "CPU Model:    $CPU_MODEL"
  echo -e "GPU Vendor:   ${GREEN}$GPU_VENDOR${NC}"
  echo -e "GPU Model:    $GPU_MODEL"
  if [ "$IS_VM" = true ]; then
    echo -e "Environment:  ${YELLOW}Virtual Machine ($VM_TYPE)${NC}"
  else
    echo -e "Environment:  Physical Hardware"
  fi
  echo -e "${BLUE}═══════════════════════════════════════${NC}"
  echo ""
}

main() {
  echo -e "${BLUE}"
  echo "╔═══════════════════════════════════════════╗"
  echo "║         Preparation of the host           ║"
  echo "╚═══════════════════════════════════════════╝"
  echo -e "${NC}"

  local checks_passed=true

  # Critical checks (must pass)
  check_root || checks_passed=false
  check_arch_iso || checks_passed=false
  check_internet || checks_passed=false

  if [ "$checks_passed" = false ]; then
    echo ""
    print_error "Critical checks failed. Cannot continue invokation."
    return 1
  fi

  # Information gathering checks (non-critical)
  check_boot_mode
  check_disk_space
  check_memory
  check_virtualization
  check_cpu
  check_gpu
  update_system_clock

  # Display summary
  display_summary

  # Final confirmation
  echo "System attunment complete"
  read -p "Continue with invokation? (y/N): " -n 1 -r
  echo

  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "Invokation cancelled by user"
    return 1
  fi

  print_success "Attunment checks complete!"
  return 0
}

# Run if executed directly
if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
  main "$@"
fi
