# Dotfiles

Fresh Debian/Ubuntu machine:

```zsh
sudo apt update && sudo apt upgrade -y
sudo apt install -y git neovim wget curl zsh unzip file procps
sudo apt-get install -y build-essential
chsh -s "$(command -v zsh)"
exec zsh
```

Install Homebrew on Linux:

```zsh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
```

Install the tools used by the zsh config:

```zsh
brew install chezmoi eza fzf zoxide zsh-autosuggestions
```

Install the plugin this repo expects from Git:

```zsh
mkdir -p ~/.zsh
git clone https://github.com/romkatv/zsh-defer ~/.zsh/zsh-defer
```

Apply the dotfiles:

```zsh
chezmoi init --apply YOUR_GITHUB_USERNAME
exec zsh
```

Install nvm, then Node LTS and npm:

```zsh
PROFILE=/dev/null bash -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash'
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
nvm install --lts
nvm alias default 'lts/*'
node -v
npm -v
```

Install Bun:

```zsh
curl -fsSL https://bun.com/install | bash
exec zsh
bun --version
```

Install zerobrew:

```zsh
curl -fsSL https://zerobrew.rs/install | bash -s -- --no-modify-path
exec zsh
zb --version
```
