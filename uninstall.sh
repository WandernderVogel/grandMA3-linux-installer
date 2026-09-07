#!/bin/bash
set -e

# Check if running with sudo/root privileges
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run with sudo"
   exit 1
fi

# Root installation paths
GMA3_INSTALL_ROOT="/root"
BIN_DIR="/usr/bin"

# Determine the user who invoked sudo
REAL_USER="${SUDO_USER:-$USER}"
USER_HOME=$(eval echo "~$REAL_USER")

echo "Uninstalling GrandMA3 (root installation)..."
echo "Install root: $GMA3_INSTALL_ROOT"
echo "Executable: $BIN_DIR/gma3"
echo ""

# Confirm uninstallation
read -p "Are you sure you want to uninstall GrandMA3? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Uninstall cancelled."
    exit 0
fi

# Remove MALightingTechnology directory
if [ -d "$GMA3_INSTALL_ROOT/MALightingTechnology" ]; then
    echo "Removing $GMA3_INSTALL_ROOT/MALightingTechnology..."
    rm -rf "$GMA3_INSTALL_ROOT/MALightingTechnology"
fi

# Remove executable
if [ -f "$BIN_DIR/gma3" ]; then
    echo "Removing $BIN_DIR/gma3..."
    rm -f "$BIN_DIR/gma3"
fi

# Remove desktop file and icon (from the user's home)
if [ -f "$USER_HOME/.local/share/applications/gma3.desktop" ]; then
    echo "Removing desktop launcher..."
    rm -f "$USER_HOME/.local/share/applications/gma3.desktop"
fi

if [ -d "$USER_HOME/.local/share/gma3" ]; then
    echo "Removing application data..."
    rm -rf "$USER_HOME/.local/share/gma3"
fi

echo ""
echo "GrandMA3 has been uninstalled successfully!"
