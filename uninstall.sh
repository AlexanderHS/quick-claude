#!/bin/bash
# Uninstall quick-claude alias

# Detect shell config file
if [[ -n "$ZSH_VERSION" ]] || [[ "$SHELL" == */zsh ]]; then
    RC_FILE="$HOME/.zshrc"
else
    RC_FILE="$HOME/.bashrc"
fi

# Check if installed
if ! grep -q "# quick-claude" "$RC_FILE" 2>/dev/null; then
    echo "quick-claude not found in $RC_FILE"
    exit 0
fi

# Remove the alias and comment
sed -i '/# quick-claude/d' "$RC_FILE"
sed -i '/alias.*quick-claude/d' "$RC_FILE"

echo "Uninstalled! Removed alias from $RC_FILE"
echo "Run 'source $RC_FILE' or restart your shell."
