sudo apt update
sudo apt upgrade -y

sudo apt install -y nano wget curl zip neofetch python3 pgp gawk make fzf git

git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions

echo 'deb http://download.opensuse.org/repositories/shells:/zsh-users:/zsh-syntax-highlighting/Raspbian_9.0/ /' | sudo tee /etc/apt/sources.list.d/shells:zsh-users:zsh-syntax-highlighting.list
curl -fsSL https://download.opensuse.org/repositories/shells:zsh-users:zsh-syntax-highlighting/Raspbian_9.0/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/shells_zsh-users_zsh-syntax-highlighting.gpg > /dev/null
sudo apt update
sudo apt install zsh-syntax-highlighting

curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash

sudo mkdir -p /etc/apt/keyrings
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
sudo apt update
sudo apt install -y eza

add_to_path() {
  # Get the current user's home directory
  USER_HOME=$(eval echo ~"$USER")
  LOCAL_BIN_PATH="$USER_HOME/.local/bin"

  # Detect the active shell
  CURRENT_SHELL=$(basename "$SHELL")

  # Determine which configuration file to update
  if [[ "$CURRENT_SHELL" == "bash" ]]; then
    CONFIG_FILE="$USER_HOME/.bashrc"
  elif [[ "$CURRENT_SHELL" == "zsh" ]]; then
    CONFIG_FILE="$USER_HOME/.zshrc"
  else
    echo "Unsupported shell: $CURRENT_SHELL"
    return 1
  fi

  # Check if the path is already in the file
  if ! grep -q "export PATH=.*$LOCAL_BIN_PATH" "$CONFIG_FILE"; then
    # Add an empty line before the path export
    echo "" >> "$CONFIG_FILE"
    # Add the path to the configuration file
    echo "export PATH=\"\$PATH:$LOCAL_BIN_PATH\"" >> "$CONFIG_FILE"
    echo "Added $LOCAL_BIN_PATH to $CONFIG_FILE"
  else
    echo "$LOCAL_BIN_PATH is already in $CONFIG_FILE"
  fi

  # Check if the zoxide init line is already in the file
  if ! grep -q "eval \"\$(zoxide init --cmd cd $CURRENT_SHELL)\"" "$CONFIG_FILE"; then
    # Add the zoxide init line to the configuration file
    echo "eval \"\$(zoxide init --cmd cd $CURRENT_SHELL)\"" >> "$CONFIG_FILE"
    echo "Added zoxide init to $CONFIG_FILE"
  else
    echo "zoxide init is already in $CONFIG_FILE"
  fi
}

# Call the function
add_to_path

git clone https://github.com/catppuccin/zsh-syntax-highlighting.git
cd zsh-syntax-highlighting/themes/
cp -v catppuccin_mocha-zsh-syntax-highlighting.zsh ~/.zsh/

echo "source ~/.zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc

echo "source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc