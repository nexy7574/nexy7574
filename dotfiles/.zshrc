export PYENV_ROOT="$HOME/.pyenv"
export PATH="$HOME/.local/bin:$PYENV_ROOT/bin:$PATH"
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="fino-time"
COMPLETION_WAITING_DOTS="true"
HIST_STAMPS="dd.mm.yyyy"
plugins=(git nvm sudo command-not-found python rsync zsh-syntax-highlighting zsh-autosuggestions)
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src
source $ZSH/oh-my-zsh.sh
export LANG=en_GB.UTF-8
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='code'
else
  export EDITOR='vim'
fi
export ARCHFLAGS="-arch x86_64"
command -v pyenv >/dev/null
eval "$(pyenv init -)"
export GPG_TTY=$(tty)
autoload -U bashcompinit
bashcompinit
eval "$(register-python-argcomplete pipx)"
source /usr/share/nvm/init-nvm.sh
