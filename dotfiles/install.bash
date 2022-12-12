#!/usr/bin/env bash

INSTALLER=$INSTALLER || "apt install -y"

echo 'Checking for wget'
wget -V > /dev/null 2> /dev/null || $INSTALLER wget sudo || (echo 'Unable to install wget' && exit 1)
echo 'Removing existing installations'
rm -rf $HOME/.pyenv $HOME/.oh-my-zsh $HOME/.nvm
echo 'Installing oh-my-zsh'
export RUNZSH=no
export CHSH=no
sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -qO -)" || exit 3
echo 'Installing zsh-autosuggestions'
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting > /dev/null || exit 4
echo 'Installing zsh-autosuggestions'
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions > /dev/null || exit 5
echo 'Installing pyenv'
wget https://pyenv.run -qO - | bash > /dev/null || exit 7
echo 'Installing build dependencies'
if [ -f /etc/debian_version ]; then
    sudo apt update; sudo apt install build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev curl llvm \
    libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
fi
if [ -f /etc/arch-release ]; then
  sudo pacman -Sy --needed base-devel openssl zlib xz tk
fi;
if [ -f /etc/alpine-release ]; then
  sudo apk add --no-cache git bash build-base libffi-dev openssl-dev bzip2-dev zlib-dev xz-dev readline-dev sqlite-dev tk-dev
fi
echo 'Installing python 3.11'
$HOME/.pyenv/bin/pyenv install 3.11.0 || exit 8
pyenv global 3.11.0
echo 'Installing nvm'
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash || exit 9
echo 'Installing pipx'
$HOME/.pyenv/shims/python3 -m pip install --user pipx || exit 10
echo 'Installing cli-utils via pipx'
$HOME/.local/bin/pipx install git+https://github.com/EEKIM10/cli-utils || exit 11
echo 'Downloading zsh config'
wget https://github.com/EEKIM10/EEKIM10/raw/master/dotfiles/.zshrc -qO ~/.zshrc || exit 2
echo 'Setting ZSH as default shell'
chsh -s $(which zsh) || exit 12
echo 'Restarting shell'
zsh -l || exit 6
