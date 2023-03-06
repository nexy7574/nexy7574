#!/usr/bin/env bash
cd /tmp

if [ -f /usr/bin/apt ]; then
    export DEBIAN_FRONTEND=noninteractive
    export INSTALLER='sudo -E apt install -y'
    BUILD_PACKAGES='build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev curl llvm libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev'
elif [ -f /usr/bin/pacman ]; then
    export INSTALLER='sudo -E pacman -Sq --noconfirm --needed'
    BUILD_PACKAGES='base-devel openssl zlib xz tk'
else
    echo 'Unknown package manager. Please refer to https://github.com/pyenv/pyenv/wiki#suggested-build-environment.' > /dev/stderr
    export INSTALLER=""
    export BUILD_PACKAGES=""
    export NOBUILD="1"
    export NOPYTHON="1"
fi


echo "Installing requirements using '$INSTALLER'"
$INSTALLER git wget curl zsh rsync > /dev/null || exit 1
echo 'Removing existing installations'
rm -rf $HOME/.pyenv $HOME/.oh-my-zsh $HOME/.nvm
echo 'Installing oh-my-zsh'
export RUNZSH=no
export CHSH=no
sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -qO -)" || exit 3
mkdir -p $HOME/.oh-my-zsh/custom/themes
wget https://github.com/EEKIM10/EEKIM10/blob/master/dotfiles/.vimrc -qO $HOME/.oh-my-zsh/custom/themes/nexytech.zsh-theme || exit 69
echo 'Installing zsh-autosuggestions'
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting > /dev/null || exit 4
echo 'Installing zsh-autosuggestions'
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions > /dev/null || exit 5
echo 'Installing pyenv'
wget https://pyenv.run -qO - | bash > /dev/null || exit 7
if [ "$NOBUILD" !=  "1" ]; then
    echo 'Installing build dependencies'
    $INSTALLER $BUILD_PACKAGES || exit 13
fi;
if [ "$NOPYTHON" != "1" ]; then
    echo 'Installing python 3.11'
    $HOME/.pyenv/bin/pyenv install 3.11 -vs || exit 8
    $HOME/.pyenv/bin/pyenv global 3.11
    echo 'Installing pipx'
    $HOME/.pyenv/shims/python3 -m pip install --user pipx || exit 10
    echo 'Installing cli-utils via pipx'
    $HOME/.local/bin/pipx install git+https://github.com/EEKIM10/cli-utils --force --verbose --python $HOME/.pyenv/shims/python3 || exit 11
fi;
if [ "$NONVM" != "1" ]; then
    echo 'Installing nvm'
    wget -O- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash || exit 9
fi;
echo 'Downloading dotfiles repo'
FN="EEKIM10-DOTFILES-${RANDOM}"
git clone https://github.com/EEKIM10/EEKIM10.git $FN || exit 13
# cp $FN/dotfiles/.zshrc ~/.zshrc
rsync -azhP EEKIM10/dotfiles/.* ~/
sudo rsync -azhPr EEKIM10/dotfiles/NetworkManager/ /etc/NetworkManager/conf.d/
mkdir -p ~/.ssh
cp $FN/dotfiles/.ssh/config ~/.ssh/config
ping -c 1 -W 3 192.168.0.32 &> /dev/null
if [ $? -eq 0 ]; then
    echo 'Connecting to raspberry pi to get SSH key.'
    rsync -azhP pi@192.168.0.32:/home/pi/.ssh/id_rsa ~/.ssh/id_rsa
    rsync -azhP pi@192.168.0.32:/home/pi/.ssh/id_rsa.pub ~/.ssh/id_rsa.pub
fi
echo 'Setting ZSH as default shell'
chsh -s /usr/bin/zsh || exit 12
# echo 'Installing NetworkManager configs'
# sudo rsync -azhPRulc
echo 'Adding cheat.sh things'
mkdir ~/.zsh.d
curl https://cheat.sh/:zsh > ~/.zsh.d/_cht && echo 'fpath=(~/.zsh.d/ $fpath)' >> ~/.zshrc
echo 'Restarting shell'
zsh -l || exit 6
