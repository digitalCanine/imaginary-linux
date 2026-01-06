# Imaginary Linux Installation Guide

**Version 1.1.6 (Shamshel)**

This guide will walk you through installing Imaginary Linux on your system.

---

## Prerequisites

### System Requirements

**Minimum:**

- 64-bit x86 processor
- 2GB RAM (4GB recommended)
- 20GB disk space (40GB+ recommended)
- Internet connection

**Recommended:**

- Modern CPU (Intel Core i3/AMD Ryzen 3 or better)
- 8GB+ RAM
- 60GB+ SSD
- Stable internet connection

### Before You Begin

1. **Backup your data** - Installation can erase data
2. **Check BIOS settings** - Disable Secure Boot (not yet supported)
3. **Verify boot mode** - UEFI or BIOS (installer auto-detects)
4. **Have network credentials ready** - WiFi password, etc.

---

## Installation Methods

### Method 1: Using Arch Linux ISO (Recommended)

1. **Download Arch ISO**
   - Get the latest from [archlinux.org](https://archlinux.org/download/)
   - Verify checksums

2. **Create bootable USB**

   ```bash
   # Linux
   dd if=archlinux.iso of=/dev/sdX bs=4M status=progress && sync
   
   # Windows - Use Rufus or balenaEtcher
   ```

3. **Boot from USB**
   - Enter BIOS/UEFI settings (usually F2, F12, or Del)
   - Select USB drive
   - Boot Arch Linux

4. **Connect to internet**

   ```bash
   # Start NetworkManager
   systemctl start NetworkManager
   
   # Connect to WiFi
   nmtui
   # Or for ethernet, it should auto-connect
   
   # Test connection
   ping -c 3 archlinux.org
   ```

5. **Clone Imaginary Linux**

   ```bash
   git clone https://github.com/digitalcanine/imaginary-linux.git
   cd imaginary-linux
   ```

6. **Run installer**

   ```bash
   sudo ./installer/install.sh
   ```

7. **Follow the prompts** - See [Installation Process](#installation-process) below

---

## Installation Process

The installer will guide you through these steps:

### 1. Pre-flight Checks

The installer automatically detects:

- ✓ Boot mode (UEFI/BIOS)
- ✓ CPU vendor (Intel/AMD)
- ✓ GPU vendor (NVIDIA/AMD/Intel)
- ✓ Available disks
- ✓ System memory
- ✓ Virtualization (if in a VM)

**No action required** - just verify the detected information is correct.

### 2. Disk Configuration

**Options:**

- **Auto** - Wipe entire disk and auto-partition
- **Manual** - Choose specific partitions
- **Advanced** - Preserve /home, custom fstab

**Partitioning schemes:**

**UEFI System:**

```
/dev/sda1  512MB   FAT32   /boot or /efi (EFI System Partition)
/dev/sda2  Rest    ext4    / (root)
```

**BIOS System:**

```
/dev/sda1  Rest    ext4    / (root)
```

**With separate /home:**

```
/dev/sda1  512MB   FAT32   /boot (UEFI only)
/dev/sda2  40GB    ext4    /
/dev/sda3  Rest    ext4    /home
```

**Encryption:**

- LUKS encryption available for root partition
- You'll set encryption password during setup

**Filesystem options:**

- ext4 (stable, recommended)
- btrfs (snapshots, advanced)

**Swap:**

- Swap file (recommended)
- Swap partition
- zram (memory compression)
- None

### 3. System Configuration

**Hostname:**

- Choose a name for your computer
- Alphanumeric and hyphens only

**Example:** `my-laptop`, `workstation`, `imaginary-pc`

### 4. User Account

**Username:**

- Lowercase letters, numbers, underscore, hyphen
- Must start with letter or underscore

**Password:**

- Minimum 8 characters
- No complexity requirements (but use a strong password!)

**Root password:**

- Option to use same as user password
- Or set a different root password

### 5. Bootloader Selection

**UEFI Systems:**

- **systemd-boot** (recommended) - Simple, fast
- **GRUB** - More features, dual-boot friendly

**BIOS Systems:**

- **GRUB** (only option)

**Kernel parameters:**

- Option to add custom parameters
- Examples: `apparmor=1 security=apparmor`, `quiet`

### 6. Desktop Environment

**Full Desktop Environments:**

| Choice | Description | Recommended For |
|--------|-------------|-----------------|
| **GNOME** | Modern, polished | Beginners, touchpads |
| **KDE Plasma** | Feature-rich, customizable | Power users |
| **XFCE** | Lightweight, traditional | Older hardware |
| **Cinnamon** | Familiar layout | Windows users |

**Window Managers:**

| Choice | Description | Recommended For |
|--------|-------------|-----------------|
| **BSPWM** | Tiling WM, custom rice available | Intermediate users |
| **i3** | Popular tiling WM | Keyboard enthusiasts |
| **Hyprland** | Modern Wayland compositor | Latest features |

**Installation type:**

- **Minimal** - Desktop + terminal + browser
- **Full** - Includes additional applications

**BSPWM Rice:**

- If BSPWM selected, option to install pre-configured rice
- Includes custom keybindings, polybar, themes, etc.

### 7. Package Manager

**AUR Helper:**

- **paru** (recommended) - Feature-rich, fast
- **yay** - Popular, well-established
- **None** - Skip AUR helper

### 8. Hardware Drivers

**Automatically installed:**

- CPU microcode (Intel/AMD)
- GPU drivers (NVIDIA/AMD/Intel)
- Audio drivers (PipeWire)
- Network drivers (NetworkManager)

**Optional:**

- Bluetooth support (if hardware detected)
- Printer support (CUPS)
- VM guest tools (if in virtual machine)

**NVIDIA driver options:**

- nvidia-open (RTX 20 series+, recommended)
- nvidia (proprietary, older GPUs)
- nouveau (open source, limited)

### 9. Additional Software

**Profiles:**

- **Minimal** - Firefox, git, vim, htop
- **Standard** - + office suite, media player, chat
- **Full** - + gaming, development tools
- **Custom** - Pick individual packages

**Package categories:**

- Web browsers
- Text editors
- File managers
- Media players
- Communication apps
- Development tools
- Gaming (Steam, Lutris)
- Productivity (LibreOffice)
- And more...

### 10. System Finalization

**Locale & Timezone:**

- Default: en_US.UTF-8, UTC
- Option to add additional locales
- Option to set custom timezone

**Optional features:**

- Multilib repository (32-bit support for gaming)
- Firewall (UFW, recommended)
- AppArmor (security framework)
- System hardening (advanced security)

**System hardening includes:**

- Kernel parameter hardening
- Restricted ptrace
- Core dump disabling
- SSH hardening
- Secure file permissions
- And more...

### 11. Verification & Completion

The installer verifies:

- ✓ fstab generated correctly
- ✓ User account created
- ✓ Root password set
- ✓ Bootloader installed
- ✓ Kernel and initramfs present

**Manual reboot:**

```bash
# Unmount partitions
umount -R /mnt

# Reboot
reboot
```

---

## Post-Installation

### First Boot

1. **Login screen** - Use credentials you created
2. **Network** - Should auto-connect (NetworkManager enabled)
3. **System info** - Run `fastfetch` to see your new system

### Initial Setup

**Update system:**

```bash
sudo pacman -Syu
```

**Install additional packages:**

```bash
# Using pacman
sudo pacman -S package-name

# Using AUR helper (if installed)
paru -S aur-package-name
```

**Customize:**

- Change wallpaper
- Adjust settings
- Install themes
- Configure applications

### Recommended First Steps

1. **Create recovery user**

   ```bash
   sudo useradd -m -G wheel recovery
   sudo passwd recovery
   ```

2. **Set up backups**
   - Use timeshift (btrfs snapshots)
   - Or rsync for regular backups

3. **Install essential tools**

   ```bash
   sudo pacman -S man-db man-pages
   ```

4. **Configure firewall rules** (if using servers)

   ```bash
   sudo ufw allow ssh
   sudo ufw enable
   ```

---

## Advanced Topics

### Dual Booting

**With Windows:**

1. Install Windows first
2. Shrink Windows partition to make space
3. Install Imaginary Linux on free space
4. GRUB will detect Windows automatically

**With another Linux:**

- Both can share EFI partition
- GRUB will detect other Linux installs
- Use different root partitions

### Encryption

**LUKS Setup:**

- Encrypts entire root partition
- Password required at boot
- Protects data if drive is stolen

**Performance impact:**

- Modern CPUs: negligible (<5%)
- Older systems: may notice slight slowdown

### Btrfs Snapshots

If you chose btrfs:

**Install snapper:**

```bash
sudo pacman -S snapper
sudo snapper -c root create-config /
```

**Create snapshots:**

```bash
sudo snapper -c root create --description "Before update"
```

**Restore snapshot:**

```bash
sudo snapper -c root undochange 1..2
```

### Custom Partitions

**Multiple drives:**

- Install root on SSD
- Mount HDD as /home or /data

**Example fstab:**

```
UUID=xxx  /       ext4  defaults  0 1
UUID=yyy  /home   ext4  defaults  0 2
UUID=zzz  /data   ext4  defaults  0 2
```

---

## Troubleshooting

### Installation Issues

**"No internet connection"**

- Check network cable
- Reconnect to WiFi with `nmtui`
- Verify with `ping archlinux.org`

**"Failed to mount partition"**

- Partition might be in use
- Unmount: `umount /dev/sdXY`
- Check filesystem: `fsck /dev/sdXY`

**"Bootloader installation failed"**

- Verify EFI partition mounted (UEFI)
- Check disk has space
- Try alternative bootloader

### Boot Issues

**"No boot device found"**

- Check BIOS boot order
- Disable Secure Boot
- Reinstall bootloader from live USB

**"Kernel panic"**

- Boot from USB
- Chroot and regenerate initramfs:

  ```bash
  arch-chroot /mnt
  mkinitcpio -P
  ```

**"Can't login"**

- Boot from USB
- Reset password:

  ```bash
  arch-chroot /mnt
  passwd username
  ```

### Common Issues

See [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for detailed solutions.

---

## Getting Help

**Before asking for help:**

1. Check error messages carefully
2. Search existing issues on GitHub
3. Review documentation

**When reporting issues:**

- Describe what you expected
- Describe what actually happened
- Include error messages
- Mention your hardware
- State which options you selected

**Resources:**

- [GitHub Issues](https://github.com/yourusername/imaginary-linux/issues)
- [GitHub Discussions](https://github.com/yourusername/imaginary-linux/discussions)
- [Arch Wiki](https://wiki.archlinux.org/) - Excellent resource

---

## FAQ

**Q: Can I install alongside Windows?**  
A: Yes, install Windows first, then Imaginary Linux. GRUB will detect Windows.

**Q: How much disk space do I need?**  
A: Minimum 20GB, recommended 40GB+. Desktop environments vary in size.

**Q: Does it support Secure Boot?**  
A: Not yet. Disable Secure Boot in BIOS.

**Q: Can I switch desktop environments later?**  
A: Yes, install additional DE/WM with pacman and select at login.

**Q: Is this beginner-friendly?**  
A: It's designed for intermediate users familiar with Linux. Beginners can use it but should read documentation.

**Q: How do I update?**  
A: `sudo pacman -Syu` - rolling release model, always latest packages.

**Q: Can I contribute?**  
A: Absolutely! See [CONTRIBUTING.md](docs/CONTRIBUTING.md).

---

<div align="center">

**Need more help?** Check out the [full documentation](docs/) or open an [issue](https://github.com/yourusername/imaginary-linux/issues).

</div>
