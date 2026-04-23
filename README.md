# Dotfiles

Fresh Debian/Ubuntu machine:

```zsh
sudo apt update && sudo apt upgrade -y
sudo apt install -y git neovim wget curl zsh unzip file procps
sudo apt-get install -y build-essential
chsh -s "$(command -v zsh)"
exec zsh
```

When `zsh-newuser-install` appears, press `q`.

Clone the repo wherever you want, for example:

```zsh
git clone https://github.com/nocdn/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

Install Homebrew on Linux:

```zsh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
```

Install the tools used by the zsh config:

```zsh
brew install eza fzf zoxide
```

Install the plugins this repo expects from Git:

```zsh
mkdir -p ~/.zsh
git clone https://github.com/romkatv/zsh-defer ~/.zsh/zsh-defer
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
ln -sfn ~/dotfiles/.zsh/functions.zsh ~/.zsh/functions.zsh
```

Pick the zsh config you want and symlink it:

Linux:

```zsh
ln -sfn ~/dotfiles/linux/.zshrc ~/.zshrc
exec zsh
```

macOS:

```zsh
ln -sfn ~/dotfiles/macos/.zshrc ~/.zshrc
exec zsh
```

If you pull new changes later:

```zsh
cd ~/dotfiles
git pull
exec zsh
```

Install runtimes:

```zsh
PROFILE=/dev/null bash -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash'
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
nvm install --lts
nvm alias default 'lts/*'
```

Install Bun:

```zsh
curl -fsSL https://bun.com/install | bash
```

Install zerobrew:

```zsh
curl -fsSL https://zerobrew.rs/install | bash -s -- --no-modify-path
```

Reload and verify:

```zsh
exec zsh
node -v
npm -v
bun --version
zb --version
```
