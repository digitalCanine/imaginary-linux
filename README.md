# Imaginary Linux

**Version 1.0.0 (Shamshel)**

A transformative Arch-based system with guardian philosophy built-in.

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

## What is Imaginary Linux?

Imaginary Linux is not an ISO. It is a transformation.

This is an Arch-based system designed for **intermediate Linux users** who want:
- Intentional, guided system installation
- Security-conscious defaults
- Freedom of choice without hand-holding
- A system that respects your intelligence while offering care

**Philosophy:** Power should be usable without being reckless.

## Installation

### Prerequisites

- An Arch Linux ISO (any recent version)
- Internet connection
- Basic Linux knowledge
- 20GB+ disk space

### Installation Steps

1. **Boot from Arch ISO**

2. **Connect to the internet:**
   ```bash
   # For WiFi
   iwctl
   # Or
   nmtui
   ```

3. **Clone the repository:**
   ```bash
   git clone https://github.com/schizopup/imaginary-linux.git
   cd imaginary-linux
   ```

4. **Run the installer:**
   ```bash
   sudo ./install.sh
   ```

5. **Follow the guided installation**

The installer will walk you through:
- System checks and hardware detection
- Disk partitioning and formatting
- Base system installation
- Kernel selection (linux, linux-lts, linux-zen, linux-hardened)
- Bootloader configuration (GRUB/systemd-boot/libreboot)
- User account creation
- Desktop environment selection
- Driver installation
- Optional software installation
- System finalization

## Features

### What Makes It Different?

- **No ISO required** - Transform any Arch system
- **CLI-based installer** - Intentional, not automated
- **Multiple kernel options** - Choose what fits your needs
- **Desktop flexibility** - GNOME, KDE, XFCE, Cinnamon, BSPWM, i3, Hyprland
- **Custom branding** - Unique ASCII art and system identity
- **Imaginary repository** - Updates for Imaginary-specific tools
- **Guardian philosophy** - `imaginary-angel` tool (coming in future updates)

### Desktop Environments

**Full Desktop Environments:**
- GNOME - Modern, feature-rich
- KDE Plasma - Customizable and powerful
- XFCE - Lightweight and classic
- Cinnamon - Traditional desktop layout

**Window Managers:**
- BSPWM - Binary space partitioning (with optional custom rice)
- i3 - Tiling window manager
- Hyprland - Modern Wayland compositor

### Kernel Options

- **linux** - Default Arch kernel (recommended)
- **linux-lts** - Long term support, maximum stability
- **linux-zen** - Performance-optimized for desktop/gaming
- **linux-hardened** - Security-focused (may have compatibility issues)

## Post-Installation

After rebooting, your system will:
- Display the Imaginary Linux ASCII logo
- Run `fastfetch` automatically on terminal launch
- Have all selected software ready to use

### Imaginary Repository

The installer adds the Imaginary Linux repository for system-specific tools:

```ini
[imaginary]
SigLevel = Optional TrustAll
Server = https://github.com/schizopup/imaginary-repo/releases/download/$arch
```

This repository will contain:
- `imaginary-angel` - System guardian tool (coming soon)
- Future Imaginary-specific utilities

## The Guardian (Coming Soon)

**imaginary-angel** will be a post-install tool for:
- System integrity checking
- Security hardening
- Network traffic monitoring
- Configuration audit
- Systemd hardening assistance

The angel doesn't run unless you invoke it. It guides, it doesn't govern.

## Version Naming

Each version is named after an angel from Neon Genesis Evangelion:

- **1.0.0 (Shamshel)** - Current release. Focus: Protection and structure.
- Previous: 0.5.X (Sachiel) - Proof of concept

Future angels will bring new philosophical focuses and features.

## For Developers

### Repository Structure

```
imaginary-linux/
├── install.sh              # Main installer
├── modules/                # Installation modules
│   ├── 00-checks.sh
│   ├── 10-disk.sh
│   ├── 20-base.sh
│   ├── 30-kernel.sh
│   ├── 40-bootloader.sh
│   ├── 50-users.sh
│   ├── 60-desktop.sh
│   ├── 70-drivers.sh
│   ├── 80-packages.sh
│   └── 90-finalize.sh
├── profiles/               # Desktop environment profiles
│   ├── gnome/
│   ├── kde/
│   ├── xfce/
│   ├── cinnamon/
│   ├── bspwm/
│   ├── i3/
│   └── hyprland/
└── assets/                 # Branding assets
    ├── logo.txt
    └── logo-small.txt
```

### Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Test thoroughly in a VM
4. Submit a pull request

## Support

- **Issues:** https://github.com/schizopup/imaginary-linux/issues
- **Discussions:** https://github.com/schizopup/imaginary-linux/discussions

## Philosophy

Imaginary Linux is defined less by how it installs, and more by how it helps you live with the system afterward.

This is a system that:
- Assumes intelligence but still offers care
- Provides power without encouraging recklessness
- Protects through awareness, not restriction
- Treats security as guided awareness, not lockdown

**Imaginary Linux protects the user. The user protects the system.**

## License

The installer scripts and configurations are MIT licensed.
The Arch Linux base system retains its original licenses.

## Acknowledgments

- **Arch Linux** - The substrate and foundation
- **ArchTitus** - Inspiration for installer architecture
- **Neon Genesis Evangelion** - Naming and philosophical inspiration
- **The community** - For testing and feedback

---

**Imaginary Linux 1.0.0 (Shamshel)**  
*Power should be usable without being reckless.*
