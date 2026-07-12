# Imaginary Linux

```
   ████▓▓▒▒      ▒▒▓▓████
  ████▓▓▓▒▒      ▒▒▓▓▓████
 ████▓▓▓▓▒▒      ▒▒▓▓▓▓████
████▓▓▓▓▒▒   ██   ▒▒▓▓▓▓████
███▓▓▓▒▒     ██     ▒▒▓▓▓███
██▓▓▒▒       ██       ▒▒▓▓██
█▓▒          ██          ▒▓█
▒                          ▒
       IMAGINARY LINUX
```

`The system stands, quietly.`

**Version 1.1.17 (Shamshel)**  
*A git-based, security-focused Arch Linux distribution*

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Arch Linux](https://img.shields.io/badge/Based%20on-Arch%20Linux-1793D1?logo=arch-linux)](https://archlinux.org/)
[![Version](https://img.shields.io/badge/version-1.1.17-blue)](https://github.com/digitalcanine/imaginary-linux/releases)

---

## About

Imaginary Linux is an unconventional, git-based Arch distribution with a guardian philosophy. Unlike traditional distributions that release outdated ISOs, Imaginary Linux is always current, simply clone and install.

### Why Git-Based?

**Traditional distros:** Download 2GB ISO → ISO is outdated the moment it's released → Install old system → Update everything anyway

**Imaginary Linux:** Boot any Arch ISO → `git clone` latest installer (seconds) → Install current system → Start secured

### Why Imaginary?

- **Security First** - Hardened kernel options, AppArmor support, firewall enabled by default
- **Always Current** - Git-based delivery means you always get the latest installer
- **Customizable** - Choose from 7 desktop environments/window managers
- **Transparent** - Review all code before installation
- **Arch-Based** - Rolling release, access to AUR, pacman package manager
- **Guardian System** - Includes imaginary-angel for ongoing system monitoring and protection

### What Makes This a Distribution?

| Traditional Distro | Imaginary Linux |
|-------------------|-----------------|
| ❌ Outdated ISO releases | ✅ Always-current git installer |
| ❌ GB of bandwidth per download | ✅ Lightweight clone (~few MB) |
| ❌ Fixed at release time | ✅ Hotfixes applied immediately |
| ✅ Custom branding | ✅ Custom branding (`/etc/os-release`) |
| ✅ Package repository | ✅ Package repository (GitHub releases) |
| ✅ Unique packages | ✅ imaginary-release, imaginary-angel |
| ✅ Post-install support | ✅ imaginary-angel guardian system |

### Screenshots

<div align="center">

**Installer**  
![Installer](./assets/screenshots/installer.png)

**Terminal**  
![Terminal](./assets/screenshots/terminal.png)

</div>

---

## Features

### Installation

- **Git-based installer** - Always get the latest version
- **Automated CLI installer** - No manual partitioning or configuration needed
- **Multiple desktop environments** - GNOME, KDE, XFCE, Cinnamon, BSPWM, i3, Hyprland
- **Custom BSPWM rice** - Pre-configured beautiful setup for BSPWM users
- **Dual boot aware** - Detects other operating systems

### Security

- **Hardened kernel options** - Security-focused kernel parameters
- **AppArmor support** - Mandatory Access Control framework
- **UFW firewall** - Enabled and configured by default
- **System hardening** - Optional security hardening during installation
- **Minimal attack surface** - Only essential packages installed
- **Guardian philosophy** - imaginary-angel provides ongoing system protection

### Desktop Environments

| Environment | Type | Description |
|------------|------|-------------|
| **GNOME** | Full DE | Modern, feature-rich desktop |
| **KDE Plasma** | Full DE | Highly customizable, powerful |
| **XFCE** | Full DE | Lightweight, classic experience |
| **Cinnamon** | Full DE | Traditional desktop layout |
| **BSPWM** | WM | Tiling window manager with custom rice |
| **i3** | WM | Popular tiling window manager |
| **Hyprland** | WM | Modern Wayland compositor |

### Package Management

- **pacman** - Fast, efficient package manager
- **AUR support** - Choose between paru or yay
- **Custom repository** - imaginary-release and imaginary-angel packages
- **Minimal base** - Install only what you need

---

## Quick Start

### Prerequisites

- Any Arch Linux ISO (or any Arch-based live environment)
- Internet connection
- Target system (physical or virtual machine)

### Installation (The Imaginary Way)

1. **Boot from any Arch Linux ISO**
   - Download from [archlinux.org](https://archlinux.org/download/)
   - Boot into live environment

2. **Connect to the internet:**

   ```bash
   WiFi (using iwctl)
   iwctl
   # Inside iwctl:
   # device list
   # station wlan0 scan
   # station wlan0 get-networks
   # station wlan0 connect "SSID"
   # exit
   
   # Ethernet usually auto-connects
   
   # Verify connection
   ping -c 3 archlinux.org   
   ```

3. **Clone and install:**

   ```bash
   # Clone the repository (always latest)
   git clone https://github.com/digitalcanine/imaginary-linux.git
   cd imaginary-linux/installer
   
   # Run the installer
   sudo ./install.sh
   ```

4. **Follow the prompts** - The installer guides you through everything

5. **Reboot into your new Imaginary Linux system**

### Alternative: Quick Install

For those who prefer a one-liner:

```bash
curl -sL https://raw.githubusercontent.com/digitalcanine/imaginary-linux/main/quick-install.sh | sudo bash
```

See [INSTALL.md](./docs/INSTALL.md) for detailed installation instructions.

---

## What's Included

### Base System

- Linux kernel (choice of standard, LTS, zen, or hardened)
- Base-devel tools
- NetworkManager
- Git, vim, fastfetch
- Auto-detected hardware drivers (GPU, audio, network)
- **imaginary-release** - System branding package
- **imaginary-angel** - System guardian and monitoring tool

### Desktop Profiles

**Minimal Installation:**

- Desktop environment/window manager
- Terminal emulator (kitty)
- Web browser (Firefox)
- Essential utilities

**Full Installation:**

- Everything in Minimal
- File manager
- Archive tools
- System utilities
- Multimedia support

### Optional Packages

Choose from curated categories:

- Web browsers (Firefox, Chromium, Brave, LibreWolf)
- Editors (Neovim, VS Code, VSCodium)
- Communication (Discord, Telegram, Signal)
- Development tools (Docker, Git, GitHub CLI)
- Gaming (Steam, Lutris, Wine)
- And more...

---

## Guardian System: Imaginary Angel

Imaginary Linux includes **Imaginary Angel**, a comprehensive system guardian tool that provides:

### Core Features

- **System Health Monitoring**: Real-time CPU, memory, and disk monitoring with auto-repair capabilities
- **Security Auditing**: SSH hardening, firewall management, privilege checks, and vulnerability scanning
- **Network Protection**: Threat detection, DDoS prevention, port scan detection, and connection monitoring
- **Process Management**: Suspicious process detection, zombie cleanup, and resource analysis
- **System Integrity**: Package verification, file integrity checks, and configuration monitoring
- **Smart Automation**: Configurable auto-fix mode for hands-free maintenance

### Usage

```bash
# Run the guardian system
imaginary-angel

# Or use it directly after installation
sudo pacman -S imaginary-angel  # If not already installed
imaginary-angel
```

The guardian philosophy means your system isn't just installed—it's protected and monitored throughout its lifetime.

---

## Advanced Features

### System Hardening

Optional security hardening includes:

- Kernel parameter hardening (dmesg_restrict, kptr_restrict, ASLR)
- Restricted ptrace access
- Core dump disabling
- Secure umask (077)
- SSH hardening
- Systemd security settings
- Automatic security updates (optional)

### Bootloader Options

- **systemd-boot** (UEFI, recommended)
- **GRUB** (UEFI and BIOS)

### Partition Schemes

- Multiple filesystem support (ext4, btrfs, xfs, f2fs)
- Btrfs with snapshots capability
- Flexible swap options (file, partition, or zram)
- Support for additional disks with custom mount points

---

## Version History & Roadmap

### Current: Version 1.1.17 (Shamshel)

- Git-based installer delivery
- Automated CLI installation
- 7 desktop environment options
- Security hardening features
- UEFI and BIOS support
- imaginary-angel system guardian
- Custom package repository

### Roadmap to 2.X.X (Ramiel)

Planned features for the next major release:

- [ ] Custom hardened kernel package
- [ ] imaginary-angel 2.0 with enhanced features
- [ ] Advanced security hardening options
- [ ] Expanded angelic theming
- [ ] LUKS encryption during installation
- [ ] Minimal ISO with git-based updater

### Version History

- **0.5.6 (Sachiel)** - First prototype
- **1.0.0 (Shamshel)** - Initial public release
- **1.1.X (Shamshel)** - Current stable series (git-based installer)
- **2.X.X (Ramiel)** - Future major release (planned)

---

## Keeping Up to Date

### System Updates

```bash
# Update all packages
sudo pacman -Syu

# Update imaginary packages
sudo pacman -S imaginary-release imaginary-angel

# Apply new branding (if imaginary-release updated)
sudo imaginary-release
```

### Installer Updates

The beauty of git-based distribution: **you always get the latest installer**.

Every time someone clones the repository, they get:

- Latest bug fixes
- Newest features
- Security patches
- Updated configurations

No need to wait for ISO releases!

---

## Contributing

Contributions are welcome! Whether it's:

- Bug reports
- Feature requests
- Code improvements
- Documentation
- New desktop environment profiles
- Security enhancements

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

---

## License

Imaginary Linux is released under the MIT License. See [LICENSE](LICENSE) for details.

The installer scripts and configurations are MIT licensed.  
The Linux kernel and included packages retain their original licenses.

---

## Credits

- **Arch Linux** - The foundation of this distribution
- **Chris Titus Tech** - Inspiration for automated installer concepts
- **Evangelion** - Angel naming scheme and philosophical inspiration
- All the open source projects that make this possible
- The Arch community for excellent documentation

---

## Support & Community

- **Issues:** [GitHub Issues](https://github.com/digitalcanine/imaginary-linux/issues)
- **Discussions:** [GitHub Discussions](https://github.com/digitalcanine/imaginary-linux/discussions)
- **Documentation:** [Installation Guide](INSTALL.md) | [Wiki](https://github.com/digitalcanine/imaginary-linux/wiki)

---

## Disclaimer

Imaginary Linux is provided as-is without warranty. This is a community project created for enthusiasts who appreciate:

- Transparency (git-based, reviewable code)
- Security (hardened by default)
- Simplicity (Arch philosophy)
- Philosophy (guardian protection)

**Always backup your data before installation.**

---

## Why Choose Imaginary?

**Choose Imaginary Linux if you:**

- ✅ Want security-focused Arch without manual installation
- ✅ Prefer always-current installers over outdated ISOs
- ✅ Like to review code before running it
- ✅ Appreciate the guardian philosophy
- ✅ Want ongoing system protection (imaginary-angel)
- ✅ Value transparency and open source

**Stick with other distros if you:**

- ❌ Need commercial support contracts
- ❌ Want graphical installers only
- ❌ Prefer stable (non-rolling) releases
- ❌ Need Secure Boot support (not yet implemented)

