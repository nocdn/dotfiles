source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

# history options
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# completion styling to help with zeoxide
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu no

alias fcat="fzf | xargs cat"
alias ls="eza"
alias la="eza -l --no-permissions --no-user --no-filesize"
alias laa="eza -la --no-permissions --no-user --no-filesize"

alias gs='git status'
alias ga='git add'
alias gp='git push'
alias gc='git commit'
alias cp='cp -iv'
alias mv='mv -iv'
alias cl='clear'
alias ipinfo='curl -s http://ip-api.com/json/ | jq "."'
alias act='source bin/activate'
alias nq='networkQuality'
alias zshconfig="code ~/.zshrc"
alias reload="source ~/.zshrc"

export EDITOR=/usr/bin/nano

export EXA_COLORS="di=38;5;117:ex=38;5;177:no=00:da=0;0:sn=0;0"


# Bind keys for history search (eg. only show matches from the current line)
autoload -Uz compinit && compinit
bindkey "^[[A" history-search-backward
bindkey "^[[B" history-search-forward

# Prompt customization
PS1="%F{white}%n %F{#F38BA8}%~ %F{white}%# %F"

eval "$(zoxide init --cmd cd zsh)"