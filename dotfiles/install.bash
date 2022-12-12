#!/usr/bin/env bash

wget https://github.com/EEKIM10/EEKIM10/raw/master/dotfiles/.zshrc -O ~/.zshrc
curl -V > /dev/null 2> /dev/null || sudo apt install curl || sudo pacman -S curl || (echo 'Unable to install curl' && exit 1)
bash -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
