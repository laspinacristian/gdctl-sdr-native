#!/usr/bin/env bash
# Install:   curl -fsSL https://raw.githubusercontent.com/laspinacristian/gdctl-sdr-native/main/install.sh | bash
# Uninstall: curl -fsSL https://raw.githubusercontent.com/laspinacristian/gdctl-sdr-native/main/install.sh | bash -s -- --uninstall
#
# Per-user install, no root needed: the watcher goes to ~/.local/bin and a
# systemd user service starts it with the graphical session.
set -euo pipefail

BASE_URL=https://raw.githubusercontent.com/laspinacristian/gdctl-sdr-native/main
BIN="$HOME/.local/bin/gdctl-sdr-native-watch"
UNIT_DIR="$HOME/.config/systemd/user"
UNIT=gdctl-sdr-native.service

die() { echo "Error: $*" >&2; exit 1; }

fetch() {
    local name=$1 dest=$2 local_copy
    local_copy="$(dirname -- "${BASH_SOURCE[0]:-/nonexistent}")/$name"
    if [[ -f "$local_copy" ]]; then
        cp -- "$local_copy" "$dest"
    else
        curl -fsSL "$BASE_URL/$name" -o "$dest"
    fi
}

case "${1:-}" in
    --uninstall)
        systemctl --user disable --now "$UNIT" 2>/dev/null || true
        rm -f -- "$BIN" "$UNIT_DIR/$UNIT"
        systemctl --user daemon-reload
        echo 'Uninstalled.'
        exit 0 ;;
    '') ;;
    *) die "unknown option: $1" ;;
esac

[[ -x /usr/bin/gdctl ]] || die '/usr/bin/gdctl not found: it ships with recent GNOME/Mutter.'
python3 -c 'import gi; gi.require_version("Gio", "2.0")' 2>/dev/null \
    || die 'python3 with PyGObject (python3-gobject) is required.'

tmp=$(mktemp -d)
trap 'rm -rf -- "$tmp"' EXIT
fetch gdctl-sdr-native-watch "$tmp/watch"
fetch "$UNIT" "$tmp/unit"
python3 -c 'import ast, sys; ast.parse(open(sys.argv[1]).read())' "$tmp/watch" \
    || die 'downloaded watcher is not valid.'

install -D -m 0755 -- "$tmp/watch" "$BIN"
install -D -m 0644 -- "$tmp/unit" "$UNIT_DIR/$UNIT"
systemctl --user daemon-reload
systemctl --user enable "$UNIT"
# Start it now if we are inside a graphical session; otherwise it starts at next login.
systemctl --user restart "$UNIT" 2>/dev/null || true
echo "Installed. Check it with: systemctl --user status $UNIT"
