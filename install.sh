#!/usr/bin/env bash

set -e

INSTALL_DIR="$HOME/.local/bin"
SCRIPT_NAME="nvenv"
REPO_URL="https://raw.githubusercontent.com/tedtasman/nvenv/main/nvenv"

INTERACTIVE=true

# Detect pipe install
if [[ ! -t 0 ]]; then
  INTERACTIVE=false
fi

prompt_yes() {
  local message="$1"
  local response

  if [[ "$INTERACTIVE" == false ]]; then
    return 0
  fi

  read -r -p "$message [Y/n] " response </dev/tty

  case "$response" in
    [nN]|[nN][oO])
      return 1
      ;;
    *)
      return 0
      ;;
  esac
}

if [[ -f "$INSTALL_DIR"/$SCRIPT_NAME ]];then
  echo "Removing existing nvenv installation"
  echo ""
  rm -f "$INSTALL_DIR/$SCRIPT_NAME"
fi

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
# Detect Shell RC File
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
    echo "Add manually:"
    echo "export PATH=\"$INSTALL_DIR:\$PATH\""
    exit 0
    ;;
esac

# ----------------------------
# PATH Installation
# ----------------------------

echo ""

if prompt_yes "Add $INSTALL_DIR to PATH in $SHELL_RC?"; then
  if ! grep -q "export PATH=\"$INSTALL_DIR" "$SHELL_RC" 2>/dev/null; then
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
# Shell Function Wrapper
# ----------------------------

echo ""

if prompt_yes "Make 'nvenv' callable without typing 'source'?"; then

  if ! grep -q "nvenv() {" "$SHELL_RC" 2>/dev/null; then

    {
      echo ""
      echo "# nvenv shell wrapper"
      echo "nvenv() {"
      echo "  source \"$INSTALL_DIR/$SCRIPT_NAME\" \"\$@\""
      echo "}"
    } >> "$SHELL_RC"

    echo "✔ Shell wrapper added to $SHELL_RC"
  else
    echo "✔ Shell wrapper already exists"
  fi
fi

echo "Installation complete."
echo ""
echo "Restart your shell or run:"
echo "  source \"$SHELL_RC\""
