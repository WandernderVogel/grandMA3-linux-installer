# grandMA3 Linux Installer

Install grandMA3 onPC on Linux with a simple shell script.

## Prerequisites

- `unzip` - for extracting the installer
- `xmllint` (libxml2-utils) - for parsing release files
- `sudo` access - required for installation

## Installation

1. Download the **grandMA3 stick package** from [MA Lighting Downloads](https://www.malighting.com/downloads/)
   - Look for "grandMA3 Software x.x.x.x" under "Software + Release Notes"
   - Download the file named `grandMA3_stick_vx.x.x.x.zip`

2. Run the installer:
```bash
sudo ./install.sh ./path/to/grandMA3_stick_vx.x.x.x.zip
```

3. Launch GrandMA3:
```bash
gma3
```

Or use the desktop launcher from your application menu.

## What Gets Installed

- **Software files**: `/root/MALightingTechnology/gma3_x.x/`
- **Executable**: `/usr/bin/gma3`
- **Desktop launcher**: `~/.local/share/applications/gma3.desktop`
- **Icon**: `~/.local/share/gma3/gma3.ico`

## Uninstalling

```bash
sudo ./uninstall.sh
```

The uninstall script will:
- Remove the MALightingTechnology directory
- Remove the gma3 executable
- Remove the desktop launcher and icon
- Ask for confirmation before proceeding

## Known Issues

### Recovery Mode Banner

GrandMA3 will display a red "RECOVERY MODE" banner when running on Linux. This is expected behavior and **does not affect functionality**. The software is fully functional despite this message.

**Why this happens**: GrandMA3 v2.x performs hardware validation checks designed for official MA Lighting consoles. When run on generic Linux hardware, it enters recovery mode as a safety mechanism. However, the interface remains fully responsive and usable.

### Requires Root/Sudo

The application must be run with sudo to function properly. The installer creates a launcher script that automatically handles this, so you can run `gma3` from the command line or use the desktop launcher without manually typing sudo.

## Tested On

- Fedora 43 (KDE Plasma on Wayland)
- Debian 13 (KDE Plasma on Wayland)
- GrandMA3 v2.3.2.0
- GrandMA3 v2.5.0.3

## Credits

- Original installer script: [routmoute/grandMA3-linux-installer](https://github.com/routmoute/grandMA3-linux-installer)
- Installation method discovered by johnsudaar: [Audiofanzine Forum Thread](https://fr.audiofanzine.com/controleur-d-eclairage-informati/ma-lighting/grandma-onpc/forums/t.706000,grandma3-il-est-possible-de-le-faire-tourner-sur-linux.html)
