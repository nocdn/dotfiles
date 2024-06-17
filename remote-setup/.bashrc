# personal aliases
alias bashconfig="nano ~/.bashrc"
alias reload="source ~/.bashrc"
alias cl="clear"
alias fcat="fzf | xargs cat"
alias gs='git status'
alias ga='git add'
alias gp='git push'
alias gc='git commit'
alias cp='cp -iv'
alias mv='mv -iv'
alias cl='clear'
alias ipinfo='curl -s http://ip-api.com/json/ | jq "."'
export EDITOR=/usr/bin/nano
# for eza
alias la="eza -l --no-permissions --no-user --no-filesize"
alias laa="eza -l --no-permissions --no-user --no-filesize -a"
export EXA_COLORS="di=38;5;117:ex=38;5;177:no=00:da=0;0:sn=0;0"

# Prompt customization
PS1="\[\e[97m\]\u \[\e[38;5;175m\]\w \[\e[97m\]\$ \[\e[0m\]"
