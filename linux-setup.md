## zsh installation

```bash
sudo apt install zsh && chsh -s $(which zsh)
```
Then relog into session

Add this to zshrc:
```
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
```

## zsh syntax highlighting and zsh-autosuggestions

```bash
brew install zsh-syntax-highlighting
echo "source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc
```

```bash
brew install zsh-autosuggestions
```

Add to end of zshrc:
```bash
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
```

Then start a new terminal session



## personal aliases and installation

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
alias nq='networkQuality'
alias zshconfig="code ~/.zshrc"
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
# PS1="%F{white}%n %F{#F38BA8}%~ %F{white}%# %F"
# light theme
PS1="%F{black}%n %F{#B75D74}%~ %F{black}%# %F"

source <(fzf --zsh)

# zeoxide initialization
eval "$(zoxide init --cmd cd zsh)"
```

downloading the needed programs:

```bash
brew install fzf eza jq wget xargs zoxide
```
