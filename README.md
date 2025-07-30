# 🚀 Dotfiles

Personal dotfiles for macOS and Linux with cross-platform setup.

## ✨ Features

- **🐚 Enhanced Zsh** with Oh My Zsh, autosuggestions, and syntax highlighting
- **🌟 Starship Prompt** with git status and performance indicators
- **🛠️ Custom Functions** for development workflow (devtree, check_pr_shipped, etc.)
- **🎨 Ghostty Terminal** configuration (macOS)
- **🔍 FZF & Ripgrep** for fast file/text search
- **📦 Gum** for beautiful CLI prompts
- **🔗 Symlinked** - edit once, apply everywhere

## 🎯 Quick Setup (New Computer)

```bash
# 1. Clone dotfiles
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/Documents/dotfiles

# 2. Run setup script
cd ~/Documents/dotfiles
chmod +x setup.sh
./setup.sh

# 3. Restart terminal
exec zsh
```

## 📁 What Gets Installed

### Dependencies

- **gum** - Interactive CLI prompts
- **fzf** - Fuzzy finder
- **ripgrep** - Fast text search
- **starship** - Cross-shell prompt
- **fd** - Fast file finder (macOS)

### Configs Symlinked

- `~/.zshrc` → `~/Documents/dotfiles/.zshrc`
- `~/.gitconfig` → `~/Documents/dotfiles/.gitconfig`
- `~/.config/starship.toml` → `~/Documents/dotfiles/starship.toml`
- `~/.zsh/functions/` → `~/Documents/dotfiles/functions/`
- Ghostty config (macOS only)

### Custom Functions

- `devtree` - Interactive worktree management with 5 modes
- `check_pr_shipped` - Check if PR is shipped
- `billing_setup`, `change_plan`, `create_shop` - Shopify tools
- `tree_status` - Enhanced tree status

## 🛠️ Usage

### Devtree Function

```bash
devtree                    # Interactive mode with 5 options
devtree list              # List all trees
devtree remove my-tree    # Remove specific tree
devtree admin-web pr-123  # Direct: dev cd admin-web -t pr-123
```

### Editing Dotfiles

```bash
# Edit any config file in ~/Documents/dotfiles/
vim ~/Documents/dotfiles/.zshrc

# Changes apply immediately (no restart needed)
# All changes are version controlled with git
```

## 📁 Modular Structure

```
dotfiles/
├── .zshrc                    # Main configuration (loads modules)
├── zsh/
│   ├── aliases.zsh          # All aliases
│   ├── functions.zsh        # General functions
│   └── shopify.zsh          # Shopify-specific tools
├── functions/               # External function files
├── ghostty-config          # Terminal configuration
└── starship.toml           # Prompt configuration
```

**Local Overrides:**

- `~/.zshrc.local` - Machine-specific settings (not in git)

## 🔄 Reorganizing Existing Setup

If you have an existing `.zshrc`, reorganize it into the modular structure:

```bash
cd ~/Documents/dotfiles
./migrate-zshrc.sh
```

This will:

- ✅ Back up your current `.zshrc`
- ✅ Split it into organized modules
- ✅ Create `.zshrc.local` for personal settings
- ✅ Update `.gitignore` appropriately

## 🔧 Platform Support

- ✅ **macOS** (Homebrew)
- ✅ **Linux** (apt/yum)
- ✅ **Shopify Spin** environments
- ⚠️ **Windows** (not tested)

## 📝 Manual Steps (if needed)

```bash
# If setup fails, run manually:
brew install gum fzf ripgrep starship fd  # macOS
# or
sudo apt install fzf ripgrep curl         # Linux

# Install Starship (Linux)
curl -sS https://starship.rs/install.sh | sh
```
