# Linux Zsh config
# Common tools:
# - zsh
# - git
# - neovim
# - zoxide
# - fzf
# - docker
# - Homebrew
# - nvm
# - node + npm (via nvm)
# - bun
# - zerobrew (command: zb)
# - zsh-defer plugin at ~/.zsh/zsh-defer
# - zsh-autosuggestions plugin at ~/.zsh/zsh-autosuggestions or via Homebrew

[[ -f "$HOME/.config/zsh/secrets.zsh" ]] && source "$HOME/.config/zsh/secrets.zsh"

typeset -U path PATH fpath

path_prepend_if_dir() {
  [[ -d "$1" ]] && path=("$1" $path)
}

path_append_if_dir() {
  [[ -d "$1" ]] && path+=("$1")
}

if [[ -z "${ZEROBREW_ROOT:-}" ]]; then
  if [[ -d "/opt/zerobrew" ]]; then
    ZEROBREW_ROOT="/opt/zerobrew"
  elif [[ "$(uname -s)" == "Darwin" ]]; then
    ZEROBREW_ROOT="/opt/zerobrew"
  else
    ZEROBREW_ROOT="${XDG_DATA_HOME:-$HOME/.local/share}/zerobrew"
  fi
fi

if [[ -z "${ZEROBREW_PREFIX:-}" ]]; then
  if [[ "$(uname -s)" == "Darwin" ]]; then
    ZEROBREW_PREFIX="$ZEROBREW_ROOT"
  else
    ZEROBREW_PREFIX="$ZEROBREW_ROOT/prefix"
  fi
fi

export ZEROBREW_ROOT
export ZEROBREW_PREFIX
export BUN_INSTALL="$HOME/.bun"
export NVM_DIR="$HOME/.nvm"

path_prepend_if_dir "$HOME/.local/bin"
path_prepend_if_dir "$HOME/bin"
path_prepend_if_dir "$HOME/.cargo/bin"
path_prepend_if_dir "$HOME/go/bin"
path_prepend_if_dir "$BUN_INSTALL/bin"
path_prepend_if_dir "$ZEROBREW_PREFIX/bin"
path_append_if_dir "/home/linuxbrew/.linuxbrew/bin"
path_append_if_dir "/home/linuxbrew/.linuxbrew/sbin"
path_append_if_dir "/opt/homebrew/bin"
path_append_if_dir "/opt/homebrew/sbin"
path_append_if_dir "/usr/local/bin"
path_append_if_dir "/usr/local/sbin"

# Homebrew: reduce noisy hints and automatic side effects
export HOMEBREW_NO_ENV_HINTS=1
export HOMEBREW_NO_UPDATE_REPORT_NEW=1
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_EMOJI=1
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_INSTALL_CLEANUP=1

HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
mkdir -p "${HISTFILE:h}"
HISTSIZE=100000
SAVEHIST=100000

setopt APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt INTERACTIVE_COMMENTS
setopt AUTO_CD
setopt AUTO_MENU
setopt COMPLETE_IN_WORD
setopt NO_CASE_GLOB

export EDITOR="nvim"
export VISUAL="nvim"

PROMPT='%B%F{green}%n@%m%f%b:%B%F{blue}%~%f%b %(!.#.$) '

alias reload='source ~/.zshrc'

# git
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gap='git add -p'
alias gb='git branch'
alias gba='git branch -a'
alias gbd='git branch -d'
alias gc='git commit'
alias gca='git commit --amend'
alias gcam='git commit -am'
alias gcl='git clone'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gcm='git checkout main || git checkout master'
alias gclean='git clean -fd'
alias gd='git diff'
alias gds='git diff --staged'
alias gf='git fetch'
alias gl='git log --oneline --graph --decorate'
alias glast='git log -1 HEAD'
alias gp='git pull'
alias gpl='git pull --rebase'
alias gpf='git push --force-with-lease'
alias gpo='git push origin'
alias gps='git push'
alias gr='git remote -v'
alias grs='git reset --soft HEAD~1'
alias gs='git status -sb'
alias gsh='git show --stat'
alias gst='git stash'
alias gstp='git stash pop'
alias gsw='git switch'
alias gswc='git switch -c'
alias gundo='git restore --staged .'
alias gunstage='git restore --staged'

# docker
alias dc='docker compose'
alias dcup='docker compose up'
alias dcupd='docker compose up -d'
alias dcdown='docker compose down'
alias dclogs='docker compose logs -f'
alias dimg='docker images'
alias dexec='docker exec -it'
alias dsp='docker system prune -a -f'

[[ -f "${ZDOTDIR:-$HOME}/.zsh/functions.zsh" ]] && source "${ZDOTDIR:-$HOME}/.zsh/functions.zsh"

if [[ -f "$HOME/.zsh/zsh-defer/zsh-defer.plugin.zsh" ]]; then
  source "$HOME/.zsh/zsh-defer/zsh-defer.plugin.zsh"
fi

if [[ -d "${ZDOTDIR:-$HOME}/.zsh/completions" ]]; then
  fpath=("${ZDOTDIR:-$HOME}/.zsh/completions" $fpath)
fi

if [[ -f "$BUN_INSTALL/_bun" ]]; then
  fpath=("$BUN_INSTALL" $fpath)
fi

for zsh_site_functions in \
  "/home/linuxbrew/.linuxbrew/share/zsh/site-functions" \
  "/opt/homebrew/share/zsh/site-functions" \
  "/usr/local/share/zsh/site-functions"
do
  if [[ -d "$zsh_site_functions" ]]; then
    fpath=("$zsh_site_functions" $fpath)
  fi
done

ZSH_COMPDUMP="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-$ZSH_VERSION"
mkdir -p "${ZSH_COMPDUMP:h}"

if typeset -f zsh-defer >/dev/null 2>&1; then
  zsh-defer 'autoload -Uz compinit; compinit -C -d "$ZSH_COMPDUMP"'
else
  autoload -Uz compinit
  compinit -C -d "$ZSH_COMPDUMP"
fi

_zsh_autosuggestions_script=""
for candidate in \
  "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh" \
  "/home/linuxbrew/.linuxbrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh" \
  "/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh" \
  "/usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
do
  if [[ -f "$candidate" ]]; then
    _zsh_autosuggestions_script="$candidate"
    break
  fi
done

if [[ -n "$_zsh_autosuggestions_script" ]]; then
  ZSH_AUTOSUGGEST_STRATEGY=(history)
  ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
  ZSH_AUTOSUGGEST_MANUAL_REBIND=1

  if typeset -f zsh-defer >/dev/null 2>&1; then
    zsh-defer source "$_zsh_autosuggestions_script"
    zsh-defer _zsh_autosuggest_bind_widgets
  else
    source "$_zsh_autosuggestions_script"
    _zsh_autosuggest_bind_widgets
  fi
fi

_nvm_load() {
  unset -f nvm node npm npx

  local nvm_script
  for nvm_script in \
    "$NVM_DIR/nvm.sh" \
    "/home/linuxbrew/.linuxbrew/opt/nvm/nvm.sh" \
    "/opt/homebrew/opt/nvm/nvm.sh" \
    "/usr/local/opt/nvm/nvm.sh"
  do
    if [[ -s "$nvm_script" ]]; then
      . "$nvm_script"
      return 0
    fi
  done

  return 0
}

nvm() {
  _nvm_load
  if ! typeset -f nvm >/dev/null 2>&1; then
    echo "Error: nvm is not installed." >&2
    return 1
  fi
  nvm "$@"
}

node() {
  _nvm_load
  command node "$@"
}

npm() {
  _nvm_load
  command npm "$@"
}

npx() {
  _nvm_load
  command npx "$@"
}

if command -v zoxide >/dev/null 2>&1; then
  if typeset -f zsh-defer >/dev/null 2>&1; then
    zsh-defer 'eval "$(zoxide init zsh --cmd cd)"'
  else
    eval "$(zoxide init zsh --cmd cd)"
  fi
fi

mkcd() {
  [[ -n "$1" ]] || return 1
  mkdir -p -- "$1" && cd -- "$1"
}

extract() {
  [[ -f "$1" ]] || {
    echo "Usage: extract <archive>" >&2
    return 1
  }

  case "$1" in
    *.tar.bz2|*.tbz2) tar xjf "$1" ;;
    *.tar.gz|*.tgz) tar xzf "$1" ;;
    *.tar.xz|*.txz) tar xJf "$1" ;;
    *.tar.zst|*.tzst) tar --zstd -xf "$1" ;;
    *.tar) tar xf "$1" ;;
    *.bz2) bunzip2 "$1" ;;
    *.gz) gunzip "$1" ;;
    *.xz) unxz "$1" ;;
    *.zst) unzstd "$1" ;;
    *.zip) unzip "$1" ;;
    *.rar) unrar x "$1" ;;
    *.7z) 7z x "$1" ;;
    *)
      echo "extract: unsupported archive format: $1" >&2
      return 1
      ;;
  esac
}

hist() {
  command -v fzf >/dev/null 2>&1 || return 1

  local -a fzf_opts
  fzf_opts=(
    --tac
    --no-sort
    --height=40%
    --reverse
    --prompt='history> '
    --bind='ctrl-r:toggle-sort'
  )

  [[ "$1" == (-e|--exact) ]] && fzf_opts+=(--exact)

  local selected
  selected=$(fc -ln 1 | fzf "${fzf_opts[@]}") || return
  print -z -- "$selected"
}

_hist_widget() {
  command -v fzf >/dev/null 2>&1 || return 1

  local selected
  selected=$(
    fc -ln 1 | fzf --tac --no-sort \
      --query "${LBUFFER}" \
      --height=40% --reverse \
      --prompt='history> ' \
      --bind='ctrl-r:toggle-sort'
  ) || return

  BUFFER="$selected"
  CURSOR=${#BUFFER}
  zle redisplay
}
zle -N _hist_widget
bindkey '^R' _hist_widget

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line
