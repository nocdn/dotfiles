1. Install Apple's command line tools

```bash
xcode-select --install
```

2. Clone this repo into a dotfiles repo on your local machine

```bash
git clone https://github.com/Kayetic/dotfiles.git ~/.dotfiles
```

3. Create symbolic links to the dotfiles in your home directory

```bash
ln -s ~/.dotfiles/.zshrc ~/.zshrc
ln -s ~/.dotfiles/.npmrc ~/.npmrc
ln -s ~/.dotfiles/.gitconfig ~/.gitconfig
ln -s ~/.dotfiles/.gitignore_global ~/.gitignore_global
```

4. Install Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

5. Install Homebrew packages

```bash
brew bundle --file ~/.dotfiles/Brewfile
```

5.5.

```bash
cd ~/.dotfiles && brew bundle
```
