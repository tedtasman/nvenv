#!/usr/bin/env bash

set -euo pipefail

INSTALL_DIR="$HOME/.local/bin"
SCRIPT_NAME="nvenv"
REPO_URL="https://raw.githubusercontent.com/tedtasman/nvenv/main/nvenv"

echo ""
echo "Installing nvenv..."
echo ""

# ----------------------------
# Download Script
# ----------------------------

mkdir -p "$INSTALL_DIR"

curl -fsSL "$REPO_URL" -o "$INSTALL_DIR/$SCRIPT_NAME"
chmod +x "$INSTALL_DIR/$SCRIPT_NAME"

echo "✔ Script installed to $INSTALL_DIR/$SCRIPT_NAME"

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
    echo "Add the following manually to your shell config:"
    echo "export PATH=\"$INSTALL_DIR:\$PATH\""
    echo ""
    exit 0
    ;;
esac

echo ""
read -r -p "Add $INSTALL_DIR to PATH in $SHELL_RC? [y/N] " ADD_PATH

if [[ "$ADD_PATH" =~ ^[Yy]$ ]]; then
  if ! grep -q "$INSTALL_DIR" "$SHELL_RC" 2>/dev/null; then
    {
      echo ""
      echo "# Added by nvenv installer"
      echo "export PATH=\"$INSTALL_DIR:\$PATH\""
    } >> "$SHELL_RC"
    echo "✔ PATH updated in $SHELL_RC"
  else
    echo "✔ PATH already configured"
  fi
fi

# ----------------------------
# Add Callable Wrapper
# ----------------------------

echo ""
read -r -p "Make 'nvenv' callable without typing 'source'? [y/N] " ADD_FUNC

if [[ "$ADD_FUNC" =~ ^[Yy]$ ]]; then
  if ! grep -q "nvenv() {" "$SHELL_RC" 2>/dev/null; then
    {
      echo ""
      echo "# nvenv shell wrapper"
      echo "nvenv() {"
      echo "  source \"$INSTALL_DIR/$SCRIPT_NAME\" \"\$@\""
      echo "}"
    } >> "$SHELL_RC"
    echo "✔ Shell function added to $SHELL_RC"
  else
    echo "✔ nvenv function already exists"
  fi
fi

echo ""
echo "Installation complete."
echo ""
echo "Restart your shell or run:"
echo "  source $SHELL_RC"
echo ""