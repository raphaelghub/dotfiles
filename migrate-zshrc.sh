#!/bin/bash

# ===============================================================================
# ZSHRC REORGANIZATION MIGRATION SCRIPT
# ===============================================================================

set -e

echo "🚀 Migrating to organized .zshrc structure..."

DOTFILES_DIR="$HOME/Documents/dotfiles"
BACKUP_DIR="$DOTFILES_DIR/backup-$(date +%Y%m%d_%H%M%S)"

# Create backup
echo "📦 Creating backup at $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"
cp "$DOTFILES_DIR/.zshrc" "$BACKUP_DIR/.zshrc.original"

# Create zsh directory
echo "📁 Creating zsh module directory"
mkdir -p "$DOTFILES_DIR/zsh"

# Replace .zshrc with clean version
echo "✨ Installing new modular .zshrc"
cp "$DOTFILES_DIR/zshrc-clean" "$DOTFILES_DIR/.zshrc"

# Clean up temporary files
rm -f "$DOTFILES_DIR/zshrc-clean"

# Create .zshrc.local template in home directory (if it doesn't exist)
if [[ ! -f "$HOME/.zshrc.local" ]]; then
  echo "📝 Creating .zshrc.local template"
  cp "$DOTFILES_DIR/zshrc.local.template" "$HOME/.zshrc.local"
  echo "# Local overrides - edit as needed" >> "$HOME/.zshrc.local"
fi

# Update .gitignore
echo "🔧 Updating .gitignore"
if ! grep -q "\.zshrc\.local" "$DOTFILES_DIR/.gitignore" 2>/dev/null; then
  echo "
# Local machine-specific overrides (never commit)
.zshrc.local
**/backup-*/" >> "$DOTFILES_DIR/.gitignore"
fi

echo ""
echo "✅ Migration complete!"
echo ""
echo "📋 What changed:"
echo "   • .zshrc is now modular and organized"
echo "   • Aliases moved to zsh/aliases.zsh"
echo "   • Functions moved to zsh/functions.zsh"
echo "   • Shopify-specific code in zsh/shopify.zsh"
echo "   • Local overrides go in ~/.zshrc.local"
echo "   • Original backed up to $BACKUP_DIR"
echo ""
echo "📝 Next steps:"
echo "   1. Review ~/.zshrc.local for any needed customizations"
echo "   2. Test: source ~/.zshrc"
echo "   3. Verify: devtree --help"
echo "   4. Commit the new structure: git add . && git commit -m 'Reorganize zshrc into modular structure'"
echo ""
echo "🔍 File structure:"
echo "   $DOTFILES_DIR/.zshrc (main config)"
echo "   $DOTFILES_DIR/zsh/aliases.zsh (all aliases)"
echo "   $DOTFILES_DIR/zsh/functions.zsh (general functions)"
echo "   $DOTFILES_DIR/zsh/shopify.zsh (Shopify-specific)"
echo "   ~/.zshrc.local (local machine overrides - not in git)"
echo ""
