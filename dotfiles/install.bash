#!/usr/bin/env bash

echo 'Checking for wget'
wget -V > /dev/null 2> /dev/null || sudo apt install wget || sudo pacman -S wget || (echo 'Unable to install wget' && exit 1)
echo 'Downloading zsh config'
wget https://github.com/EEKIM10/EEKIM10/raw/master/dotfiles/.zshrc -O ~/.zshrc || exit 2
echo 'Installing oh-my-zsh'
export RUNZSH=no
sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)" || exit 3
echo 'Installing zsh-autosuggestions'
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting || exit 4
echo 'Installing zsh-autosuggestions'
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions || exit 5
echo 'Restarting shell'
zsh -l || exit 6
