#!/bin/sh
set -euf

usage() {
  echo "Usage: $0 [--system] /path/to/grandMA3_onPC_win_v*.zip" >&2
  exit 1
}

SYSTEM=0
case "${1:-}" in
  --system) SYSTEM=1; shift ;;
esac
[ $# -eq 1 ] || usage
ZIP="$1"
[ -f "$ZIP" ] || { echo "ZIP not found: $ZIP" >&2; exit 1; }

# Paths based on mode
if [ "$SYSTEM" -eq 1 ]; then
  APP_ROOT="/opt/MALightingTechnology"
  BIN_DIR="/usr/local/bin"
  DESKTOP_DIR="/usr/share/applications"
  ICON_DIR="/usr/share/icons/hicolor/256x256/apps"
  OWNER="root:root"
else
  APP_ROOT="$HOME/.local/opt/MALightingTechnology"
  BIN_DIR="$HOME/.local/bin"
  DESKTOP_DIR="$HOME/.local/share/applications"
  ICON_DIR="$HOME/.local/share/icons/hicolor/256x256/apps"
  OWNER="$(id -u):$(id -g)"
fi

TMPDIR="$(mktemp -d)"
cleanup() { rm -rf "$TMPDIR"; }
trap cleanup EXIT

echo ">> Unpacking ZIP to temp..."
unzip -q -o "$ZIP" -d "$TMPDIR/grandMA3"

# Find release XML
RELEASEFILE="$(ls "$TMPDIR/grandMA3/ma"/release_stick_*.xml | head -1)"
[ -n "$RELEASEFILE" ] || { echo "Release XML not found." >&2; exit 1; }

FULLVERSION="$(xmllint -xpath 'string(//GMA3/ReleaseFile/Version)' "$RELEASEFILE")"
VERSION="${FULLVERSION%.*}"  # e.g., 2.2.5

echo "RELEASEFILE: $RELEASEFILE"
echo "FULLVERSION: $FULLVERSION"
echo "VERSION: $VERSION"

DEST_PREFIX="$APP_ROOT/gma3_${VERSION}"
echo ">> Installing to: $DEST_PREFIX"

# Create dirs (may need sudo in system mode)
if [ "$SYSTEM" -eq 1 ]; then
  sudo mkdir -p "$DEST_PREFIX"
else
  mkdir -p "$DEST_PREFIX"
fi

# 1) Create all destination dirs from the XML (excluding sys/arm/gma2 packets)
#    Replace /home/ma with $DEST_PREFIX
MKDIR_CMDS="$(xmllint -xpath \
  '//GMA3/ReleaseFile/MAPacket[not(contains(@Type,"sys")) and not(contains(@Type,"arm")) and not(contains(@Type,"gma2"))]/@Destination' \
  "$RELEASEFILE" \
  | sed 's/ Destination=/mkdir -p /g' \
  | sed "s|/home/ma|$DEST_PREFIX|g")"

# 2) Unpack each packet to its Destination
UNZIP_CMDS="$(xmllint -xpath \
  '//GMA3/ReleaseFile/MAPacket[not(contains(@Type,"sys")) and not(contains(@Type,"arm")) and not(contains(@Type,"gma2"))]/@*[name()="Name" or name()="Destination"]' \
  "$RELEASEFILE" \
  | tr -d '\n' \
  | sed 's/ Name=/\nunzip -q -o /g' \
  | sed 's/ Destination=/ -d /g' \
  | sed "s|/home/ma|$DEST_PREFIX|g")"

# Run the commands in the extracted 'ma' folder context
(
  cd "$TMPDIR/grandMA3/ma"
  if [ "$SYSTEM" -eq 1 ]; then
    echo "$MKDIR_CMDS" | sudo sh
    echo "$UNZIP_CMDS" | sudo sh
  else
    echo "$MKDIR_CMDS" | sh
    echo "$UNZIP_CMDS" | sh
  fi
)

# Ownership & perms for system mode
if [ "$SYSTEM" -eq 1 ]; then
  sudo chown -R $OWNER "$APP_ROOT"
  sudo find "$DEST_PREFIX" -type d -exec chmod 755 {} \;
  sudo find "$DEST_PREFIX" -type f -exec chmod 644 {} \;
  # Make sure executables are executable
  if [ -d "$DEST_PREFIX/console/bin" ]; then
    sudo find "$DEST_PREFIX/console/bin" -type f -exec chmod 755 {} \;
  fi
fi

# Wrapper script
WRAP_PATH="$BIN_DIR/gma3"
WRAP_TMP="$TMPDIR/gma3.wrapper"
cat > "$WRAP_TMP" <<EOF
#!/bin/sh
set -e
GMA3_DIR="$DEST_PREFIX"
export HOSTTYPE=onPC
export LD_LIBRARY_PATH="\$GMA3_DIR/shared/third_party\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}"
exec "\$GMA3_DIR/console/bin/app_gma3" "\$@"
EOF

if [ "$SYSTEM" -eq 1 ]; then
  sudo install -m 0755 -o root -g root -D "$WRAP_TMP" "$WRAP_PATH"
else
  mkdir -p "$BIN_DIR"
  install -m 0755 -D "$WRAP_TMP" "$WRAP_PATH"
fi

# Icon & desktop file
# If you have gma3.ico next to this installer, we’ll convert a 256px PNG if possible; otherwise we just reference the .ico.
ICO_SRC_DIR="$(dirname "$0")"
ICO_SRC="$ICO_SRC_DIR/gma3.ico"

mkdir -p "$ICON_DIR" "$DESKTOP_DIR"
if command -v convert >/dev/null 2>&1 && [ -f "$ICO_SRC" ]; then
  PNG_OUT="$TMPDIR/gma3.png"
  convert "$ICO_SRC[0]" -resize 256x256 "$PNG_OUT"
  if [ "$SYSTEM" -eq 1 ]; then
    sudo install -m 0644 -D "$PNG_OUT" "$ICON_DIR/gma3.png"
  else
    install -m 0644 -D "$PNG_OUT" "$ICON_DIR/gma3.png"
  fi
  ICON_PATH="$ICON_DIR/gma3.png"
elif [ -f "$ICO_SRC" ]; then
  # Some desktops handle ICOs fine
  if [ "$SYSTEM" -eq 1 ]; then
    sudo install -m 0644 -D "$ICO_SRC" "$ICON_DIR/gma3.ico"
  else
    install -m 0644 -D "$ICO_SRC" "$ICON_DIR/gma3.ico"
  fi
  ICON_PATH="$ICON_DIR/gma3.ico"
else
  ICON_PATH="gma3"
fi

DESKTOP_TMP="$TMPDIR/gma3.desktop"
cat > "$DESKTOP_TMP" <<EOF
[Desktop Entry]
Type=Application
Name=grandMA3 onPC
Comment=MA Lighting grandMA3 onPC
Exec=$WRAP_PATH
Icon=$ICON_PATH
Terminal=false
Categories=AudioVideo;Graphics;
EOF

if [ "$SYSTEM" -eq 1 ]; then
  sudo install -m 0644 -D "$DESKTOP_TMP" "$DESKTOP_DIR/gma3.desktop"
  # Update desktop & icon caches (best effort)
  command -v update-desktop-database >/dev/null 2>&1 && sudo update-desktop-database || true
  command -v gtk-update-icon-cache >/dev/null 2>&1 && sudo gtk-update-icon-cache -q /usr/share/icons/hicolor || true
else
  install -m 0644 -D "$DESKTOP_TMP" "$DESKTOP_DIR/gma3.desktop"
fi

echo "✅ Installed grandMA3 onPC $FULLVERSION"
echo "   Binary: $WRAP_PATH"
echo "   AppDir: $DEST_PREFIX"
echo "   Desktop entry: $DESKTOP_DIR/gma3.desktop"
