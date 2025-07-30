#!/bin/bash

# ===============================================================================
# DOTFILES SETUP SCRIPT
# ===============================================================================
# Cross-platform setup for macOS and Linux - Direct loading (no lazy loading)

set -e  # Exit on error

echo "🚀 Setting up dotfiles..."

# Detect platform
OS="$(uname -s)"
case "${OS}" in
    Linux*)     PLATFORM=Linux;;
    Darwin*)    PLATFORM=Mac;;
    *)          PLATFORM="UNKNOWN:${OS}"
esac

echo "📱 Detected platform: $PLATFORM"

# ===============================================================================
# INSTALL DEPENDENCIES
# ===============================================================================

install_deps() {
    echo "📦 Installing dependencies..."

    if [[ "$PLATFORM" == "Mac" ]]; then
        # macOS with Homebrew
        if ! command -v brew >/dev/null 2>&1; then
            echo "🍺 Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi

        echo "🍺 Installing packages with Homebrew..."
        brew install gum fzf ripgrep starship fd

    elif [[ "$PLATFORM" == "Linux" ]]; then
        # Linux with package managers
        if command -v apt-get >/dev/null 2>&1; then
            echo "🐧 Installing packages with apt..."
            sudo apt-get update
            sudo apt-get install -y fzf ripgrep curl

            # Install gum
            sudo mkdir -p /etc/apt/keyrings
            curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
            echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
            sudo apt update && sudo apt install gum

            # Install starship
            curl -sS https://starship.rs/install.sh | sh -s -- -y

        elif command -v yum >/dev/null 2>&1; then
            echo "🐧 Installing packages with yum..."
            sudo yum install -y fzf ripgrep curl

            # Install gum
            echo '[charm]
name=Charm
baseurl=https://repo.charm.sh/yum/
enabled=1
gpgcheck=1
gpgkey=https://repo.charm.sh/yum/gpg.key' | sudo tee /etc/yum.repos.d/charm.repo
            sudo yum install gum

            # Install starship
            curl -sS https://starship.rs/install.sh | sh -s -- -y
        else
            echo "❌ Unsupported Linux package manager"
            exit 1
        fi
    else
        echo "❌ Unsupported platform: $PLATFORM"
        exit 1
    fi
}

install_zsh() {
    echo "🐚 Installing Oh My Zsh..."
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        echo "✅ Oh My Zsh already installed"
    fi

    echo "🔌 Installing zsh plugins..."
    # zsh-autosuggestions
    if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    fi

    # zsh-syntax-highlighting
    if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    fi
}

create_symlinks() {
    echo "🔗 Creating symlinks..."

    # Create necessary directories
    mkdir -p ~/.config

    # Create symlinks
    ln -sf ~/Documents/dotfiles/.zshrc ~/.zshrc
    ln -sf ~/Documents/dotfiles/.gitconfig ~/.gitconfig
    ln -sf ~/Documents/dotfiles/starship.toml ~/.config/starship.toml

    # Platform-specific symlinks
    if [[ "$PLATFORM" == "Mac" ]]; then
        # Ghostty config (macOS only)
        mkdir -p "$HOME/Library/Application Support/com.mitchellh.ghostty"
        ln -sf ~/Documents/dotfiles/ghostty-config "$HOME/Library/Application Support/com.mitchellh.ghostty/config"
    fi

    # Create functions directory symlink
    mkdir -p ~/.zsh
    ln -sf ~/Documents/dotfiles/functions ~/.zsh/functions

    echo "✅ Symlinks created successfully"
}

setup_shopify() {
    echo "🏪 Setting up Shopify-specific tools..."
    # Only run if in Shopify environment
    if command -v cart >/dev/null 2>&1; then
        cart insert history
        echo "✅ Shopify history setup complete"
    else
        echo "⚠️  Skipping Shopify tools (not in Shopify environment)"
    fi
}

# ===============================================================================
# MAIN INSTALLATION
# ===============================================================================

echo "🎯 Starting installation..."

# Run installation steps
install_deps
install_zsh
create_symlinks
setup_shopify

echo ""
echo "🎉 Dotfiles setup complete!"
echo ""
echo "📝 Next steps:"
echo "   1. Restart your terminal or run: exec zsh"
echo "   2. All tools load immediately - no lazy loading issues!"
echo "   3. Your shell functions are available: devtree, check_pr_shipped, etc."
echo "   4. All configs are symlinked - edit files in ~/Documents/dotfiles/"
echo ""


