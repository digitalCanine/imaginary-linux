# Imaginary Linux Installation Guide

**Version 1.1.17 (Shamshel)**

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

   **For WiFi:**

   ```bash
   # Start iwctl (interactive prompt)
   iwctl
   
   # Inside iwctl prompt:
   [iwd]# device list
   [iwd]# station wlan0 scan
   [iwd]# station wlan0 get-networks
   [iwd]# station wlan0 connect "YourNetworkName"
   # Enter password when prompted
   [iwd]# exit
   ```

   **For Ethernet:**

   Should auto-connect. If not:

   ```bash
   # Check connection status
   ip link
   
   # If interface is down
   ip link set eth0 up
   
   # Test DHCP
   dhcpcd
   ```

   **Verify connection:**

   ```bash
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

### Method 2: Quick Install (One-liner)

If you're comfortable with running remote scripts:

```bash
curl -sL https://raw.githubusercontent.com/digitalcanine/imaginary-linux/main/quick-install.sh | sudo bash
```

This automatically clones the repository and runs the installer.

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

- **Auto** - Wipe entire disk and auto-partition (recommended)
- **Manual** - Use cfdisk for custom partitioning

**Auto partitioning schemes:**

**UEFI System:**

```
/dev/sda1  512MB   FAT32   /boot (EFI System Partition)
/dev/sda2  [SWAP]  swap    swap (if swap partition selected)
/dev/sda3  Rest    ext4    / (root)
```

**BIOS System:**

```
/dev/sda1  [SWAP]  swap    swap (if swap partition selected)
/dev/sda2  Rest    ext4    / (root, bootable)
```

**Additional Disks:**

The installer supports mounting additional disks at custom locations:

- Separate /home partition
- Additional storage at /mnt/data, /mnt/storage, etc.

**Filesystem options:**

- **ext4** (stable, recommended for most users)
- **btrfs** (snapshots, compression, advanced features)
- **xfs** (high performance, large files)
- **f2fs** (optimized for SSDs/flash storage)

**Swap options:**

- **Swap file** (recommended, flexible size)
- **Swap partition** (traditional)
- **zram** (compressed RAM swap, good for limited RAM)
- **None** (not recommended for systems with <8GB RAM)

**Recommended swap sizes:**

- 4GB RAM or less: 2x RAM
- 4-8GB RAM: 1x RAM  
- 8GB+ RAM: 4-8GB or equal to RAM if you use hibernation

### 3. Hostname Configuration

**Hostname:**

- Choose a name for your computer
- Alphanumeric and hyphens only
- Must start and end with alphanumeric character

**Examples:**

- `imaginary-workstation`
- `my-laptop`
- `desktop-pc`

### 4. User Account Creation

**Username:**

- Lowercase letters, numbers, underscore, hyphen
- Must start with letter or underscore
- Cannot be a reserved system username (root, bin, daemon, etc.)

**Password:**

- Minimum 8 characters
- No complexity requirements enforced (but use a strong password!)
- Will be used for sudo access

**Root password:**

- Option to use same password as your user account
- Or set a different root password for extra security

**User groups:**

The user is automatically added to:

- `wheel` (sudo access)
- `audio` (audio devices)
- `video` (video devices)
- `optical` (optical drives)
- `storage` (removable media)

### 5. Kernel Selection

Choose your Linux kernel:

| Kernel | Best For | Features |
|--------|----------|----------|
| **linux** | General use | Default, well-tested, stable |
| **linux-lts** | Servers, stability | Long-term support, conservative |
| **linux-zen** | Desktops, gaming | Performance optimizations, low latency |
| **linux-hardened** | Security focus | Security patches, hardening |

**Recommendation:**

- Desktop/Gaming: `linux-zen`
- Servers/Workstations: `linux-lts`
- Security-focused: `linux-hardened`
- General use: `linux`

### 6. Bootloader Installation

**UEFI Systems:**

Choose between:

1. **systemd-boot** (recommended)
   - Simple, fast
   - Native UEFI bootloader
   - Easy to configure
   - Best for single-OS installs

2. **GRUB**
   - More features
   - Better dual-boot support
   - Theme customization
   - Works with older hardware

**BIOS Systems:**

- **GRUB** (only option for BIOS)

**Boot options:**

You can add custom kernel parameters such as:

- `quiet` - Hide boot messages
- `apparmor=1 security=apparmor` - Enable AppArmor
- `nvidia-drm.modeset=1` - Enable NVIDIA DRM
- `mitigations=off` - Disable CPU vulnerability mitigations (performance vs security)

### 7. Desktop Environment Selection

**Full Desktop Environments:**

| Choice | Description | RAM Usage | Best For |
|--------|-------------|-----------|----------|
| **GNOME** | Modern, polished interface | ~1.5GB | Touchpads, modern hardware, beginners |
| **KDE Plasma** | Feature-rich, highly customizable | ~800MB | Power users, customization enthusiasts |
| **XFCE** | Lightweight, traditional | ~500MB | Older hardware, resource efficiency |
| **Cinnamon** | Familiar Windows-like layout | ~700MB | Windows migrants, traditional desktop |

**Window Managers (Advanced):**

| Choice | Description | RAM Usage | Best For |
|--------|-------------|-----------|----------|
| **BSPWM** | Binary space tiling WM | ~200MB | Keyboard-driven workflow, custom rice option |
| **i3** | Popular tiling WM | ~150MB | Productivity, keyboard enthusiasts |
| **Hyprland** | Modern Wayland compositor | ~300MB | Latest Wayland features, animations |

**None (Server/Minimal):**

- CLI only, no desktop environment
- Perfect for servers or minimal setups
- You can always install a DE later

**Installation type:**

- **Minimal** - DE/WM + terminal + browser + essential tools
- **Full** - Minimal + file manager, office suite, media players, utilities

**BSPWM Rice Option:**

If you select BSPWM, you'll be offered the Imaginary BSPWM rice:

- Pre-configured keybindings
- Polybar status bar
- Custom color schemes
- Rofi application launcher
- Pre-configured terminal and tools
- Beautiful default setup

### 8. AUR Helper Selection

**What is an AUR helper?**

The Arch User Repository (AUR) contains community-maintained packages. An AUR helper makes installing these packages easier.

**Options:**

1. **paru** (recommended)
   - Modern, written in Rust
   - Fast and feature-rich
   - Good defaults

2. **yay**
   - Popular, well-established
   - Written in Go
   - Large community

3. **None**
   - Skip AUR helper
   - Install AUR packages manually
   - Can install one later

**Recommendation:** Choose `paru` unless you have a specific preference.

### 9. Hardware Driver Installation

**Automatically detected and installed:**

**CPU Microcode:**

- Intel: `intel-ucode`
- AMD: `amd-ucode`

**GPU Drivers:**

*NVIDIA:*

- Choice of `nvidia-open` (RTX 20 series+)
- Or `nvidia` (proprietary, older GPUs)
- Or `nouveau` (open source, basic features)

*AMD:*

- `mesa`, `xf86-video-amdgpu`, `vulkan-radeon`
- Full open-source support

*Intel:*

- `mesa`, `vulkan-intel`
- Open-source drivers

**Audio:**

- PipeWire audio system (modern, low-latency)
- Replaces PulseAudio and JACK

**Network:**

- NetworkManager (WiFi, Ethernet, VPN support)
- Enabled by default

**Optional:**

- **Bluetooth** - Installed if Bluetooth hardware detected
- **Printer support** - CUPS printing system (optional)
- **VM guest tools** - Automatically installed if running in VM
  - VirtualBox: `virtualbox-guest-utils`
  - VMware: `open-vm-tools`
  - QEMU/KVM: `qemu-guest-agent`

### 10. Additional Software Installation

**Installation Profiles:**

1. **Minimal Profile**
   - Firefox, git, vim, htop, fastfetch
   - Perfect for minimal setups

2. **Standard Profile**
   - Minimal packages
   - Plus: LibreOffice, VLC, GIMP, Discord
   - Good for general use

3. **Full Profile**
   - Standard packages
   - Plus: Gaming (Steam, Lutris, Wine)
   - Plus: Development (Docker, base-devel)
   - Plus: Additional utilities

4. **Custom Selection**
   - Pick individual packages

**Categories available:**

- Web browsers
- Text editors
- File managers  
- Media players
- Graphics software
- Communication apps
- Development tools
- Gaming platforms
- Productivity software
- System utilities

### 11. System Finalization

**Locale Configuration:**

- Default: `en_US.UTF-8`
- Option to add additional locales (es_ES, fr_FR, de_DE, etc.)
- Generates locale files

**Timezone:**

- Auto-detected from system
- Option to set custom timezone
- Examples: `America/New_York`, `Europe/London`, `Asia/Tokyo`
- Sets hardware clock

**Console Settings:**

- Virtual console keymap (default: `us`)
- Option to change to different keymap (uk, de, fr, dvorak, etc.)

**Optional Features:**

**Multilib Repository:**

- 32-bit library support
- Required for many games and Wine
- Recommended if gaming

**Package Manager Optimization:**

- Parallel downloads enabled (5 simultaneous)
- Color output enabled
- ILoveCandy easter egg (Pac-Man progress bar)

**Imaginary Linux Repository:**

- Adds custom package repository
- Provides `imaginary-release` and `imaginary-angel`
- Enables system branding and guardian features

**Firewall (UFW):**

- Enabled and configured by default
- Blocks incoming connections
- Allows outgoing connections
- SSH access allowed

**System Hardening (Advanced):**

Optional security hardening measures:

- **Kernel parameters:**
  - Restrict kernel log access
  - Restrict kernel pointer visibility
  - Enable full ASLR
  - Restrict ptrace scope
  - Disable core dumps

- **SSH hardening:**
  - Disable root login
  - Limit authentication attempts
  - Configure timeouts

- **File permissions:**
  - Secure critical system files
  - Restrict world-writable files
  - Proper umask settings

- **Systemd hardening:**
  - Secure coredump handling
  - DNSSEC and DNS over TLS
  - Service restrictions

- **AppArmor:**
  - Mandatory Access Control
  - Application confinement
  - Security profiles

**Recommendation:** Enable system hardening for security-focused systems, but understand it may cause compatibility issues with some software.

### 12. Installation Verification

Before completion, the installer verifies:

- ✓ fstab generated and valid
- ✓ User account created successfully
- ✓ Root password set and unlocked
- ✓ Bootloader installed correctly
- ✓ Kernel and initramfs present
- ✓ Essential services enabled

**Installation log saved to:** `/var/log/imaginary-install.log`

### 13. Completion

After installation:

1. Review any warnings or errors
2. Unmount partitions: `umount -R /mnt`
3. Reboot: `reboot`
4. Remove installation media
5. Boot into your new Imaginary Linux system!

---

## Post-Installation

### First Boot

1. **Boot screen** - See bootloader menu
2. **Login prompt** or **Display manager** (depending on desktop choice)
3. **Login** - Use the credentials you created
4. **Network** - Should auto-connect via NetworkManager

### Verify Installation

**Check system info:**

```bash
# Show system information
fastfetch

# Check OS release
cat /etc/os-release

# Verify kernel
uname -r
```

**Expected output:**

```
NAME="Imaginary Linux"
VERSION="1.1.17"
VERSION_CODENAME=shamshel
ID=imaginary
ID_LIKE=arch
```

### Initial Setup Tasks

**1. Update System:**

```bash
sudo pacman -Syu
```

**2. Configure NetworkManager (Desktop):**

If using a desktop environment, NetworkManager applet should be available. For CLI:

```bash
# List connections
nmcli device status

# Connect to WiFi
nmcli device wifi list
nmcli device wifi connect "SSID" password "password"

# Configure connection to auto-connect
nmcli connection modify "SSID" connection.autoconnect yes
```

**3. Install Additional Software:**

```bash
# Using pacman (official repos)
sudo pacman -S package-name

# Using AUR helper (if installed)
paru -S aur-package-name
# or
yay -S aur-package-name
```

**4. Setup Imaginary Angel:**

The system guardian should already be installed. Run it to configure:

```bash
imaginary-angel
```

Features:

- System health monitoring
- Security auditing
- Network threat detection
- Process analysis
- System integrity checks
- Automated repairs

### System Updates

**Keep everything current:**

```bash
# Update all packages
sudo pacman -Syu

# Update Imaginary packages specifically
sudo pacman -S imaginary-release imaginary-angel

# Apply new branding (if imaginary-release updated)
sudo imaginary-release
```

**Enable automatic updates (optional):**

The installer can enable daily automatic updates via systemd timer. Check status:

```bash
systemctl status update-system.timer
```

### Recommended First Steps

**1. Configure firewall (if running services):**

```bash
# Allow SSH (if needed)
sudo ufw allow ssh

# Allow HTTP/HTTPS (for web server)
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Check status
sudo ufw status
```

**2. Set up backups:**

For btrfs filesystems:

```bash
sudo pacman -S snapper
sudo snapper -c root create-config /
sudo snapper -c root create --description "Fresh install"
```

For traditional backup:

```bash
sudo pacman -S timeshift  # GUI backup tool
# or
sudo pacman -S rsync      # CLI backup
```

**3. Install essential tools:**

```bash
# Man pages
sudo pacman -S man-db man-pages

# Development tools
sudo pacman -S base-devel

# Compression tools
sudo pacman -S p7zip unrar unzip

# System monitoring
sudo pacman -S htop btop
```

**4. Configure shell (optional):**

```bash
# Install zsh and oh-my-zsh
sudo pacman -S zsh
chsh -s /usr/bin/zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

---

## Advanced Topics

### Dual Booting

**With Windows:**

1. Install Windows first (if not already installed)
2. Shrink Windows partition to make space:
   - Windows: Disk Management → Shrink Volume
   - Linux live environment: GParted or fdisk
3. Boot Imaginary Linux installer
4. Install to free space
5. GRUB will automatically detect Windows

**Boot order:**

- GRUB bootloader will show:
  - Imaginary Linux
  - Windows Boot Manager
  - Advanced options

**With another Linux distribution:**

- Both can share the EFI partition (UEFI systems)
- Use different root partitions
- GRUB will detect other Linux installations
- Later-installed distro usually takes over bootloader

### Btrfs Snapshots and Subvolumes

If you installed with btrfs:

**Install snapshot tools:**

```bash
sudo pacman -S snapper snap-pac
```

**Create configuration:**

```bash
# Create root config
sudo snapper -c root create-config /

# Create home config (if separate subvolume)
sudo snapper -c home create-config /home

# Set automatic snapshots
sudo systemctl enable --now snapper-timeline.timer
sudo systemctl enable --now snapper-cleanup.timer
```

**Manual snapshots:**

```bash
# Create snapshot
sudo snapper -c root create --description "Before system update"

# List snapshots
sudo snapper -c root list

# Compare snapshots
sudo snapper -c root status 1..2

# Restore from snapshot
sudo snapper -c root undochange 1..2
```

**Boot from snapshot:**

Install `grub-btrfs` to add snapshots to GRUB menu:

```bash
sudo pacman -S grub-btrfs
sudo systemctl enable --now grub-btrfsd
```

### Custom Partitioning

**Multiple drives example:**

```bash
# Root on SSD
/dev/nvme0n1p1  512MB  EFI
/dev/nvme0n1p2  60GB   / (root)

# Home on HDD
/dev/sda1       2TB    /home
```

**With separate partitions:**

```bash
/dev/sda1  512MB   /boot     (EFI)
/dev/sda2  60GB    /         (root)
/dev/sda3  40GB    /var      (logs, cache)
/dev/sda4  Rest    /home     (user data)
```

**Encrypted root:**

While not yet in the installer, you can manually set up LUKS:

```bash
# Encrypt partition
cryptsetup luksFormat /dev/sdaX

# Open encrypted partition
cryptsetup open /dev/sdaX cryptroot

# Format and use
mkfs.ext4 /dev/mapper/cryptroot
mount /dev/mapper/cryptroot /mnt
```

---

## Troubleshooting

### Installation Issues

**Cannot connect to internet:**

```bash
# Check network interface
ip link

# For WiFi, use iwctl
iwctl
[iwd]# device list
[iwd]# station wlan0 connect "SSID"

# For ethernet
ip link set eth0 up
dhcpcd eth0

# Test connectivity
ping -c 3 archlinux.org
```

**Git clone fails:**

```bash
# If git is not installed
pacman -Sy git

# If DNS issues
echo "nameserver 1.1.1.1" > /etc/resolv.conf
```

**Installer script fails to run:**

```bash
# Check if script is executable
ls -l installer/install.sh

# Make executable if needed
chmod +x installer/install.sh

# Check for syntax errors
bash -n installer/install.sh
```

**Disk partitioning errors:**

```bash
# Check if disk is in use
lsblk
fuser -mv /dev/sdX

# Unmount partitions
umount -R /mnt

# Clear partition table (WARNING: DESTROYS DATA)
wipefs -af /dev/sdX
```

### Boot Issues

**System won't boot - "No boot device":**

1. Check BIOS boot order
2. Disable Secure Boot
3. Verify bootloader was installed:

```bash
# Boot from USB again
# Mount partitions
mount /dev/sdaX /mnt
mount /dev/sdaY /mnt/boot  # if separate boot

# Reinstall bootloader
arch-chroot /mnt

# For systemd-boot
bootctl install

# For GRUB (UEFI)
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# For GRUB (BIOS)
grub-install --target=i386-pc /dev/sdX
grub-mkconfig -o /boot/grub/grub.cfg
```

**Kernel panic on boot:**

```bash
# Boot from USB
# Mount and chroot
mount /dev/sdaX /mnt
arch-chroot /mnt

# Regenerate initramfs
mkinitcpio -P

# Check for errors
journalctl -b
```

**Black screen after boot:**

```bash
# Ctrl+Alt+F2 to switch to TTY2
# Login with your username

# Check display manager status
systemctl status gdm       # or sddm, lightdm, ly
systemctl status display-manager

# Check Xorg log
cat /var/log/Xorg.0.log | grep EE

# For NVIDIA issues, try
sudo nvidia-xconfig
```

**Can't login - password not accepted:**

```bash
# Boot from USB
# Mount and chroot
mount /dev/sdaX /mnt
arch-chroot /mnt

# Reset password
passwd username

# Verify root password is set
passwd -S root

# If locked, unlock it
passwd -u root
```

### Post-Installation Issues

**No internet connection:**

```bash
# Check NetworkManager
systemctl status NetworkManager
sudo systemctl start NetworkManager
sudo systemctl enable NetworkManager

# Connect to WiFi
nmtui
# or
nmcli device wifi connect "SSID" password "password"
```

**Missing packages or broken dependencies:**

```bash
# Update package database
sudo pacman -Sy

# Reinstall package
sudo pacman -S package-name

# Fix broken dependencies
sudo pacman -Syu
sudo pacman -S $(pacman -Qqn)  # reinstall all packages
```

**Display issues (wrong resolution, tearing):**

```bash
# Install additional drivers
sudo pacman -S xf86-video-intel   # Intel
sudo pacman -S xf86-video-amdgpu  # AMD

# For NVIDIA tearing, edit /etc/X11/xorg.conf.d/20-nvidia.conf:
Section "Screen"
    Identifier "Screen0"
    Option "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
EndSection
```

**Audio not working:**

```bash
# Check PipeWire status
systemctl --user status pipewire pipewire-pulse wireplumber

# Start if not running
systemctl --user start pipewire pipewire-pulse wireplumber

# Select audio output
wpctl status
wpctl set-default <ID>
```

---

## Recovery and Rescue

### Boot into Rescue Mode

**From GRUB:**

1. Select "Advanced options"
2. Choose kernel with "fallback" initramfs
3. Or add `single` to kernel parameters

**From Arch ISO:**

```bash
# Mount root
mount /dev/sdaX /mnt

# Mount boot (if separate)
mount /dev/sdaY /mnt/boot

# Mount other partitions
mount /dev/sdaZ /mnt/home

# Chroot into system
arch-chroot /mnt

# Now you can:
# - Reset passwords
# - Reinstall bootloader
# - Fix packages
# - Edit configuration files
```

### System Recovery Commands

**Fix broken packages:**

```bash
arch-chroot /mnt
pacman -Syyu
pacman -S $(pacman -Qnq)  # reinstall all packages
```

**Regenerate initramfs:**

```bash
arch-chroot /mnt
mkinitcpio -P
```

**Reinstall bootloader:**

```bash
arch-chroot /mnt

# systemd-boot
bootctl install

# GRUB
grub-install /dev/sdX  # or with --target and --efi-directory
grub-mkconfig -o /boot/grub/grub.cfg
```

**Reset user password:**

```bash
arch-chroot /mnt
passwd username
```

---

## Getting Help

### Before Asking for Help

1. **Check error messages carefully** - They often tell you exactly what's wrong
2. **Search existing issues** - Someone may have had the same problem
3. **Check Arch Wiki** - Excellent resource for Arch-based systems
4. **Review installation log** - Located at `/var/log/imaginary-install.log`

### Reporting Issues

**Include the following information:**

- **Hardware specs:**
  - CPU model
  - RAM amount
  - GPU model
  - Disk type (SSD/HDD)
  - UEFI or BIOS

- **Installation choices:**
  - Desktop environment selected
  - Kernel version
  - Bootloader choice
  - Filesystem type

- **Error details:**
  - Full error message
  - What you expected to happen
  - What actually happened
  - Steps to reproduce

- **Logs:**

  ```bash
  # Installation log
  cat /var/log/imaginary-install.log
  
  # System journal
  journalctl -b -p err
  
  # Bootloader issues
  bootctl status  # for systemd-boot
  # or
  cat /boot/grub/grub.cfg  # for GRUB
  ```

### Resources

- **GitHub Issues:** [Report bugs and request features](https://github.com/digitalcanine/imaginary-linux/issues)
- **GitHub Discussions:** [Ask questions and discuss](https://github.com/digitalcanine/imaginary-linux/discussions)
- **Arch Wiki:** [Comprehensive Arch documentation](https://wiki.archlinux.org/)
- **Arch Forums:** [Community support](https://bbs.archlinux.org/)

---

## FAQ

**Q: Do I need to download a special ISO?**  
A: No! Use any standard Arch Linux ISO. Imaginary Linux is git-based—you clone the installer.

**Q: Can I install alongside Windows?**  
A: Yes. Install Windows first, shrink its partition, then install Imaginary Linux. GRUB will detect Windows.

**Q: How much disk space do I need?**  
A: Minimum 20GB. Recommended 40GB+ for comfortable use. Desktop environments vary:

- Minimal (i3/BSPWM): ~10GB
- Medium (XFCE): ~15GB  
- Full (GNOME/KDE): ~20GB+

**Q: Does it support Secure Boot?**  
A: Not yet. Disable Secure Boot in BIOS/UEFI settings before installation.

**Q: Can I switch desktop environments later?**  
A: Yes. Install additional DE/WM with pacman:

```bash
sudo pacman -S gnome  # or kde-plasma, xfce4, etc.
```

Then select at login screen.

**Q: Is this beginner-friendly?**  
A: It's designed for intermediate Linux users. Beginners can use it, but should:

- Be comfortable with command line
- Read documentation carefully
- Understand basic Linux concepts

**Q: How do I update Imaginary Linux?**  
A: It's a rolling release:

```bash
sudo pacman -Syu              # Update everything
sudo imaginary-release        # Update branding (if needed)
```

**Q: What if the installer breaks?**  
A: The git-based model means you always get the latest installer with fixes. If something breaks:

1. Report the issue on GitHub
2. Check for updates: `git pull`
3. The fix will be available immediately when committed

**Q: Can I see the code before running it?**  
A: Absolutely! That's one advantage of the git-based model:

```bash
# Review the installer
cat installer/install.sh
cat installer/modules/*.sh
```

**Q: Why git-based instead of ISO?**  
A:

- ✅ Always latest version (no outdated ISOs)
- ✅ Instant bug fixes
- ✅ Smaller download (~few MB vs 2GB ISO)
- ✅ Transparent (review code before running)
- ✅ Easy to contribute improvements

**Q: What's different from vanilla Arch?**  
A:

- Automated installation (no manual steps)
- Pre-configured security hardening
- imaginary-angel guardian system
- Custom branding
- Curated defaults
- But still pure Arch underneath!

**Q: Can I contribute?**  
A: Yes! Contributions welcome:

- Report bugs
- Suggest features
- Improve documentation
- Submit pull requests
- Share your setup

---

## Quick Reference

### Essential Commands

```bash
# System update
sudo pacman -Syu

# Install package
sudo pacman -S package-name

# Remove package
sudo pacman -R package-name

# Search for package
pacman -Ss search-term

# AUR (with helper)
paru -S aur-package
yay -S aur-package

# System info
fastfetch
neofetch
uname -a

# Disk usage
df -h
du -sh *

# Network
nmtui                    # TUI
nmcli device status      # CLI

# Services
systemctl status service-name
systemctl start service-name
systemctl enable service-name

# Logs
journalctl -b            # Current boot
journalctl -f            # Follow
journalctl -p err        # Errors only

# Guardian system
imaginary-angel          # Run system guardian
```

---

<div align="center">

**Ready to install?** Boot an Arch ISO and run:

```bash
git clone https://github.com/digitalcanine/imaginary-linux
```

---
