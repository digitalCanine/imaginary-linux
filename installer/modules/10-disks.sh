#!/bin/bash
# Module 10: Disk Partitioning and Setup (SAFE / REUSE AWARE)
# Supports fresh installs AND reinstall without data loss

# ================= COLORS =================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m'

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[✓]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
print_error() { echo -e "${RED}[✗]${NC} $1"; }

# ================= STATE =================
declare -a ADDITIONAL_PARTS
declare -a ADDITIONAL_MOUNTS
declare -a ADDITIONAL_FORMAT

# ================= DISK SELECTION =================
list_disks() {
  lsblk -ndo NAME,SIZE,TYPE,MODEL | grep disk
}

select_disk() {
  while true; do
    echo ""
    print_info "Available disks:"
    list_disks
    echo ""

    read -p "Install target disk (e.g. sda, nvme0n1): " d
    DISK="/dev/$d"

    [ ! -b "$DISK" ] && print_error "Disk not found" && continue

    lsblk "$DISK"
    read -p "Use this disk? (y/N): " -n1 r
    echo
    [[ $r =~ [Yy] ]] && break
  done

  export DISK
}

# ================= PARTITION MODE =================
select_partitioning_mode() {
  echo ""
  echo "Partitioning mode:"
  echo "1) Automatic (creates partitions)"
  echo "2) Manual (reuse existing partitions)"
  echo ""

  read -p "Select [1-2]: " c
  case $c in
  1) PARTITION_MODE=auto ;;
  2) PARTITION_MODE=manual ;;
  *)
    print_error "Invalid choice"
    select_partitioning_mode
    ;;
  esac

  export PARTITION_MODE
}

# ================= FORMAT MODE =================
select_partition_handling() {
  echo ""
  echo "Partition handling:"
  echo "1) Format partitions (fresh install)"
  echo "2) Reuse existing partitions (KEEP DATA)"
  echo ""

  read -p "Select [1-2]: " c
  case $c in
  1) FORMAT_PARTITIONS=true ;;
  2) FORMAT_PARTITIONS=false ;;
  *)
    print_error "Invalid choice"
    select_partition_handling
    ;;
  esac

  export FORMAT_PARTITIONS
}

# ================= FILESYSTEM =================
select_filesystem() {
  echo ""
  echo "Root filesystem:"
  echo "1) ext4"
  echo "2) btrfs"
  echo "3) xfs"
  echo ""

  read -p "Select [1-3]: " c
  case $c in
  1) ROOT_FS=ext4 ;;
  2) ROOT_FS=btrfs ;;
  3) ROOT_FS=xfs ;;
  *)
    print_error "Invalid choice"
    select_filesystem
    ;;
  esac

  export ROOT_FS
}

# ================= MANUAL PARTITIONS =================
manual_partition() {
  print_info "Manual partition selection"
  lsblk "$DISK"

  if [ "$BOOT_MODE" = "UEFI" ]; then
    read -p "EFI partition (e.g. /dev/nvme0n1p1): " EFI_PART
  fi

  read -p "Root partition ( / ): " ROOT_PART

  read -p "Reuse existing /home? (y/N): " -n1 r
  echo
  if [[ $r =~ [Yy] ]]; then
    read -p "Home partition: " HOME_PART
  fi

  export EFI_PART ROOT_PART HOME_PART
}

# ================= AUTO PARTITION =================
auto_partition_uefi() {
  print_warning "Disk WILL be wiped"
  wipefs -af "$DISK"
  sgdisk -Z "$DISK"
  parted -s "$DISK" mklabel gpt
  parted -s "$DISK" mkpart ESP fat32 1MiB 513MiB
  parted -s "$DISK" set 1 esp on
  parted -s "$DISK" mkpart primary 513MiB 100%

  if [[ "$DISK" =~ nvme|mmcblk ]]; then
    EFI_PART="${DISK}p1"
    ROOT_PART="${DISK}p2"
  else
    EFI_PART="${DISK}1"
    ROOT_PART="${DISK}2"
  fi

  export EFI_PART ROOT_PART
}

# ================= FORMAT =================
format_partitions() {
  [ "$FORMAT_PARTITIONS" = false ] && {
    print_info "Skipping formatting"
    return
  }

  print_warning "Formatting root partition"
  case "$ROOT_FS" in
  ext4) mkfs.ext4 -F "$ROOT_PART" ;;
  btrfs) mkfs.btrfs -f "$ROOT_PART" ;;
  xfs) mkfs.xfs -f "$ROOT_PART" ;;
  esac

  if [ "$BOOT_MODE" = "UEFI" ]; then
    print_warning "Formatting EFI partition"
    mkfs.fat -F32 "$EFI_PART"
  fi
}

# ================= MOUNT =================
mount_partitions() {
  mount "$ROOT_PART" /mnt

  if [ "$BOOT_MODE" = "UEFI" ]; then
    mkdir -p /mnt/boot
    mount "$EFI_PART" /mnt/boot
  fi

  if [ -n "$HOME_PART" ]; then
    mkdir -p /mnt/home
    mount "$HOME_PART" /mnt/home
  fi

  print_success "Partitions mounted"
}

# ================= MAIN =================
main() {
  echo -e "${BLUE}"
  echo "╔══════════════════════════════════════╗"
  echo "║      Disk Setup (SAFE MODE)          ║"
  echo "╚══════════════════════════════════════╝"
  echo -e "${NC}"

  [ -z "$BOOT_MODE" ] && {
    print_error "BOOT_MODE not set"
    return 1
  }

  select_disk
  select_partitioning_mode
  select_filesystem
  select_partition_handling

  if [ "$PARTITION_MODE" = auto ]; then
    [ "$FORMAT_PARTITIONS" = false ] && {
      print_error "Auto mode requires formatting"
      return 1
    }
    auto_partition_uefi
  else
    manual_partition
  fi

  format_partitions
  mount_partitions

  print_success "Disk setup complete"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main
fi
