#!/usr/bin/env bash
# Review and run at your own risk
set -euo pipefail
PNAME="@pname@"

PREFIX="${1:-$HOME/.local}"
BIN_DIR="$PREFIX/bin"
OPT_DIR="$PREFIX/opt/$PNAME"

if [ "$PREFIX" = "$HOME/.local" ]; then
  SHARE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}"
else
  SHARE_DIR="$PREFIX/share"
fi

DESKTOP_DIR="$SHARE_DIR/applications"
ICON_DIR="$SHARE_DIR/icons/hicolor/scalable/apps"

echo "Installing $PNAME to $PREFIX..."
mkdir -p "$OPT_DIR" "$BIN_DIR" "$DESKTOP_DIR" "$ICON_DIR"

cp -R "$(dirname "$0")/$PNAME/." "$OPT_DIR/"

# Install icons
ICON_SRC_DIR="$(dirname "$0")/share/icons/hicolor/scalable/apps"
if [ -d "$ICON_SRC_DIR" ]; then
  cp "$ICON_SRC_DIR"/*.svg "$ICON_DIR/" 2>/dev/null || true
fi

cat >"$BIN_DIR/$PNAME" <<EOSH
  #!/usr/bin/env bash
  exec "$OPT_DIR/$PNAME" "$@"
EOSH
chmod +x "$BIN_DIR/$PNAME"

# Install desktop file with absolute path
DESKTOP_SRC=$(find "$(dirname "$0")/share/applications" -name "*.desktop" -print -quit)
if [ -n "$DESKTOP_SRC" ]; then
  DESKTOP_NAME=$(basename "$DESKTOP_SRC")
  sed "s|^Exec=.*|Exec=$BIN_DIR/$PNAME|" "$DESKTOP_SRC" >"$DESKTOP_DIR/$DESKTOP_NAME"
fi

if [ "$PREFIX" = "$HOME/.local" ]; then
  if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$DESKTOP_DIR"
  fi
fi
echo "Installed to $PREFIX. You can launch with $PNAME."
