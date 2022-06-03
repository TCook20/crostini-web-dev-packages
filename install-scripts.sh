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

# Atom
repoAtom() {
    if [ ! -f /etc/apt/sources.list.d/atom.list ]; then
        notify "Adding Atom IDE repository";
        curl -fsSL https://packagecloud.io/AtomEditor/atom/gpgkey | sudo apt-key add -;
        echo "deb [arch=amd64] https://packagecloud.io/AtomEditor/atom/any/ any main" | sudo tee /etc/apt/sources.list.d/atom.list;
    fi
}

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

# PHP
repoPhp() {
    if [ ! -f /etc/apt/sources.list.d/php.list ]; then
        notify "Adding PHP sury repository";
        curl -fsSL "https://packages.sury.org/php/apt.gpg" | sudo apt-key add -;
        echo "deb https://packages.sury.org/php/ stretch main" | sudo tee /etc/apt/sources.list.d/php.list;
    fi
}

# Sublime
repoSublime() {
    if [ ! -f /etc/apt/sources.list.d/sublime-text.list ]; then
        notify "Adding Sublime text repository";
        curl -fsSL "https://download.sublimetext.com/sublimehq-pub.gpg" | sudo apt-key add -;
        echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list;
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


# Wine
repoWine() {
    if [ ! -f /var/lib/dpkg/info/wine-stable.list ]; then
        notify "Adding Wine repository";
        sudo dpkg --add-architecture i386;
        curl -fsSL "https://dl.winehq.org/wine-builds/Release.key" | sudo apt-key add -;
        sudo apt-add-repository "https://dl.winehq.org/wine-builds/debian/";
    fi
}

# Yarn
repoYarn() {
    if [ ! -f /etc/apt/sources.list.d/yarn.list ]; then
        notify "Adding Yarn repository";
        curl -fsSL "https://dl.yarnpkg.com/debian/pubkey.gpg" | sudo apt-key add -;
        echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list;
    fi
}

###############################################################
## INSTALLATION
###############################################################

# Atom IDE
installAtom() {
    title "Installing Atom IDE";
    sudo apt install -y atom;
    breakLine;
}

# Composer
installComposer() {
    title "Installing Composer";
    # brew install composer;
    php -r "copy('https://getcomposer.org/installer', '/tmp/composer-setup.php');";
    sudo php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer;
    sudo rm /tmp/composer-setup.php;
    breakLine;
}

# DBeaver
installDbeaver() {
    title "Installing DBeaver SQL Client";
    # brew install --cask dbeaver-community;
    sudo apt install -y \
    ca-certificates-java* \
    java-common* \
    libpcsclite1* \
    libutempter0* \
    openjdk-8-jre-headless* \
    xbitmaps*;
    
    curlToFile "https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb" "dbeaver.deb";
    sudo dpkg -i ~/dbeaver.deb;
    sudo rm ~/dbeaver.deb;
    breakLine;
}

# Docker
installDocker() {
    title "Installing Docker CE with Docker Compose";
    # brew install docker;
    # brew install docker-compose;
    sudo apt install -y docker-ce;
    curlToFile "https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m)" "/usr/local/bin/docker-compose";
    sudo chmod +x /usr/local/bin/docker-compose;
    breakLine;
}

# FileZilla
installFileZilla() {
    title "Installing FileZilla";
    sudo apt install -y filezilla;
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
    # sudo apt install -y git;
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
    # brew install --cask gitkraken;
    curl -L https://release.gitkraken.com/linux/gitkraken-amd64.deb > gitkraken.deb
    sudo apt-get install -y ./gitkraken.deb
    sudo rm -f gitkraken.deb
    breakLine;
}

# Gnome Software Center
installGnomeSoftwareCenter() {
    sudo apt install -y gnome-software;
}

# GoLang
installGoLang() {
    title "Installing GoLang";
    # brew install go;
    sudo apt install -y golang;
    echo 'export GOPATH=~/go' >> ~/.bashrc;
    source ~/.bashrc;
    mkdir $GOPATH;
    gotGoLang=1;
    breakLine;
}

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

# Kubernetes
installKubernetes() {
    title "Installing Kubernetes";
    sudo apt install -y kubectl;
    breakLine;
}

# Lando
installLando() {
    title "Installing Lando";
    # brew install --cask lando;
    curlToFile "https://github.com/lando/lando/releases/download/lando-v3.6.4/lando-v3.6.4.deb" "lando.deb";
    sudo dpkg -i ~/lando.deb;
    sudo rm ~/lando.deb;
    breakLine;
}

# Laravel Installer
installLaravel() {
    title "Installing Laravel Installer";
    composer global require "laravel/installer";
    echo 'export PATH="$PATH:$HOME/.config/composer/vendor/bin"' | tee -a ~/.bashrc;
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
    # brew install --cask microsoft-edge;
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
    # brew install --cask postman
    curlToFile "https://dl.pstmn.io/download/latest/linux64" "postman.tar.gz";
    sudo tar xfz ~/postman.tar.gz;
    
    sudo rm -rf /opt/postman/;
    sudo mkdir /opt/postman/;
    sudo mv ~/Postman*/* /opt/postman/;
    sudo rm -rf ~/Postman*;
    sudo rm -rf ~/postman.tar.gz;
    sudo ln -s /opt/postman/Postman /usr/bin/postman;
    
    notify "Adding desktop file for Postman";
    curlToFile ${repoUrl}"desktop/postman.desktop" "/usr/share/applications/postman.desktop";
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
    sudo npm install -g create-react-native-app;
    breakLine;
}

# Sops
installSops() {
    title "Installing Sops v3.1.1";
    # brew install sops
    wget -O sops_3.1.1_amd64.deb "https://github.com/mozilla/sops/releases/download/3.1.1/sops_3.1.1_amd64.deb";
    sudo dpkg -i sops_3.1.1_amd64.deb;
    sudo rm sops_3.1.1_amd64.deb;
    breakLine;
}

# SQLite Browser
installSqLite() {
    title "Installing SQLite Browser";
    sudo apt install -y sqlitebrowser;
    breakLine;    
}

# Sublime Text
installSublime() {
    title "Installing Sublime Text";
    sudo apt install -y sublime-text;
    # brew install --cask sublime-text;
    breakLine;
}

# VS Code
installVsCode() {
    title "Installing VS Code";
    sudo apt install code -y
    # brew install --cask visual-studio-code
    breakLine;
}

# Webpack
installWebpack() {
    title "Installing Webpack";
    sudo npm install -g webpack;
    breakLine;
}

# Wine
installWine() {
    title "Installing Wine & Mono";
    # brew install --cask wine-stable
    sudo apt install -y cabextract \
    --install-recommends winehq-stable \
    mono-vbnc;

    notify "Installing windows fonts for wine apps";
    curlToFile "https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks" "winetricks";
    sudo chmod +x ~/winetricks;
    ./winetricks allfonts;
    echo "y" | rm ~/winetricks;
    
    notify "Applying font smoothing to wine apps";
    curlToFile ${repoUrl}"wine_fontsmoothing.sh" "wine_fontsmoothing";
    sudo chmod +x ~/wine_fontsmoothing;
    sudo ./wine_fontsmoothing;
    echo "y" | rm ~/wine_fontsmoothing;
    clear;
    
    notify "Installing Royale 2007 theme for windows apps";
    curlToFile "http://www.gratos.be/wincustomize/compressed/Royale_2007_for_XP_by_Baal_wa_astarte.zip" "Royale_2007.zip";
    
    sudo chown -R $(whoami) ~/;
    mkdir -p ~/.wine/drive_c/Resources/Themes/;
    unzip ~/Royale_2007.zip -d ~/.wine/drive_c/Resources/Themes/;
    echo "y" | rm ~/Royale_2007.zip;
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
        18) installGnomeSoftwareCenter ;;
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