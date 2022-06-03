#!/usr/bin/env bash

# Disallow running with sudo or su
##########################################################
if [ "$EUID" -eq 0 ]
  then printf "\033[1;101mNein, Nein, Nein!! Please do not run this script as root (no su or sudo)! \033[0m \n";
  exit;
fi

###############################################################
## HELPERS
###############################################################
title() {
    printf "\033[1;42m";
    printf '%*s\n'  "${COLUMNS:-$(tput cols)}" '' | tr ' ' ' ';
    printf '%-*s\n' "${COLUMNS:-$(tput cols)}" "  # $1" | tr ' ' ' ';
    printf '%*s'  "${COLUMNS:-$(tput cols)}" '' | tr ' ' ' ';
    printf "\033[0m";
    printf "\n\n";
}

breakLine() {
    printf "\n";
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -;
    printf "\n\n";
    sleep .5;
}

notify() {
    printf "\n";
    printf "\033[1;46m $1 \033[0m \n";
}

curlToFile() {
    notify "Downloading: $1 ----> $2";
    sudo curl -fSL "$1" -o "$2";
}

###############################################################
## GLOBALS
###############################################################
repoUrl="https://raw.githubusercontent.com/tcook20/crostini-web-dev-packages/master/";
GIT_EDITOR="code"
HOMEBREW_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
NVM_URL="https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh"
gotPhp=0;
gotNode=0;
gotGoLang=0;

###############################################################
## REPOSITORIES
###############################################################

# Docker CE
repoDocker() {
    if [ ! -f /var/lib/dpkg/info/docker-ce.list ]; then
        notify "Adding Docker repository";
        curl -fsSL "https://download.docker.com/linux/debian/gpg" | sudo apt-key add -;
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable";
    sudo groupadd docker;
    sudo usermod -aG docker $USER;
    fi
}

# MS Edge
repoMSEdge() {
    if [ ! -f /etc/apt/sources.list.d/microsoft-edge.list ]; then
        notify "Adding MS Edge repository";
        curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg;
        sudo install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/;
        sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/edge stable main" > /etc/apt/sources.list.d/microsoft-edge.list';
        sudo rm microsoft.gpg;
    fi
}

# VS Code
repoVsCode() {
    if [ ! -f /etc/apt/sources.list.d/vscode.list ]; then
        notify "Adding VS Code repository";
        curl "https://packages.microsoft.com/keys/microsoft.asc" | gpg --dearmor > microsoft.gpg;
        sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/;
        echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list;
    fi
}

###############################################################
## INSTALLATION
###############################################################

# Homebrew
installHomebrew() {
    title "Installing Homebrew";
    sudo apt-get install build-essential;
    /bin/bash -c "$(curl -fsSL $HOMEBREW_URL)";
    echo 'eval "$(~/.linuxbrew/bin/brew shellenv)"' >> ~/.profile;
    eval "$(~/.linuxbrew/bin/brew shellenv)";
    brew update;
    breakLine;
}

# Composer
installComposer() {
    title "Installing Composer";
    brew install composer;
    breakLine;
}

# DBeaver
installDbeaver() {
    title "Installing DBeaver SQL Client";
    brew install --cask dbeaver-community;
    breakLine;
}

# Docker
installDocker() {
    title "Installing Docker CE with Docker Compose";
    brew install docker;
    brew install docker-compose;
    breakLine;
}

# Firefox
installFirefox() {
    title "Installing Firefox";
    brew install --cask firefox;
    breakLine;
}

# Firefox Developer Edition
installFirefoxDeveloper() {
    title "Installing Firefox Developer Edition";
    brew tap homebrew/cask-versions;
    brew install --cask firefox-developer-edition;
    breakLine;
}

# Git
installGit() {
    title "Installing Git";
    brew install git;
    read -p 'Enter your name: ' GIT_USER
    read -p 'Enter your email: ' GIT_EMAIL
    git config --global core.editor "$GIT_EDITOR --wait"
    git config --global core.ignorecase false
    git config --global pull.rebase false
    git config --global user.email ${GIT_EMAIL}
    git config --global user.name ${GIT_USER}
    git config --global credential.helper store
    breakLine;
}

# GitKraken
installGitkraken() {
    title "Installing GitKraken";
    brew install --cask gitkraken;
    breakLine;
}

# Gnome Software Center
installSoftwareCenter() {
    sudo apt install -y gnome-software gnome-packagekit;
}

# GoLang
installGoLang() {
    title "Installing GoLang";
    brew install go;
    gotGoLang=1;
    breakLine;
}

# Lando
installLando() {
    title "Installing Lando";
    brew install --cask lando;
    breakLine;
}

# Local by Flywheel
installLocalbyFlywheel() {
    title "Installing Local by Flywheel";
    brew install --cask local;
    breakLine;
}

# Microsoft Edge
installMSEdge() {
    title "Installing Microsoft Edge";
    sudo apt install microsoft-edge-stable;
    breakLine;
}

# Node and NVM
installNode() {
    title "Installing Node and NVM";
    brew install node;
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash;
    gotNode=1;
    breakLine;
}

# NPM Tools
installNPMtools() {
    title "Installing NPM Tools";
    npm i -g npm
    npm install -g sass
    npm install -g gulp-cli gulp-dart-sass gulp-notify gulp-autoprefixer gulp-jshint gulp-uglify gulp-concat
    npm install -g browser-sync jshint bower
    npm install gulp -D
    breakLine;
}

# PHP 7.4
installPhp() {
    title "Installing PHP 7.4";
    brew install php;
    brew install php@7.4;
    gotPhp=1;
    breakLine;
}

# Postman
installPostman() {
    title "Installing Postman";
    brew install --cask postman
    breakLine;
}

# Python
installPython() {
    title "Installing Python & PIP";
    sudo apt install -y python-pip;
    curl "https://bootstrap.pypa.io/get-pip.py" | sudo python;
    sudo pip install --upgrade setuptools;
    breakLine;
}

# React Native
installReactNative() {
    title "Installing React Native";
    npm install -g create-react-native-app;
    breakLine;
}

# Screamingfrog
installScreamingfrog() {
    title "Installing Screamingfrog";
    brew install --cask screaming-frog-seo-spider
    breakLine;
}

# Sops
installSops() {
    title "Installing Sops";
    brew install sops
    breakLine;
}

# Sublime Text
installSublime() {
    title "Installing Sublime Text";
    brew install --cask sublime-text;
    breakLine;
}

# Tower Git
installTowerGit() {
    title "Installing Git Tower";
    brew install --cask tower;
    breakLine;
}

# VS Code
installVsCode() {
    title "Installing VS Code";
    sudo apt install code -y
    breakLine;
}

# Webpack
installWebpack() {
    title "Installing Webpack";
    npm install -g webpack;
    breakLine;
}

# Wine
installWine() {
    title "Installing Wine";
    brew install --cask wine-stable
    breakLine;
}

# Yarn
installYarn() {
    title "Installing Yarn";
    npm install --global yarn;
    yarn set version berry;
    breakLine;
}

# ZSH
installZsh() {
    title "Installing ZSH";
    brew install zsh
    chsh -s /usr/local/bin/zsh
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
    echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
    breakLine;
}

###############################################################
## MAIN PROGRAM
###############################################################
sudo apt install -y dialog;

cmd=(dialog --backtitle "Debian 11 Developer Container - USAGE: <space> select/unselect options & <enter> start installation." \
--ascii-lines \
--clear \
--nocancel \
--separate-output \
--checklist "Select what you would like installed:" 35 50 50);

options=(
    01 "Homebrew" on
    02 "ZSH" on
    03 "Git" on
    04 "Node v8" on
    05 "PHP v7.4" on
    06 "NPM Tools" on
    07 "Python" off
    08 "GoLang" off
    09 "Yarn (package manager)" on
    10 "Composer (package manager)" on
    11 "React Native" off
    12 "Webpack" on
    13 "VS Code" on
    14 "Sublime Text IDE" off
    15 "Firefox" off
    16 "Firefox Developer Edition" off
    17 "Microsoft Edge" off
    18 "Software Center" off
    19 "Laravel installer" off
    20 "Lando" off
    21 "Local by Flywheel" off
    22 "Docker" off
    23 "Wine" off
    24 "GitKraken" off
    25 "DBeaver (database tool)" off
);

choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty);

clear;

# Preperation
##########################################################
title "Installing Pre-Requisite Packages and Homebrew";
    cd ~/;
    sudo chown -R $(whoami) ~/
    sudo apt update;
    sudo apt dist-upgrade -y;
    sudo apt autoremove -y --purge;
    
    sudo apt install -y ca-certificates \
    apt-transport-https \
    software-properties-common \
    wget \
    curl \
    htop \
    mlocate \
    gnupg2 \
    cmake \
    libssh2-1-dev \
    libssl-dev \
    nano \
    vim \
    preload \
    gksu \
    snapd;
    
    sudo updatedb;
breakLine;

title "Adding Repositories";
for choice in $choices
do
    case $choice in
        13) repoVsCode ;;
        16) repoMSEdge ;;
        22) repoDocker ;;
    esac
done
notify "Required repositories have been added...";
breakLine;

title "Updating apt";
    sudo apt update;
    notify "The apt package manager is fully updated...";
breakLine;

for choice in $choices
do
    case $choice in
        01) installHomebrew ;;
        02) installZsh ;;
        03) installGit ;;
        04) installNode ;;
        05) installPhp ;;
        06) installNPMtools ;;
        07) installPython ;;
        08) installGoLang ;;
        09) installYarn ;;
        10) installComposer ;;
        11) installReactNative ;;
        12) installWebpack ;;
        13) installVsCode ;;
        14) installSublime ;;
        15) installFirefox ;;
        16) installFirefoxDeveloper ;;
        17) installMSEdge ;;
        18) installSoftwareCenter ;;
        19) installLaravel ;;
        20) installLando ;;
        21) installLocalbyFlywheel ;;
        22) installDocker ;;
        23) installWine ;;
        24) installGitkraken ;;
        25) installDbeaver ;;
    esac
done

# Clean
##########################################################
title "Finalising & Cleaning Up...";
    sudo chown -R $(whoami) ~/;
    sudo apt --fix-broken install -y;
    sudo apt dist-upgrade -y;
    sudo apt autoremove -y --purge;
breakLine;

notify "Great, the installation is complete";