#!/bin/bash
# Module 10: Disk Partitioning and Setup
# Handles disk selection, partitioning, formatting, and mounting

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

list_disks() {
  print_info "Available disks:"
  echo ""
  lsblk -ndo NAME,SIZE,TYPE,MODEL | grep disk
  echo ""
}

select_disk() {
  list_disks

  while true; do
    read -p "Enter disk to install to (e.g., sda, nvme0n1, vda): " disk_name

    DISK="/dev/$disk_name"

    if [ ! -b "$DISK" ]; then
      print_error "Disk $DISK does not exist"
      continue
    fi

    # Show disk info
    echo ""
    print_info "Selected disk: $DISK"
    lsblk "$DISK"
    echo ""

    print_warning "ALL DATA ON $DISK WILL BE ERASED!"
    read -p "Are you absolutely sure? Type 'YES' to confirm: " confirmation

    if [ "$confirmation" = "YES" ]; then
      export DISK
      print_success "Disk selected: $DISK"
      break
    else
      print_info "Disk selection cancelled"
    fi
  done
}

select_partitioning_mode() {
  echo ""
  echo -e "${BLUE}╔═══════════════════════════════════════════╗${NC}"
  echo -e "${BLUE}║       Partitioning Mode                   ║${NC}"
  echo -e "${BLUE}╚═══════════════════════════════════════════╝${NC}"
  echo ""
  echo "1) Auto    - Automatic partitioning (recommended)"
  echo "            Wipes disk and creates optimal layout"
  echo ""
  echo "2) Manual  - Manual partitioning with cfdisk"
  echo "            For advanced users"
  echo ""

  while true; do
    read -p "Select mode [1-2]: " choice

    case $choice in
    1)
      PARTITION_MODE="auto"
      break
      ;;
    2)
      PARTITION_MODE="manual"
      print_warning "You will need to manually create partitions"
      break
      ;;
    *)
      print_error "Invalid selection"
      ;;
    esac
  done

  export PARTITION_MODE
}

select_filesystem() {
  echo ""
  echo "Select root filesystem:"
  echo "1) ext4   - Reliable, stable (recommended)"
  echo "2) btrfs  - Modern, snapshots, compression"
  echo "3) xfs    - High performance, large files"
  echo "4) f2fs   - Optimized for SSDs/flash"
  echo ""

  while true; do
    read -p "Select filesystem [1-4]: " choice

    case $choice in
    1)
      ROOT_FS="ext4"
      break
      ;;
    2)
      ROOT_FS="btrfs"
      print_info "Btrfs selected - snapshots and subvolumes available"
      break
      ;;
    3)
      ROOT_FS="xfs"
      break
      ;;
    4)
      ROOT_FS="f2fs"
      print_warning "F2FS is best for SSDs only"
      break
      ;;
    *)
      print_error "Invalid selection"
      ;;
    esac
  done

  export ROOT_FS
}

select_swap() {
  echo ""
  echo "Swap configuration:"
  echo "1) Swap file     - Flexible size (recommended)"
  echo "2) Swap partition - Traditional"
  echo "3) zram         - Compressed RAM swap"
  echo "4) None         - No swap"
  echo ""

  while true; do
    read -p "Select swap type [1-4]: " choice

    case $choice in
    1)
      SWAP_TYPE="file"
      read -p "Swap file size in GB [8]: " swap_size
      SWAP_SIZE=${swap_size:-8}
      break
      ;;
    2)
      SWAP_TYPE="partition"
      read -p "Swap partition size in GB [8]: " swap_size
      SWAP_SIZE=${swap_size:-8}
      break
      ;;
    3)
      SWAP_TYPE="zram"
      print_info "zram will use compressed RAM"
      break
      ;;
    4)
      SWAP_TYPE="none"
      print_warning "No swap - may cause issues on low memory systems"
      break
      ;;
    *)
      print_error "Invalid selection"
      ;;
    esac
  done

  export SWAP_TYPE
  export SWAP_SIZE
}

auto_partition_uefi() {
  print_info "Creating UEFI partition layout..."

  # Wipe disk
  wipefs -af "$DISK"
  sgdisk -Z "$DISK"

  # Create GPT partition table
  parted -s "$DISK" mklabel gpt

  # Create EFI partition (512MB)
  parted -s "$DISK" mkpart primary fat32 1MiB 513MiB
  parted -s "$DISK" set 1 esp on

  if [ "$SWAP_TYPE" = "partition" ]; then
    # Create swap partition
    local swap_end=$((513 + SWAP_SIZE * 1024))
    parted -s "$DISK" mkpart primary linux-swap 513MiB ${swap_end}MiB

    # Create root partition (rest of disk)
    parted -s "$DISK" mkpart primary ext4 ${swap_end}MiB 100%

    # Set partition variables
    EFI_PART="${DISK}1"
    SWAP_PART="${DISK}2"
    ROOT_PART="${DISK}3"
  else
    # Create root partition (rest of disk)
    parted -s "$DISK" mkpart primary ext4 513MiB 100%

    # Set partition variables
    EFI_PART="${DISK}1"
    ROOT_PART="${DISK}2"
  fi

  # Handle nvme naming
  if [[ "$DISK" == *"nvme"* ]]; then
    EFI_PART="${DISK}p1"
    if [ "$SWAP_TYPE" = "partition" ]; then
      SWAP_PART="${DISK}p2"
      ROOT_PART="${DISK}p3"
    else
      ROOT_PART="${DISK}p2"
    fi
  fi

  print_success "Partitions created"

  export EFI_PART
  export ROOT_PART
  export SWAP_PART
}

auto_partition_bios() {
  print_info "Creating BIOS partition layout..."

  # Wipe disk
  wipefs -af "$DISK"

  # Create MBR partition table
  parted -s "$DISK" mklabel msdos

  if [ "$SWAP_TYPE" = "partition" ]; then
    # Create swap partition
    local swap_end=$((SWAP_SIZE * 1024))
    parted -s "$DISK" mkpart primary linux-swap 1MiB ${swap_end}MiB

    # Create root partition (rest of disk)
    parted -s "$DISK" mkpart primary ext4 ${swap_end}MiB 100%
    parted -s "$DISK" set 2 boot on

    # Set partition variables
    SWAP_PART="${DISK}1"
    ROOT_PART="${DISK}2"
  else
    # Create root partition (whole disk)
    parted -s "$DISK" mkpart primary ext4 1MiB 100%
    parted -s "$DISK" set 1 boot on

    # Set partition variables
    ROOT_PART="${DISK}1"
  fi

  # Handle nvme naming
  if [[ "$DISK" == *"nvme"* ]]; then
    if [ "$SWAP_TYPE" = "partition" ]; then
      SWAP_PART="${DISK}p1"
      ROOT_PART="${DISK}p2"
    else
      ROOT_PART="${DISK}p1"
    fi
  fi

  print_success "Partitions created"

  export ROOT_PART
  export SWAP_PART
}

manual_partition() {
  print_info "Opening cfdisk for manual partitioning..."
  print_warning "You must create:"

  if [ "$BOOT_MODE" = "UEFI" ]; then
    print_warning "  1. EFI System Partition (512MB+, type: EFI System)"
    print_warning "  2. Root partition (/, type: Linux filesystem)"
    print_warning "  3. Swap partition (optional, type: Linux swap)"
  else
    print_warning "  1. Root partition (/, type: Linux, bootable)"
    print_warning "  2. Swap partition (optional, type: Linux swap)"
  fi

  echo ""
  read -p "Press Enter to open cfdisk..."

  cfdisk "$DISK"

  # Let user specify partitions
  echo ""
  list_disks
  echo ""
  lsblk "$DISK"
  echo ""

  if [ "$BOOT_MODE" = "UEFI" ]; then
    read -p "Enter EFI partition (e.g., ${DISK}1): " efi_part
    EFI_PART="$efi_part"
  fi

  read -p "Enter root partition (e.g., ${DISK}2): " root_part
  ROOT_PART="$root_part"

  if [ "$SWAP_TYPE" = "partition" ]; then
    read -p "Enter swap partition (e.g., ${DISK}3): " swap_part
    SWAP_PART="$swap_part"
  fi

  export EFI_PART
  export ROOT_PART
  export SWAP_PART
}

format_partitions() {
  print_info "Formatting partitions..."

  # Format EFI partition (UEFI only)
  if [ "$BOOT_MODE" = "UEFI" ] && [ -n "$EFI_PART" ]; then
    print_info "Formatting EFI partition: $EFI_PART"
    mkfs.fat -F32 "$EFI_PART"
  fi

  # Format root partition
  print_info "Formatting root partition: $ROOT_PART ($ROOT_FS)"

  case "$ROOT_FS" in
  ext4)
    mkfs.ext4 -F "$ROOT_PART"
    ;;
  btrfs)
    mkfs.btrfs -f "$ROOT_PART"
    ;;
  xfs)
    mkfs.xfs -f "$ROOT_PART"
    ;;
  f2fs)
    mkfs.f2fs -f "$ROOT_PART"
    ;;
  esac

  # Format swap partition
  if [ "$SWAP_TYPE" = "partition" ] && [ -n "$SWAP_PART" ]; then
    print_info "Formatting swap partition: $SWAP_PART"
    mkswap "$SWAP_PART"
  fi

  print_success "Partitions formatted"
}

mount_partitions() {
  print_info "Mounting partitions..."

  # Mount root
  mount "$ROOT_PART" /mnt

  # Create and mount EFI partition (UEFI only)
  if [ "$BOOT_MODE" = "UEFI" ] && [ -n "$EFI_PART" ]; then
    mkdir -p /mnt/boot
    mount "$EFI_PART" /mnt/boot
  fi

  # Enable swap if partition
  if [ "$SWAP_TYPE" = "partition" ] && [ -n "$SWAP_PART" ]; then
    swapon "$SWAP_PART"
  fi

  print_success "Partitions mounted"
}

setup_zram() {
  print_info "Setting up zram swap..."

  # Install zram-generator
  arch-chroot /mnt pacman -S --noconfirm --needed zram-generator

  # Configure zram
  cat >/mnt/etc/systemd/zram-generator.conf <<EOF
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
EOF

  print_success "zram configured"
}

display_summary() {
  echo ""
  echo -e "${BLUE}═══════════════════════════════════════${NC}"
  echo -e "${BLUE}    Disk Configuration Summary${NC}"
  echo -e "${BLUE}═══════════════════════════════════════${NC}"
  echo -e "Disk:         ${GREEN}$DISK${NC}"
  echo -e "Mode:         ${GREEN}$PARTITION_MODE${NC}"
  if [ "$BOOT_MODE" = "UEFI" ]; then
    echo -e "EFI:          ${GREEN}$EFI_PART${NC}"
  fi
  echo -e "Root:         ${GREEN}$ROOT_PART${NC} ($ROOT_FS)"
  if [ "$SWAP_TYPE" = "partition" ]; then
    echo -e "Swap:         ${GREEN}$SWAP_PART${NC} (${SWAP_SIZE}GB)"
  elif [ "$SWAP_TYPE" = "file" ]; then
    echo -e "Swap:         ${GREEN}File${NC} (${SWAP_SIZE}GB)"
  elif [ "$SWAP_TYPE" = "zram" ]; then
    echo -e "Swap:         ${GREEN}zram${NC}"
  else
    echo -e "Swap:         ${YELLOW}None${NC}"
  fi
  echo -e "${BLUE}═══════════════════════════════════════${NC}"
  echo ""
}

main() {
  echo -e "${BLUE}"
  echo "╔═══════════════════════════════════════════╗"
  echo "║       Disk Setup and Partitioning         ║"
  echo "╚═══════════════════════════════════════════╝"
  echo -e "${NC}"

  # Check if BOOT_MODE is set
  if [ -z "$BOOT_MODE" ]; then
    print_error "BOOT_MODE not set"
    print_info "Please run 00-checks.sh first"
    return 1
  fi

  # Select disk
  select_disk

  # Select partitioning mode
  select_partitioning_mode

  # Select filesystem
  select_filesystem

  # Select swap
  select_swap

  # Display summary and confirm
  display_summary

  print_warning "This will DESTROY all data on $DISK"
  read -p "Proceed with disk setup? (y/N): " -n 1 -r
  echo

  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "Disk setup cancelled"
    return 1
  fi

  # Partition disk
  if [ "$PARTITION_MODE" = "auto" ]; then
    if [ "$BOOT_MODE" = "UEFI" ]; then
      auto_partition_uefi
    else
      auto_partition_bios
    fi
  else
    manual_partition
  fi

  # Format partitions
  format_partitions

  # Mount partitions
  mount_partitions

  # Setup zram if selected
  if [ "$SWAP_TYPE" = "zram" ]; then
    # Note: zram setup happens in finalize module after base install
    :
  fi

  print_success "Disk setup complete!"

  return 0
}

# Run if executed directly
if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
  main "$@"
fi
