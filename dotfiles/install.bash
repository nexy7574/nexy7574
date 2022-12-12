#!/usr/bin/env bash

echo 'Checking for wget'
wget -V > /dev/null 2> /dev/null || sudo apt install wget || sudo pacman -S wget || (echo 'Unable to install wget' && exit 1)
echo 'Installing oh-my-zsh'
export RUNZSH=no
sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -qO -)" || exit 3
echo 'Installing zsh-autosuggestions'
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting || exit 4
echo 'Installing zsh-autosuggestions'
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions || exit 5
echo 'Installing pyenv'
wget https://pyenv.run -qO - | bash || exit 7
echo 'Installing python 3.11'
$HOME/.pyenv/shims/pyenv install 3.11.0 || exit 8
echo 'Installing nvm'
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash || exit 9
echo 'Downloading zsh config'
wget https://github.com/EEKIM10/EEKIM10/raw/master/dotfiles/.zshrc -qO ~/.zshrc || exit 2
echo 'Restarting shell'
zsh -l || exit 6
