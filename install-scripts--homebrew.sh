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
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)";
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
    git config --global user.name "Travis Cook"
    git config --global core.editor code
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

# Microsoft Edge
installMSEdge() {
    title "Installing Microsoft Edge";
    brew install --cask microsoft-edge;
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
    brew install --cask visual-studio-code
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
    02 "Git" on
    03 "Node v8" on
    04 "PHP v7.4" on
    05 "NPM Tools" on
    06 "Python" off
    07 "GoLang" off
    08 "Yarn (package manager)" on
    09 "Composer (package manager)" on
    10 "React Native" off
    11 "Webpack" on
    12 "Lando" on
    13 "VS Code" on
    14 "Firefox" off
    15 "Firefox Developer Edition" off
    16 "Microsoft Edge" off
    17 "Screamingfrog" on
    18 "Tower Git" off
    19 "Sublime Text IDE" off
    20 "Software Center" off
    21 "Laravel installer" off
    22 "Docker" off
    23 "Wine" off
    24 "GitKraken" off
    25 "SQLite (database tool)" off
    26 "DBeaver (database tool)" on
);

choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty);

clear;

# Preperation
##########################################################
title "Installing Pre-Requisite Packages";
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
        02) installGit ;;
        03) installNode ;;
        04) installPhp ;;
        05) installNPMtools ;;
        06) installPython ;;
        07) installGoLang ;;
        08) installYarn ;;
        09) installComposer ;;
        10) installReactNative ;;
        11) installWebpack ;;
        12) installLando ;;
        13) installVsCode ;;
        14) installFirefox ;;
        15) installFirefoxDeveloper ;;
        16) installMSEdge ;;
        17) installScreamingfrog ;;
        18) installTowerGit ;;
        19) installSublime ;;
        20) installSoftwareCenter ;;
        21) installLaravel ;;
        22) installDocker ;;
        23) installWine ;;
        24) installGitkraken ;;
        25) installSqLite ;;
        26) installDbeaver ;;
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

notify "Great, the installation is complete =)";