## Instructions

1. Download "grandMA3 Software x.x.x.x" under "Software + Release Notes" section
2. Run the installer using one of the installation modes below

## Installation Modes

### Rootless Installation (Default)
Installs to your home directory without requiring sudo:
```bash
./install.sh ./path/to/grandMA3_stick_vx.x.x.x.zip
```
- Files installed to: `~/MALightingTechnology`
- Executable: `~/.local/bin/gma3`
- Run with: `gma3`
- Works in read-only distros like Universal Blue

### Rootful Installation (Testing/Original Method)
Installs to /root directory, matching the original fork behavior:
```bash
GMA3_INSTALL_ROOT=/root sudo ./install.sh ./path/to/grandMA3_stick_vx.x.x.x.zip
```
- Files installed to: `/root/MALightingTechnology`
- Executable: `/usr/bin/gma3`
- Run with: `gma3` (sudo is invoked automatically by the script)
- Useful for testing if newer versions require root access

## Uninstalling

### Rootless Uninstall
```bash
./uninstall.sh
```

### Rootful Uninstall
```bash
GMA3_INSTALL_ROOT=/root sudo ./uninstall.sh
```

The uninstall script will:
- Remove the MALightingTechnology directory
- Remove the gma3 executable
- Remove the desktop launcher and icon
- Ask for confirmation before proceeding

## Info

Software can be installed in either rootless mode (default) or rootful mode.
A desktop launcher `gma3.desktop` is created at `~/.local/share/applications`
for easy GUI access in both modes.

## Thanks

Thanks to the original repo:
https://github.com/routmoute/grandMA3-linux-installer

Thanks to johnsudaar and audiofanzine forum:
https://fr.audiofanzine.com/controleur-d-eclairage-informati/ma-lighting/grandma-onpc/forums/t.706000,grandma3-il-est-possible-de-le-faire-tourner-sur-linux.html
