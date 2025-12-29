#!/bin/sh
set -e

# Set install root (default to $HOME for rootless installation)
GMA3_INSTALL_ROOT="${GMA3_INSTALL_ROOT:-$HOME}"

# Determine bin directory and sudo usage based on install root
if [ "$GMA3_INSTALL_ROOT" = "/root" ]; then
    # Rootful mode: system-wide installation
    BIN_DIR="/usr/bin"
    SUDO_PREFIX="sudo "
else
    # Rootless mode: user installation
    BIN_DIR="$HOME/.local/bin"
    SUDO_PREFIX=""
fi

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

mkdir -p $HOME/.local/share/applications
mkdir -p $HOME/.local/share/gma3
mkdir -p $(dirname "$BIN_DIR/gma3")

echo "#!/bin/sh
${SUDO_PREFIX}LD_LIBRARY_PATH=$GMA3_INSTALL_ROOT/MALightingTechnology/gma3_$VERSION/shared/third_party $GMA3_INSTALL_ROOT/MALightingTechnology/gma3_$VERSION/console/bin/app_gma3 HOSTTYPE=onPC" > $BIN_DIR/gma3
chmod +x $BIN_DIR/gma3
cp gma3.ico $HOME/.local/share/gma3/gma3.ico
echo "[Desktop Entry]
Type=Application
Terminal=true
Name=GrandMA3
Icon=$HOME/.local/share/gma3/gma3.ico
Exec=$BIN_DIR/gma3
" > $HOME/.local/share/applications/gma3.desktop
