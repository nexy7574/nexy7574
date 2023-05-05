#!/usr/bin/zsh

zstyle :omz:plugins:ssh-agent quiet yes
printf 'Loading ZSH...\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b'
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
  ssh-agent
  git  # git is basically exclusively a dependency
  dotenv
  command-not-found
  python  # basically only used for the pygrep, py, ipython, and pyserver commmands
  rsync  # rsync-copy, rsync-move, rsync-update, rsync-synchronize
  themes  # on-the-fly theming via the theme command
  zsh-syntax-highlighting  # syntax highlighting <moderate impact on load time and CPU>
  zsh-autosuggestions  # autosuggestions <heavy impact on load time>
)
# ^ TheFuck plugin breaks `sudo`. See https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/thefuck#notes
# Extend fpath for custom plugins zsh-syntax-highlighting and zsh-autosuggestions
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src

# Source oh-my-zsh
source $ZSH/oh-my-zsh.sh

# Use vscode to edit files when not in SSH, otherwise VIM <333
if [[ -z $SSH_CONNECTION ]]; then
  export EDITOR='code --wait'
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
alias bomb=printf "%s\n" ':t(){ :|:& };:'
# Had to alias it to just echoing the command because SOMEONE ruined it smh

# Rootless docker
if [ -f "$XDG_RUNTIME_DIR/docker.sock" ]; then
  export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/docker.sock"
fi

function gi() { curl -sLw "\n" https://www.toptal.com/developers/gitignore/api/$@ ;}
alias spook="head -c 102400 /dev/urandom | aplay -r 384000 2>&1 >/dev/null;"
