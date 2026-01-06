#!/bin/bash
# Module 70: Hardware Driver Installation
# Installs appropriate drivers based on detected hardware

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

install_cpu_microcode() {
  print_info "Installing CPU microcode..."

  case "$CPU_VENDOR" in
  intel)
    print_info "Installing Intel microcode"
    arch-chroot /mnt pacman -S --noconfirm intel-ucode
    print_success "Intel microcode installed"
    ;;
  amd)
    print_info "Installing AMD microcode"
    arch-chroot /mnt pacman -S --noconfirm amd-ucode
    print_success "AMD microcode installed"
    ;;
  *)
    print_warning "Unknown CPU vendor, skipping microcode"
    ;;
  esac
}

install_gpu_drivers() {
  print_info "Installing GPU drivers for: $GPU_VENDOR"

  case "$GPU_VENDOR" in
  nvidia)
    install_nvidia_drivers
    ;;
  amd)
    install_amd_drivers
    ;;
  intel)
    install_intel_drivers
    ;;
  *)
    print_warning "Unknown GPU vendor, installing generic drivers"
    install_generic_drivers
    ;;
  esac
}

install_nvidia_drivers() {
  print_info "Installing NVIDIA drivers..."

  # Ask user which driver version
  echo ""
  echo "NVIDIA Driver Options:"
  echo "1) nvidia-open (recommended for RTX 20 series and newer)"
  echo "2) nvidia (proprietary, for older GPUs)"
  echo "3) nouveau (open source, limited performance)"
  echo ""

  while true; do
    read -p "Select driver [1-3]: " choice
    case $choice in
    1)
      print_info "Installing nvidia-open drivers"
      arch-chroot /mnt pacman -S --noconfirm nvidia-open nvidia-utils nvidia-settings
      NVIDIA_DRIVER="nvidia-open"
      break
      ;;
    2)
      print_info "Installing proprietary nvidia drivers"
      arch-chroot /mnt pacman -S --noconfirm nvidia nvidia-utils nvidia-settings
      NVIDIA_DRIVER="nvidia"
      break
      ;;
    3)
      print_info "Using nouveau open source drivers (already included in kernel)"
      NVIDIA_DRIVER="nouveau"
      break
      ;;
    *)
      print_error "Invalid choice"
      ;;
    esac
  done

  if [ "$NVIDIA_DRIVER" != "nouveau" ]; then
    # Install additional NVIDIA packages
    arch-chroot /mnt pacman -S --noconfirm lib32-nvidia-utils vulkan-icd-loader lib32-vulkan-icd-loader

    # Enable nvidia services
    arch-chroot /mnt systemctl enable nvidia-suspend.service
    arch-chroot /mnt systemctl enable nvidia-hibernate.service
    arch-chroot /mnt systemctl enable nvidia-resume.service

    print_success "NVIDIA drivers installed"
  else
    print_success "Nouveau drivers will be used"
  fi
}

install_amd_drivers() {
  print_info "Installing AMD GPU drivers..."

  # Install Mesa drivers (open source, recommended)
  arch-chroot /mnt pacman -S --noconfirm mesa lib32-mesa xf86-video-amdgpu vulkan-radeon lib32-vulkan-radeon

  # Install AMD utilities
  arch-chroot /mnt pacman -S --noconfirm libva-mesa-driver lib32-libva-mesa-driver mesa-vdpau lib32-mesa-vdpau

  print_success "AMD GPU drivers installed"
}

install_intel_drivers() {
  print_info "Installing Intel GPU drivers..."

  # Install Intel drivers
  arch-chroot /mnt pacman -S --noconfirm mesa lib32-mesa vulkan-intel lib32-vulkan-intel

  # Install Intel media driver
  arch-chroot /mnt pacman -S --noconfirm intel-media-driver libva-intel-driver lib32-libva-intel-driver

  print_success "Intel GPU drivers installed"
}

install_generic_drivers() {
  print_info "Installing generic GPU drivers..."

  # Install basic Mesa
  arch-chroot /mnt pacman -S --noconfirm mesa lib32-mesa

  print_success "Generic GPU drivers installed"
}

install_audio_drivers() {
  print_info "Installing audio drivers..."

  # Install PipeWire (modern audio system)
  arch-chroot /mnt pacman -S --noconfirm pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber

  # Enable audio service
  # Note: PipeWire is started per-user, not system-wide

  print_success "Audio drivers installed (PipeWire)"
}

install_bluetooth() {
  print_info "Checking for Bluetooth hardware..."

  if lsusb | grep -i bluetooth &>/dev/null || lspci | grep -i bluetooth &>/dev/null; then
    print_info "Bluetooth hardware detected"

    read -p "Install Bluetooth support? (Y/n): " -n 1 -r
    echo

    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
      arch-chroot /mnt pacman -S --noconfirm bluez bluez-utils
      arch-chroot /mnt systemctl enable bluetooth.service
      print_success "Bluetooth support installed"
    else
      print_info "Skipping Bluetooth installation"
    fi
  else
    print_info "No Bluetooth hardware detected, skipping"
  fi
}

install_printer_support() {
  echo ""
  read -p "Install printer support (CUPS)? (y/N): " -n 1 -r
  echo

  if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "Installing printer support..."
    arch-chroot /mnt pacman -S --noconfirm cups cups-pdf system-config-printer
    arch-chroot /mnt systemctl enable cups.service
    print_success "Printer support installed"
  else
    print_info "Skipping printer support"
  fi
}

install_network_drivers() {
  print_info "Installing network drivers..."

  # NetworkManager is already installed in base system
  # Just ensure it's enabled
  arch-chroot /mnt systemctl enable NetworkManager

  # Install additional network tools
  arch-chroot /mnt pacman -S --noconfirm networkmanager-openvpn nm-connection-editor

  print_success "Network drivers configured"
}

install_vm_tools() {
  if [ "$IS_VM" = "true" ]; then
    print_info "Virtual machine detected: $VM_TYPE"

    case "$VM_TYPE" in
    kvm | qemu)
      print_info "Installing QEMU guest agent..."
      arch-chroot /mnt pacman -S --noconfirm qemu-guest-agent
      arch-chroot /mnt systemctl enable qemu-guest-agent.service
      print_success "QEMU guest agent installed"
      ;;
    vmware)
      print_info "Installing VMware tools..."
      arch-chroot /mnt pacman -S --noconfirm open-vm-tools
      arch-chroot /mnt systemctl enable vmtoolsd.service
      print_success "VMware tools installed"
      ;;
    oracle)
      print_info "Installing VirtualBox guest additions..."
      arch-chroot /mnt pacman -S --noconfirm virtualbox-guest-utils
      arch-chroot /mnt systemctl enable vboxservice.service
      print_success "VirtualBox guest additions installed"
      ;;
    *)
      print_info "Unknown VM type, skipping VM-specific tools"
      ;;
    esac
  fi
}

install_filesystem_tools() {
  print_info "Installing filesystem utilities..."

  # Install common filesystem tools
  arch-chroot /mnt pacman -S --noconfirm dosfstools exfatprogs ntfs-3g

  # Install btrfs tools if btrfs was used
  if mount | grep -q btrfs; then
    arch-chroot /mnt pacman -S --noconfirm btrfs-progs
    print_success "Btrfs tools installed"
  fi

  print_success "Filesystem utilities installed"
}

display_summary() {
  echo ""
  echo -e "${BLUE}═══════════════════════════════════════${NC}"
  echo -e "${BLUE}    Driver Installation Summary${NC}"
  echo -e "${BLUE}═══════════════════════════════════════${NC}"
  echo -e "CPU Microcode: ${GREEN}Installed${NC}"
  echo -e "GPU Drivers:   ${GREEN}Installed${NC}"
  echo -e "Audio:         ${GREEN}PipeWire${NC}"
  echo -e "Network:       ${GREEN}NetworkManager${NC}"
  if [ "$IS_VM" = "true" ]; then
    echo -e "VM Tools:      ${GREEN}Installed${NC}"
  fi
  echo -e "${BLUE}═══════════════════════════════════════${NC}"
  echo ""
}

main() {
  echo -e "${BLUE}"
  echo "╔═══════════════════════════════════════════╗"
  echo "║       Hardware Driver Installation        ║"
  echo "╚═══════════════════════════════════════════╝"
  echo -e "${NC}"

  # Check if required variables are set
  if [ -z "$CPU_VENDOR" ] || [ -z "$GPU_VENDOR" ]; then
    print_error "Hardware detection variables not set"
    print_info "Please run 00-checks.sh first"
    return 1
  fi

  # Install drivers
  install_cpu_microcode
  install_gpu_drivers
  install_audio_drivers
  install_network_drivers
  install_bluetooth
  install_printer_support
  install_vm_tools
  install_filesystem_tools

  # Display summary
  display_summary

  print_success "Driver installation complete!"

  return 0
}

# Run if executed directly
if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
  main "$@"
fi
