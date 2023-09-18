# Used to install only for spin
# if [ $SPIN ]; then
#   # Install Ripgrep for better code searching: `rg <string>` to search. Obeys .gitignore
#   sudo apt-get install -y ripgrep
# fi

sudo apt-get install -y fzf ripgrep

sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

ln -sf ~/dotfiles/.zshrc ~/.zshrc


# ----------------------
# Oh my zsh pluginx
# ----------------------

# zsh-autosuggestions
# https://github.com/zsh-users/zsh-autosuggestions/blob/master/INSTALL.md#oh-my-zsh
# Syntax completion for zsh
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting


# history
cart insert history


