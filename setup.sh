if [ $SPIN ]; then
  # Install Ripgrep for better code searching: `rg <string>` to search. Obeys .gitignore
  sudo apt-get install -y ripgrep
fi


ln -sf ~/dotfiles/.zshrc ~/.zshrc