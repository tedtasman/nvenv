#!/usr/bin/env bash

INSTALL_DIR="$HOME/.local/bin"
SCRIPT_NAME="nvenv"

echo ""
echo "Uninstalling nvenv..."
echo ""

# ----------------------------
# Remove Script
# ----------------------------

if [[ -f "$INSTALL_DIR/$SCRIPT_NAME" ]]; then
  rm "$INSTALL_DIR/$SCRIPT_NAME"
  echo "✔ Script removed from $INSTALL_DIR/$SCRIPT_NAME"
else
  echo "Script not found in $INSTALL_DIR"
fi

# ----------------------------
# Detect Shell Config
# ----------------------------

SHELL_NAME="$(basename "${SHELL:-}")"

case "$SHELL_NAME" in
  bash)
    SHELL_RC="$HOME/.bashrc"
    ;;
  zsh)
    SHELL_RC="$HOME/.zshrc"
    ;;
  *)
    echo ""
    echo "Unsupported shell: $SHELL_NAME"
    echo "Remove the following manually from your shell config if present:"
    echo "export PATH=\"$INSTALL_DIR:\$PATH\""
    echo "nvenv() { source \"$INSTALL_DIR/$SCRIPT_NAME\" \"\$@\"; }"
    echo ""
    exit 0
    ;;
esac

# ----------------------------
# Remove PATH Export
# ----------------------------

if [[ -f "$SHELL_RC" ]]; then
  if grep -q "$INSTALL_DIR" "$SHELL_RC" 2>/dev/null; then
    # Create a temporary file without the PATH export and related comments
    grep -v "Added by nvenv installer" "$SHELL_RC" | grep -v "export PATH=\"$INSTALL_DIR:\$PATH\"" > "$SHELL_RC.tmp"
    mv "$SHELL_RC.tmp" "$SHELL_RC"
    echo "✔ PATH export removed from $SHELL_RC"
  fi
fi

# ----------------------------
# Remove Shell Function
# ----------------------------

if [[ -f "$SHELL_RC" ]]; then
  if grep -q "nvenv() {" "$SHELL_RC" 2>/dev/null; then
    # Create a temporary file without the nvenv function and related comments
    {
      grep -v "nvenv shell wrapper" "$SHELL_RC"
    } | {
      grep -v "^nvenv() {$"
    } | {
      grep -v "source \"$INSTALL_DIR/$SCRIPT_NAME"
    } | {
      grep -v "^}$" -m1
    } > "$SHELL_RC.tmp"
    
    # More precise removal using sed
    sed -i '' '/# nvenv shell wrapper/,/^}/d' "$SHELL_RC"
    echo "✔ Shell function removed from $SHELL_RC"
  fi
fi

echo ""
echo "Uninstallation complete."
echo ""
echo "Restart your shell or run:"
echo "  source $SHELL_RC"
echo ""
