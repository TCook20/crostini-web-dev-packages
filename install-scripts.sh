#!/usr/bin/env bash

# Disallow running with sudo or su
##########################################################
if [ "$EUID" -eq 0 ]
  then printf "\033[1;101mNein, nein, nein... Please do NOT run this script as root! \033[0m \n";
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
gotPhp=0;
gotNode=0;

###############################################################
## REPOSITORIES
###############################################################

# PHP 7.2
##########################################################
repoPhp() {
    if [ ! -f /etc/apt/sources.list.d/php.list ]; then
        notify "Adding PHP sury repository";
        curl -fsSL "https://packages.sury.org/php/apt.gpg" | sudo apt-key add -;
        echo "deb https://packages.sury.org/php/ stretch main" | sudo tee /etc/apt/sources.list.d/php.list;
    fi
}

# Yarn
##########################################################
repoYarn() {
    if [ ! -f /etc/apt/sources.list.d/yarn.list ]; then
        notify "Adding Yarn repository";
        curl -fsSL "https://dl.yarnpkg.com/debian/pubkey.gpg" | sudo apt-key add -;
        echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list;
    fi
}

# Docker CE
##########################################################
repoDocker() {
    if [ ! -f /var/lib/dpkg/info/docker-ce.list ]; then
        notify "Adding Docker repository";
        curl -fsSL "https://download.docker.com/linux/debian/gpg" | sudo apt-key add -;
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable";
    fi
}

# VS Code
##########################################################
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

# Debian Software Center
installSoftwareCenter() {
    sudo apt install -y gnome-software gnome-packagekit;
}

# Git
##########################################################
installGit() {
    title "Installing Git";
    sudo apt install -y git;
    sudo git config --global user.name "Travis Cook"
    sudo git config --global core.editor code
    sudo git config --global credential.helper store
    breakLine;
}

# Node 8
##########################################################
installNode() {
    title "Installing Node 8";
    curl -L "https://deb.nodesource.com/setup_8.x" | sudo -E bash -;
    sudo apt install -y nodejs;
    sudo chown -R $(whoami) /usr/lib/node_modules;
    gotNode=1;
    breakLine;
}

# React Native
##########################################################
installReactNative() {
    title "Installing React Native";
    sudo npm install -g create-react-native-app;
    breakLine;
}

# Webpack
##########################################################
installWebpack() {
    title "Installing Webpack";
    sudo npm install -g webpack;
    breakLine;
}

# PHP 7.2
##########################################################
installPhp() {
    title "Installing PHP 7.3";
    sudo apt install -y php7.3 php7.3-{bcmath,cli,common,curl,dev,gd,mbstring,mysql,sqlite,xml,zip} php-pear php-memcached php-redis;
    sudo apt install -y libphp-predis;
    php --version;
    gotPhp=1;
    breakLine;
}

# Ruby
##########################################################
installRuby() {
    title "Installing Ruby & DAPP";
    sudo apt install -y ruby-dev gcc pkg-config build-essential;
    sudo gem install dapp;
    sudo gem install sass;
    breakLine;
}

# Python
##########################################################
installPython() {
    title "Installing Python & PIP";
    sudo apt install -y python-pip;
    curl "https://bootstrap.pypa.io/get-pip.py" | sudo python;
    sudo pip install --upgrade setuptools;
    breakLine;
}

# Yarn
##########################################################
installYarn() {
    title "Installing Yarn";
    sudo apt install -y yarn;
    breakLine;
}

# Composer
##########################################################
installComposer() {
    title "Installing Composer";
    php -r "copy('https://getcomposer.org/installer', '/tmp/composer-setup.php');";
    sudo php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer;
    sudo rm /tmp/composer-setup.php;
    breakLine;
}

# SQLite Browser
##########################################################
installSqLite() {
    title "Installing SQLite Browser";
    sudo apt install -y sqlitebrowser;
    breakLine;    
}

# DBeaver
##########################################################
installDbeaver() {
    title "Installing DBeaver SQL Client";
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
##########################################################
installDocker() {
    title "Installing Docker CE with Docker Compose";
    sudo apt install -y docker-ce;
    curlToFile "https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m)" "/usr/local/bin/docker-compose";
    sudo chmod +x /usr/local/bin/docker-compose;
    sudo usermod -aG docker $USER;
    breakLine;
}

# Lando
##########################################################
installLando() {
    title "Installing Lando";
    curlToFile "https://github.com/lando/lando/releases/download/lando-v3.0.0-rc.1/lando-v3.0.0-rc.1.deb" "lando.deb";
    sudo dpkg -i ~/lando.deb;
    sudo rm ~/lando.deb;
    breakLine;
}

# VS Code
##########################################################
installVsCode() {
    title "Installing VS Code IDE";
    sudo apt install -y code;
    code --install-extension Shan.code-settings-sync
    breakLine;
}

# FileZilla
##########################################################
installFileZilla() {
    title "Installing FileZilla";
    sudo apt install -y filezilla;
    breakLine;
}

# Pinta
##########################################################
installPinta() {
    title "Installing Pinta";
    sudo apt install -y pinta;
    breakLine;
}

# GIMP
##########################################################
installGIMP() {
    title "Installing GIMP";
    sudo apt-get install -y flatpak
    sudo flatpak install https://flathub.org/repo/appstream/org.gimp.GIMP.flatpakref -y
    breakLine;
}

# GitKraken
##########################################################
installGitkraken() {
    title "Installing GitKraken";
    curl -L https://release.gitkraken.com/linux/gitkraken-amd64.deb > gitkraken.deb
    sudo apt-get install -y ./gitkraken.deb
    sudo rm -f gitkraken.deb
    breakLine;
}

# NPM Tools
##########################################################
installNPMtools() {
    title "Installing NPM Tools";
    sudo npm i -g npm
    sudo npm install -g sass
    sudo npm install -g gulp-cli gulp-ruby-sass gulp-notify gulp-autoprefixer gulp-jshint gulp-uglify gulp-concat
    sudo npm install -g browser-sync jshint bower
    sudo npm install gulp -D
    breakLine;
}

###############################################################
## MAIN PROGRAM
###############################################################

cmd=(dialog --backtitle "Debian 9 Developer Container - USAGE: <space> select/unselect options & <enter> start installation." \
--ascii-lines \
--clear \
--nocancel \
--separate-output \
--checklist "Select what you would like installed:" 35 50 50);

options=(
    01 "Git" on
    02 "Node v8" on
    03 "PHP v7.3 with PECL" on
    04 "Ruby" off
    05 "Python" off
    06 "Yarn (package manager)" off
    07 "Composer (package manager)" on
    08 "React Native" off
    09 "Webpack" on
    10 "Docker CE (with docker compose)" off
    11 "Lando"
    12 "SQLite (database tool)" on
    13 "DBeaver (database tool)" off
    14 "VS Code IDE" on
    15 "Software Center" on
    16 "FileZilla" off
    17 "Pinta" off
    28 "GIMP" off
    19 "GitKraken" off
    20 "NPM Tools" off
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
    preload \
    gksu;
    
    sudo updatedb;
breakLine;

title "Adding Repositories";
for choice in $choices
do
    case $choice in
        03) repoPhp ;;
        07) repoPhp ;;
        17) repoPhp ;;
        06) repoYarn ;;
        10) repoDocker ;;
        14) repoVsCode ;;
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
        01) installGit ;;
        02) installNode ;;
        03) installPhp ;;
        04) installRuby ;;
        05) installPython ;;
        06) installYarn ;;
        07) 
            if [ $gotPhp -ne 1 ]; then 
                installPhp 
            fi
            installComposer
        ;;
        08) 
            if [ $gotNode -ne 1 ]; then 
                installNode 
            fi
            installReactNative
        ;;
        09) 
            if [ $gotNode -ne 1 ]; then 
                installNode 
            fi
            installWebpack
        ;;
        10) installDocker ;;
        11) installLando ;;
        12) installSqLite ;;
        13) installDbeaver ;;
        14) installVsCode ;;
        15) installSoftwareCenter ;;
        16) installFileZilla ;;
        17) installPinta ;;
        18) installGIMP ;;
        19) installGitkraken ;;
        20) installNPMtools ;;
    esac
done

# Clean
##########################################################
title "Finalising & Cleaning Up...";
    sudo apt --fix-broken install -y;
    sudo apt dist-upgrade -y;
    sudo apt autoremove -y --purge;
breakLine;

notify "Great, the installation is complete =)";