#!/bin/sh
set -e

# Set install root (default to $HOME for rootless installation)
GMA3_INSTALL_ROOT="${GMA3_INSTALL_ROOT:-$HOME}"

# Determine bin directory based on install root
if [ "$GMA3_INSTALL_ROOT" = "/root" ]; then
    # Rootful mode: system-wide installation
    BIN_DIR="/usr/bin"
    MODE="rootful"
else
    # Rootless mode: user installation
    BIN_DIR="$HOME/.local/bin"
    MODE="rootless"
fi

echo "Uninstalling GrandMA3 ($MODE mode)..."
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

# Remove desktop file and icon (always in $HOME/.local)
if [ -f "$HOME/.local/share/applications/gma3.desktop" ]; then
    echo "Removing desktop launcher..."
    rm -f "$HOME/.local/share/applications/gma3.desktop"
fi

if [ -d "$HOME/.local/share/gma3" ]; then
    echo "Removing application data..."
    rm -rf "$HOME/.local/share/gma3"
fi

echo ""
echo "GrandMA3 has been uninstalled successfully!"
