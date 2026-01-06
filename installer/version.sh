#!/usr/bin/env bash
set -euo pipefail

# ----------------------------------------
# Imaginary Linux – Version Bump Tool
# ----------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALLER_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
INSTALL_SH="$INSTALLER_ROOT/installer/install.sh"

VERSION=""
CODENAME=""

# ----------------------------------------
# Argument parsing
# ----------------------------------------

while [[ $# -gt 0 ]]; do
  case "$1" in
  --version)
    VERSION="${2:-}"
    shift 2
    ;;
  --code | --codename)
    CODENAME="${2:-}"
    shift 2
    ;;
  -h | --help)
    echo "Usage: ./version.sh --version X.Y.Z --code CODENAME"
    exit 0
    ;;
  *)
    echo "✗ Unknown argument: $1"
    exit 1
    ;;
  esac
done

# ----------------------------------------
# Validation
# ----------------------------------------

if [[ -z "$VERSION" || -z "$CODENAME" ]]; then
  echo "✗ Missing required arguments"
  echo "Usage: ./version.sh --version X.Y.Z --code CODENAME"
  exit 1
fi

if [[ ! -f "$INSTALL_SH" ]]; then
  echo "✗ install.sh not found at: $INSTALL_SH"
  exit 1
fi

echo "✧ Updating Imaginary Linux → version $VERSION ($CODENAME)"

# ----------------------------------------
# Updates
# ----------------------------------------

# Header comment
sed -i \
  "s/^# Version .*/# Version $VERSION (${CODENAME^})/" \
  "$INSTALL_SH"

# Banner version
sed -i \
  "s/Version [0-9.]* (.*/Version $VERSION (${CODENAME^})/" \
  "$INSTALL_SH"

# os-release VERSION
sed -i \
  "s/^VERSION=\".*\"/VERSION=\"$VERSION\"/" \
  "$INSTALL_SH"

sed -i \
  "s/^VERSION_ID=\".*\"/VERSION_ID=\"$VERSION\"/" \
  "$INSTALL_SH"

sed -i \
  "s/^VERSION_CODENAME=.*/VERSION_CODENAME=$CODENAME/" \
  "$INSTALL_SH"

# lsb-release
sed -i \
  "s/^DISTRIB_RELEASE=.*/DISTRIB_RELEASE=$VERSION/" \
  "$INSTALL_SH"

sed -i \
  "s/^DISTRIB_CODENAME=.*/DISTRIB_CODENAME=$CODENAME/" \
  "$INSTALL_SH"

# imaginary-release
sed -i \
  "s/^IMAGINARY_VERSION=.*/IMAGINARY_VERSION=\"$VERSION\"/" \
  "$INSTALL_SH"

sed -i \
  "s/^IMAGINARY_CODENAME=.*/IMAGINARY_CODENAME=\"${CODENAME^}\"/" \
  "$INSTALL_SH"

sed -i \
  "s/^IMAGINARY_ANGEL=.*/IMAGINARY_ANGEL=\"${CODENAME^}\"/" \
  "$INSTALL_SH"

echo "✓ install.sh updated successfully"
