#!/usr/bin/env bash
# Installs or upgrades the Nebula Monitor widget for the current user.
set -euo pipefail

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_ID="local.systrio"
PLUGIN_TARGET="${XDG_DATA_HOME:-$HOME/.local/share}/plasma/plasmoids/$PACKAGE_ID"

if ! command -v kpackagetool6 >/dev/null 2>&1; then
    echo "error: kpackagetool6 not found. Install the plasma-workspace package." >&2
    exit 1
fi

if kpackagetool6 --type Plasma/Applet --list 2>/dev/null | grep -qx "$PACKAGE_ID"; then
    echo "Upgrading $PACKAGE_ID ..."
    kpackagetool6 --type Plasma/Applet --upgrade "$SOURCE_DIR"
else
    echo "Installing $PACKAGE_ID ..."
    kpackagetool6 --type Plasma/Applet --install "$SOURCE_DIR"
fi

# Reload the desktop so the new version is picked up immediately.
if systemctl --user is-active --quiet plasma-plasmashell.service 2>/dev/null; then
    systemctl --user restart plasma-plasmashell.service
elif command -v kquitapp6 >/dev/null 2>&1; then
    kquitapp6 plasmashell >/dev/null 2>&1 || true
    setsid plasmashell >/dev/null 2>&1 &
fi

echo
echo "Nebula Monitor installed in $PLUGIN_TARGET"
echo "Add it with: right-click the desktop -> Add Widgets -> search for \"Nebula Monitor\"."
