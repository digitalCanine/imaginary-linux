#!/bin/bash
# Module 50: User Account Creation
# Creates user account and sets passwords

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

get_hostname() {
  echo ""
  print_info "Enter hostname for this system"
  print_info "This is the name that will identify your computer on networks"

  while true; do
    read -p "Hostname: " HOSTNAME

    # Validate hostname
    if [ -z "$HOSTNAME" ]; then
      print_error "Hostname cannot be empty"
      continue
    fi

    # Check if hostname is valid (alphanumeric and hyphens only)
    if [[ ! "$HOSTNAME" =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?$ ]]; then
      print_error "Invalid hostname. Use only letters, numbers, and hyphens"
      print_info "Hostname must start and end with a letter or number"
      continue
    fi

    # Confirm hostname
    echo ""
    echo "Hostname will be: $HOSTNAME"
    read -p "Is this correct? (Y/n): " -n 1 -r
    echo

    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
      export HOSTNAME
      break
    fi
  done

  print_success "Hostname set to: $HOSTNAME"
}

get_username() {
  echo ""
  print_info "Enter username for your account"
  print_info "This will be your primary user account with sudo privileges"

  while true; do
    read -p "Username: " USERNAME

    # Validate username
    if [ -z "$USERNAME" ]; then
      print_error "Username cannot be empty"
      continue
    fi

    # Check if username is valid (lowercase alphanumeric and underscore)
    if [[ ! "$USERNAME" =~ ^[a-z_]([a-z0-9_-]{0,31}|[a-z0-9_-]{0,30}\$)$ ]]; then
      print_error "Invalid username"
      print_info "Username must:"
      print_info "  - Start with a lowercase letter or underscore"
      print_info "  - Contain only lowercase letters, numbers, hyphens, and underscores"
      print_info "  - Be 32 characters or less"
      continue
    fi

    # Check for reserved usernames
    local reserved=("root" "bin" "daemon" "sys" "sync" "games" "man" "lp" "mail" "news" "uucp" "proxy" "www-data" "backup" "list" "irc" "nobody")
    if [[ " ${reserved[@]} " =~ " ${USERNAME} " ]]; then
      print_error "Username '$USERNAME' is reserved by the system"
      continue
    fi

    # Confirm username
    echo ""
    echo "Username will be: $USERNAME"
    read -p "Is this correct? (Y/n): " -n 1 -r
    echo

    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
      export USERNAME
      break
    fi
  done

  print_success "Username set to: $USERNAME"
}

get_user_password() {
  echo ""
  print_info "Set password for user: $USERNAME"
  print_info "Password must be at least 8 characters"

  while true; do
    read -s -p "Enter password: " PASSWORD
    echo

    # Check password length
    if [ ${#PASSWORD} -lt 8 ]; then
      print_error "Password must be at least 8 characters"
      continue
    fi

    read -s -p "Confirm password: " PASSWORD_CONFIRM
    echo

    if [ "$PASSWORD" != "$PASSWORD_CONFIRM" ]; then
      print_error "Passwords do not match"
      continue
    fi

    export USER_PASSWORD="$PASSWORD"
    break
  done

  print_success "User password set"
}

get_root_password() {
  echo ""
  print_info "Set root password"
  print_info "This is the system administrator password"

  while true; do
    read -p "Use same password as user account? (Y/n): " -n 1 -r
    echo

    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
      export ROOT_PASSWORD="$USER_PASSWORD"
      print_success "Root password set (same as user)"
      break
    else
      print_info "Enter root password (must be at least 8 characters)"

      while true; do
        read -s -p "Enter root password: " ROOT_PASSWORD
        echo

        if [ ${#ROOT_PASSWORD} -lt 8 ]; then
          print_error "Password must be at least 8 characters"
          continue
        fi

        read -s -p "Confirm root password: " ROOT_PASSWORD_CONFIRM
        echo

        if [ "$ROOT_PASSWORD" != "$ROOT_PASSWORD_CONFIRM" ]; then
          print_error "Passwords do not match"
          continue
        fi

        export ROOT_PASSWORD
        print_success "Root password set"
        break
      done
      break
    fi
  done
}

configure_hostname() {
  print_info "Configuring hostname..."

  # Set hostname
  echo "$HOSTNAME" >/mnt/etc/hostname

  # Configure hosts file
  cat >/mnt/etc/hosts <<EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   ${HOSTNAME}.localdomain ${HOSTNAME}
EOF

  print_success "Hostname configured"
}

create_user() {
  print_info "Creating user account: $USERNAME"

  # Create user with home directory
  arch-chroot /mnt useradd -m -G wheel,audio,video,optical,storage -s /bin/bash "$USERNAME"

  if [ $? -ne 0 ]; then
    print_error "Failed to create user account"
    return 1
  fi

  # Set user password
  echo "$USERNAME:$USER_PASSWORD" | arch-chroot /mnt chpasswd

  if [ $? -ne 0 ]; then
    print_error "Failed to set user password"
    return 1
  fi

  print_success "User account created: $USERNAME"
}

set_root_password() {
  print_info "Setting root password..."

  echo "root:$ROOT_PASSWORD" | arch-chroot /mnt chpasswd

  if [ $? -ne 0 ]; then
    print_error "Failed to set root password"
    return 1
  fi

  # Ensure root account is unlocked
  arch-chroot /mnt passwd -u root

  # Verify root password is set and unlocked
  local root_status=$(arch-chroot /mnt passwd --status root | awk '{print $2}')
  if [ "$root_status" = "P" ]; then
    print_success "Root password set and account unlocked"
  else
    print_error "Root account status: $root_status (should be P)"
    print_warning "Attempting to unlock root account..."
    arch-chroot /mnt passwd -u root
  fi
}

configure_sudo() {
  print_info "Configuring sudo access..."

  # Enable wheel group for sudo
  arch-chroot /mnt sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

  # Add sudo timeout (password cache for 15 minutes)
  echo "Defaults timestamp_timeout=15" | arch-chroot /mnt tee -a /etc/sudoers.d/timeout >/dev/null

  # Set proper permissions
  arch-chroot /mnt chmod 440 /etc/sudoers.d/timeout

  print_success "Sudo configured for wheel group"
}

display_summary() {
  echo ""
  echo -e "${BLUE}═══════════════════════════════════════${NC}"
  echo -e "${BLUE}    User Configuration Summary${NC}"
  echo -e "${BLUE}═══════════════════════════════════════${NC}"
  echo -e "Hostname: ${GREEN}$HOSTNAME${NC}"
  echo -e "Username: ${GREEN}$USERNAME${NC}"
  echo -e "Groups:   wheel, audio, video, optical, storage"
  echo -e "Shell:    /bin/bash"
  echo -e "Sudo:     Enabled"
  echo -e "${BLUE}═══════════════════════════════════════${NC}"
  echo ""
}

main() {
  echo -e "${BLUE}"
  echo "╔═══════════════════════════════════════════╗"
  echo "║       User Account Configuration          ║"
  echo "╚═══════════════════════════════════════════╝"
  echo -e "${NC}"

  # Get user input
  get_hostname
  get_username
  get_user_password
  get_root_password

  # Display summary and confirm
  display_summary

  read -p "Create user with these settings? (Y/n): " -n 1 -r
  echo

  if [[ $REPLY =~ ^[Nn]$ ]]; then
    print_info "User creation cancelled"
    return 1
  fi

  # Apply configuration
  configure_hostname
  create_user
  set_root_password
  configure_sudo

  print_success "User configuration complete!"

  # Save configuration for other modules
  export USER_HOME="/home/$USERNAME"

  return 0
}

# Run if executed directly
if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
  main "$@"
fi
