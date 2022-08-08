if [ $SPIN ]; then
  # Install Ripgrep for better code searching: `rg <string>` to search. Obeys .gitignore
  sudo apt-get install -y ripgrep
fi

sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"


ln -sf ~/dotfiles/.zshrc ~/.zshrc
