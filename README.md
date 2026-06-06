# Dotfiles

These instructions install the zsh config from this repo. Commands assume the repo
lives at `$HOME/github/dotfiles`; change `DOTFILES_DIR` once if you want a
different location.

## Shared Repository Setup

If `git` is already available:

```zsh
export DOTFILES_DIR="$HOME/github/dotfiles"
mkdir -p "$(dirname "$DOTFILES_DIR")"
git clone https://github.com/nocdn/dotfiles.git "$DOTFILES_DIR"
cd "$DOTFILES_DIR"
```

If the repo is already cloned:

```zsh
export DOTFILES_DIR="$HOME/github/dotfiles"
cd "$DOTFILES_DIR"
```

On a fresh machine where `git` is not available yet, run the first package/tool
install block for your OS below, then come back and clone the repo.

## Linux Zsh Install

For a fresh Debian/Ubuntu machine, install the base packages and switch to zsh:

```zsh
sudo apt update && sudo apt upgrade -y
sudo apt install -y git neovim wget curl zsh unzip file procps build-essential
chsh -s "$(command -v zsh)"
exec zsh
```

When `zsh-newuser-install` appears, press `q`.

Install Homebrew on Linux:

```zsh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
```

Install the tools used by the Linux zsh config:

```zsh
brew install eza fzf zoxide
```

Install the zsh plugins and link the shared helper functions:

```zsh
mkdir -p ~/.zsh

if [[ ! -d ~/.zsh/zsh-defer ]]; then
  git clone https://github.com/romkatv/zsh-defer ~/.zsh/zsh-defer
fi

if [[ ! -d ~/.zsh/zsh-autosuggestions ]]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
fi

ln -sfn "$DOTFILES_DIR/.zsh/functions.zsh" ~/.zsh/functions.zsh
```

Install the Linux zshrc:

```zsh
ln -sfn "$DOTFILES_DIR/linux/.zshrc" ~/.zshrc
exec zsh
```

Install the runtimes expected by the Linux config:

```zsh
PROFILE=/dev/null bash -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash'
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
nvm install --lts
nvm alias default 'lts/*'

curl -fsSL https://bun.com/install | bash
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

## macOS Zsh Install

The macOS zshrc in this repo expects Apple Silicon Homebrew at `/opt/homebrew`.

Install Apple's command line tools if they are not already installed:

```zsh
xcode-select -p >/dev/null 2>&1 || xcode-select --install
```

Install Homebrew if needed, then load it in the current shell:

```zsh
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

eval "$(/opt/homebrew/bin/brew shellenv)"
```

Install the tools used by the macOS zsh config:

```zsh
brew install eza fzf zoxide neovim nvm jq yt-dlp postgresql@17
mkdir -p "$HOME/.nvm" "$HOME/.local/share/yt-dlp"
yt-dlp --help > "$HOME/.local/share/yt-dlp/manual.txt"
```

If you use the `yt-dl` helper, put `OPENAI_API_KEY` in
`$HOME/.config/zsh/secrets.zsh`.

Install the zsh plugins and link the shared helper functions:

```zsh
mkdir -p ~/.zsh

if [[ ! -d ~/.zsh/zsh-defer ]]; then
  git clone https://github.com/romkatv/zsh-defer ~/.zsh/zsh-defer
fi

if [[ ! -d ~/.zsh/zsh-autosuggestions ]]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
fi

ln -sfn "$DOTFILES_DIR/.zsh/functions.zsh" ~/.zsh/functions.zsh
```

Install the macOS zshrc:

```zsh
ln -sfn "$DOTFILES_DIR/macos/.zshrc" ~/.zshrc
exec zsh
```

Install the runtimes expected by the macOS config:

```zsh
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"
nvm install --lts
nvm alias default 'lts/*'

curl -fsSL https://bun.com/install | bash
```

Reload and verify:

```zsh
exec zsh
node -v
npm -v
bun --version
eza --version
fzf --version
zoxide --version
```

## Updating Later

```zsh
export DOTFILES_DIR="$HOME/github/dotfiles"
cd "$DOTFILES_DIR"
git pull --ff-only
exec zsh
```
