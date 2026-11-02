#!/bin/sh
# Install continua: https://github.com/maximetinu/continua
#   curl -fsSL https://raw.githubusercontent.com/maximetinu/continua/main/install.sh | sh
# Set CONTINUA_BIN_DIR to install somewhere else (default: ~/.local/bin).
set -eu

REPO_RAW="https://raw.githubusercontent.com/maximetinu/continua/main"
BIN_DIR="${CONTINUA_BIN_DIR:-$HOME/.local/bin}"
DEST="$BIN_DIR/continua"

say() { printf '%s\n' "$*"; }
die() { printf 'continua install: %s\n' "$*" >&2; exit 1; }

[ "$(uname -s)" = "Darwin" ] || die "continua only works on macOS for now."
command -v python3 >/dev/null 2>&1 || die "python3 not found. Install the Xcode Command Line Tools (xcode-select --install) or Homebrew Python."
python3 -c 'import sys; sys.exit(0 if sys.version_info >= (3, 8) else 1)' || die "python3 3.8 or newer is required."

if [ ! -f /Applications/Ghostty.app/Contents/Resources/Ghostty.sdef ]; then
  say "warning: no Ghostty with AppleScript support found in /Applications."
  say "         continua needs a Ghostty build with AppleScript (tested on 1.4.0)."
fi

mkdir -p "$BIN_DIR"
tmp="$(mktemp "${TMPDIR:-/tmp}/continua.XXXXXX")"
trap 'rm -f "$tmp"' EXIT
curl -fsSL "$REPO_RAW/continua" -o "$tmp" || die "download failed."
head -1 "$tmp" | grep -q python3 || die "downloaded file does not look like continua."
chmod +x "$tmp"
mv "$tmp" "$DEST"
trap - EXIT

say "Installed continua $("$DEST" --version | cut -d' ' -f2) to $DEST"
case ":$PATH:" in
  *":$BIN_DIR:"*) say "Run: continua" ;;
  *) say "Note: $BIN_DIR is not on your PATH. Add this to your shell profile:"
     say "  export PATH=\"$BIN_DIR:\$PATH\"" ;;
esac
