#!/bin/sh
set -e

# Check if running with sudo/root privileges
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run with sudo"
   exit 1
fi

# Root installation paths
GMA3_INSTALL_ROOT="/root"
BIN_DIR="/usr/bin"

unzip -o $1 -d /tmp/grandMA3

pushd .
cd /tmp/grandMA3/ma/

RELEASEFILE=$(ls ./release_stick_*.xml | head -1)
FULLVERSION=$(xmllint -xpath '//GMA3/ReleaseFile/Version/text()' $RELEASEFILE)
VERSION="${FULLVERSION%.*}"

echo "RELEASEFILE: $RELEASEFILE"
echo "FULLVERSION: $FULLVERSION"
echo "VERSION: $VERSION"

### Unzip MA files in MALightingTechnology directory ###
xmllint -xpath '//GMA3/ReleaseFile/MAPacket[not(contains(@Type, "sys")) and not(contains(@Type, "arm")) and not(contains(@Type, "gma2"))]/@Destination' $RELEASEFILE | sed "s/ Destination=/mkdir -p /" | sed "s|/home/ma|$GMA3_INSTALL_ROOT|" | sh
xmllint -xpath '//GMA3/ReleaseFile/MAPacket[not(contains(@Type, "sys")) and not(contains(@Type, "arm")) and not(contains(@Type, "gma2"))]/@*[name()="Name" or name()="Destination"]' $RELEASEFILE | sed "s/ Destination=/ -d /" | tr -d "\n" | sed "s/ Name=/\nunzip -o /g" | sed "s|/home/ma|$GMA3_INSTALL_ROOT|" | sh
popd

# Determine the user who invoked sudo
REAL_USER="${SUDO_USER:-$USER}"
USER_HOME=$(eval echo "~$REAL_USER")

mkdir -p "$USER_HOME/.local/share/applications"
mkdir -p "$USER_HOME/.local/share/gma3"

# Create launcher script that uses sudo
echo "#!/bin/sh
sudo LD_LIBRARY_PATH=$GMA3_INSTALL_ROOT/MALightingTechnology/gma3_$VERSION/shared/third_party $GMA3_INSTALL_ROOT/MALightingTechnology/gma3_$VERSION/console/bin/app_gma3 HOSTTYPE=onPC" > $BIN_DIR/gma3
chmod +x $BIN_DIR/gma3

# Install icon and desktop file for the real user
cp gma3.ico "$USER_HOME/.local/share/gma3/gma3.ico"
chown "$REAL_USER:$REAL_USER" "$USER_HOME/.local/share/gma3/gma3.ico"

echo "[Desktop Entry]
Type=Application
Terminal=true
Name=GrandMA3
Icon=$USER_HOME/.local/share/gma3/gma3.ico
Exec=$BIN_DIR/gma3
" > "$USER_HOME/.local/share/applications/gma3.desktop"
chown "$REAL_USER:$REAL_USER" "$USER_HOME/.local/share/applications/gma3.desktop"

echo ""
echo "GrandMA3 $FULLVERSION installed successfully!"
echo "Run with: gma3"
echo ""
echo "Note: GrandMA3 will show a 'RECOVERY MODE' banner. This is expected"
echo "on Linux and does not affect functionality. The interface is fully"
echo "responsive when run with sudo (which the launcher script handles)."
