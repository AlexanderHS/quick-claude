#!/bin/bash
# Install quick-claude alias

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ALIAS_NAME="${1:-w}"
ALIAS_LINE="alias $ALIAS_NAME='source $SCRIPT_DIR/quick-claude.sh'"

# Detect shell config file
if [[ -n "$ZSH_VERSION" ]] || [[ "$SHELL" == */zsh ]]; then
    RC_FILE="$HOME/.zshrc"
else
    RC_FILE="$HOME/.bashrc"
fi

# Check if alias already exists
if grep -q "# quick-claude" "$RC_FILE" 2>/dev/null; then
    echo "quick-claude already installed in $RC_FILE"
    echo "Run ./uninstall.sh first if you want to reinstall"
    exit 1
fi

# Add alias
echo "" >> "$RC_FILE"
echo "# quick-claude" >> "$RC_FILE"
echo "$ALIAS_LINE" >> "$RC_FILE"

echo "Installed! Added to $RC_FILE:"
echo "  $ALIAS_LINE"
echo ""
echo "Run 'source $RC_FILE' or restart your shell, then use '$ALIAS_NAME' to launch."
