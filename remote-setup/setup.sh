ln -s /mnt/c/Users/akbb0 ./winhome
ln -s /mnt/c/Users/akbb0/curseforge/minecraft/Instances ./mcinstances

sudo apt update
sudo apt upgrade -y

sudo apt install -y wget curl zip neofetch python3 pgp gawk make

rm -f .bashrc
curl -O "https://raw.githubusercontent.com/Kayetic/dotfiles/master/.bashrc?token=GHSAT0AAAAAACTPZHLXG6SQFI3MADZGHEBCZTQU3YQ"

curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash

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
