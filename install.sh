#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
prefix=${PREFIX:-"$HOME/.local"}

usage() {
  cat <<'EOF'
Usage:
  ./install.sh [--prefix PATH]

Installs fanctl, fanctl-gui, and a desktop launcher for the current user.
Set PREFIX=/usr/local or pass --prefix /usr/local for a system-wide install.
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

bindir="$prefix/bin"
desktop_dir="$prefix/share/applications"
desktop_file="$desktop_dir/victus-fan-control.desktop"

install -d "$bindir" "$desktop_dir"
install -m 0755 "$repo_dir/bin/fanctl" "$bindir/fanctl"
install -m 0755 "$repo_dir/bin/fanctl-gui" "$bindir/fanctl-gui"
install -m 0644 "$repo_dir/share/applications/victus-fan-control.desktop.in" "$desktop_file"
sed -i "s|@BINDIR@|$bindir|g" "$desktop_file"

if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$desktop_dir" >/dev/null 2>&1 || true
fi

printf 'Installed:\n'
printf '  %s\n' "$bindir/fanctl"
printf '  %s\n' "$bindir/fanctl-gui"
printf '  %s\n' "$desktop_file"

if [[ ":$PATH:" != *":$bindir:"* ]]; then
  printf '\nAdd this to PATH if your shell cannot find fanctl:\n'
  printf '  export PATH="%s:$PATH"\n' "$bindir"
fi

if ! python3 - <<'PY' >/dev/null 2>&1
import gi
gi.require_version("Gtk", "3.0")
PY
then
  cat <<'EOF'

GUI dependency warning:
  Python GTK bindings are missing. The CLI is installed, but fanctl-gui will not
  start until PyGObject/GTK3 is installed for your distro.
EOF
fi

cat <<'EOF'

Next:
  fanctl capabilities
  fanctl status
  fanctl-gui
EOF
