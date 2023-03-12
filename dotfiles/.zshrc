#!/usr/bin/zsh

# Make custom scripts directory if it doesn't exist
mkdir -p $HOME/.local/bin/custom

# Set up pyenv & PATH
export LANG=en_GB.UTF-8
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$HOME/.local/bin/custom:$HOME/.local/bin:$PYENV_ROOT/bin:$PATH"

# Set up oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"

# Set theme to custom one in $HOME/.oh-my-zsh/custom/themes/nexytech.zsh_theme
# If it doesn't exist, default to nanotech (base) theme.
if [ ! -f $HOME/.oh-my-zsh/custom/themes/nexytech.zsh-theme ]; then
  ZSH_THEME="nanotech"
  THEME_LOC='https://github.com/EEKIM10/EEKIM10/raw/master/dotfiles/nexytech.zsh-theme'
  THEME_CMD="curl -Lo $HOME/.oh-my-zsh/custom/themes/nexytech.zsh-theme '$THEME_LOC'"
  printf "Nexytech theme missing - consider downloading with: $THEME_CMD"
else
  ZSH_THEME="nexytech"
fi;

# Enable completion dots, for slower machines
COMPLETION_WAITING_DOTS="true"

# Swap from Amer***n formatting to Bri'ish (the correct date format)
HIST_STAMPS="dd.mm.yyyy"

# Load plugins in priority order
plugins=(
  sudo
  git
  nvm
  command-not-found
  python
  rsync
  themes
  zsh-syntax-highlighting
  zsh-autosuggestions
)
# Extend fpath for custom plugins zsh-syntax-highlighting and zsh-autosuggestions
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src

# Source oh-my-zsh
source $ZSH/oh-my-zsh.sh

# Use vscode to edit files when not in SSH, otherwise VIM <333
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='code'
else
  export EDITOR='vim'
fi

export ARCHFLAGS="-arch x86_64"

# Load pyenv
command -v pyenv >/dev/null && eval "$(pyenv init -)"

export GPG_TTY=$(tty)

# Load bashcompinit for pipx autocompletion
autoload -U bashcompinit
bashcompinit
eval "$(register-python-argcomplete pipx)"

# Load nvm if possible
[ -z "/usr/share/nvm/init-nvm.sh" ] && source /usr/share/nvm/init-nvm.sh

# Fun little command to auto-type bash bomb
# alias bomb='kdesu -d --noignorebutton -n bash -c ":t(){ :|:& };:"'
alias bomb=printf "%s" ':t(){ :|:& };:'
