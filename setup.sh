# Used to install only for spin
# if [ $SPIN ]; then
#   # Install Ripgrep for better code searching: `rg <string>` to search. Obeys .gitignore
#   sudo apt-get install -y ripgrep
# fi

sudo apt-get install -y fzf ripgrep

# Install gum for interactive prompts
if command -v brew >/dev/null 2>&1; then
  brew install gum
elif command -v apt-get >/dev/null 2>&1; then
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
  echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
  sudo apt update && sudo apt install gum
elif command -v yum >/dev/null 2>&1; then
  echo '[charm]
name=Charm
baseurl=https://repo.charm.sh/yum/
enabled=1
gpgcheck=1
gpgkey=https://repo.charm.sh/yum/gpg.key' | sudo tee /etc/yum.repos.d/charm.repo
  sudo yum install gum
else
  echo "Warning: Could not install gum automatically. Please install manually."
fi

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


