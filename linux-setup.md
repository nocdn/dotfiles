## Zsh installation

```bash
sudo apt update && sudo apt upgrade -y && sudo apt install -y zsh curl git zip clang && chsh -s $(which zsh)
```
Then relog into session

Add this to zshrc:
```
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
```

## Zsh syntax highlighting and zsh-autosuggestions

Install homebrew first
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

```bash
brew install zsh-syntax-highlighting
echo "source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc
```

```bash
brew install zsh-autosuggestions
```

Add to end of zshrc:
```bash
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
```

Then start a new terminal session



## Personal aliases and installation

Paste all this into your zshrc:
```bash
# set history options
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# set completion options
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu no

# aliases
alias act='source bin/activate'
alias zshconfig="nvim ~/.zshrc"
alias reload="source ~/.zshrc"
alias hist="cat .zsh_history | fzf | pbcopy"

alias fcat="fzf | xargs cat"
alias ls="eza"
alias la="eza -l --no-permissions --no-user --no-filesize --sort=date"
alias laa="eza -la --no-permissions --no-user --sort=date"

alias gs='git status'
alias ga='git add'
alias gp='git push'
alias gc='git commit'
alias cp='cp -iv'
alias mv='mv -iv'
alias cl='clear'
alias ipinfo='curl -s http://ip-api.com/json/ | jq "."'
alias python='python3.11'

export EDITOR=/home/linuxbrew/.linuxbrew/bin/nvim

autoload -z edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line

export EXA_COLORS="di=38;5;117:ex=38;5;177:no=00:da=0;0:sn=0;0"

# bind keys for history search (eg. only show matches from the current line)
autoload -Uz compinit && compinit
bindkey "^[[A" history-search-backward
bindkey "^[[B" history-search-forward

# Prompt customization
# dark theme
# PS1="%F{white}%n@%m %F{#F38BA8}%~ %F{white}%# %F"
# light theme
# PS1="%F{black}%n@%m %F{#B75D74}%~ %F{black}%# %F"
# universal (auto adapts to background color of terminal)
PS1="%F{reset}%n@%m %F{#B75D74}%~ %F{reset}%# %F"

source <(fzf --zsh)

# zeoxide initialization
eval "$(zoxide init --cmd cd zsh)"
```

## Downloading the needed programs:

```bash
brew install fzf eza jq wget zoxide rg fd nvim
```

## Docker installation
Setting up the apt repositories:
```bash
sudo apt-get update && sudo apt-get install ca-certificates curl && sudo install -m 0755 -d /etc/apt/keyrings && sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc && sudo chmod a+r /etc/apt/keyrings/docker.asc && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null && sudo apt-get update
```
Actually installing docker:
```bash
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```
(Optional) portainer installation:
```
sudo docker pull portainer/portainer-ce:latest
```
```
sudo docker run -d -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest
```

## Npm and Bun
Node version manager installation
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
```
Then reload the shell, and run:
```bash
nvm install node
```
For bun:
```bash
curl -fsSL https://bun.sh/install | bash
```

## Uv installation
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```
