#!/usr/bin/env bash
set -euo pipefail

prefix=${PREFIX:-"$HOME/.local"}

usage() {
  cat <<'EOF'
Usage:
  ./uninstall.sh [--prefix PATH]

Removes the installed commands and desktop launcher. User config/log files are
left in ~/.config/victus-fan-control and ~/.local/state/victus-fan-control.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --prefix)
      [[ $# -ge 2 ]] || { usage >&2; exit 2; }
      prefix=$2
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
done

rm -f "$prefix/bin/fanctl"
rm -f "$prefix/bin/fanctl-gui"
rm -f "$prefix/share/applications/victus-fan-control.desktop"
rm -f "$HOME/.config/autostart/victus-fan-control.desktop"

if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$prefix/share/applications" >/dev/null 2>&1 || true
fi

printf 'Removed Victus Fan Control from %s\n' "$prefix"
