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
repoUrl="https://raw.githubusercontent.com/andrewbrg/deb9-dev-machine/master/";
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

# Kubernetes
##########################################################
repoKubernetes() {
    if [ ! -f /etc/apt/sources.list.d/kubernetes.list ]; then
        notify "Adding Kubernetes repository";
        curl -fsSL "https://packages.cloud.google.com/apt/doc/apt-key.gpg" | sudo apt-key add -;
        echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list;
    fi   
}

# Wine
##########################################################
repoWine() {
    if [ ! -f /var/lib/dpkg/info/wine-stable.list ]; then
        notify "Adding Wine repository";
        sudo dpkg --add-architecture i386;
        curl -fsSL "https://dl.winehq.org/wine-builds/Release.key" | sudo apt-key add -;
        sudo apt-add-repository "https://dl.winehq.org/wine-builds/debian/";
    fi
}

# Atom
##########################################################
repoAtom() {
    if [ ! -f /etc/apt/sources.list.d/atom.list ]; then
        notify "Adding Atom IDE repository";
        curl -fsSL https://packagecloud.io/AtomEditor/atom/gpgkey | sudo apt-key add -;
        echo "deb [arch=amd64] https://packagecloud.io/AtomEditor/atom/any/ any main" | sudo tee /etc/apt/sources.list.d/atom.list;
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

# Sublime
##########################################################
repoSublime() {
    if [ ! -f /etc/apt/sources.list.d/sublime-text.list ]; then
        notify "Adding Sublime text repository";
        curl -fsSL "https://download.sublimetext.com/sublimehq-pub.gpg" | sudo apt-key add -;
        echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list;
    fi
}

# Remmina
##########################################################
repoRemmina() {
	if [ ! -f /etc/apt/sources.list.d/remmina.list ]; then
		notify "Adding Remmina repository";
		sudo touch /etc/apt/sources.list.d/remmina.list;
		echo 'deb http://ftp.debian.org/debian stretch-backports main' | sudo tee --append /etc/apt/sources.list.d/stretch-backports.list >> /dev/null
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

# Cordova
##########################################################
installCordova() {
    title "Installing Apache Cordova";
    sudo npm install -g cordova;
    breakLine;
}

# Phonegap
##########################################################
installPhoneGap() {
    title "Installing Phone Gap";
    sudo npm install -g phonegap;
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

# Memcached
##########################################################
installMemcached() {
    title "Installing Memcached";
    sudo apt install -y memcached;
    sudo systemctl start memcached;
    sudo systemctl enable memcached;
    breakLine;
}

# Redis
##########################################################
installRedis() {
    title "Installing Redis";
    sudo apt install -y redis-server;
    sudo systemctl start redis;
    sudo systemctl enable redis;
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

# Laravel Installer
##########################################################
installLaravel() {
    title "Installing Laravel Installer";
    composer global require "laravel/installer";
    echo 'export PATH="$PATH:$HOME/.config/composer/vendor/bin"' | tee -a ~/.bashrc;
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

# Kubernetes
##########################################################
installKubernetes() {
    title "Installing Kubernetes";
    sudo apt install -y kubectl;
    breakLine;
}

# Wine
##########################################################
installWine() {
    title "Installing Wine & Mono";
    
    sudo apt install -y cabextract;
    sudo apt install -y --install-recommends winehq-stable;
    sudo apt install -y mono-vbnc;

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

# Postman
##########################################################
installPostman() {
    title "Installing Postman";
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

# Atom IDE
##########################################################
installAtom() {
    title "Installing Atom IDE";
    sudo apt install -y atom;
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

# Sublime Text
##########################################################
installSublime() {
    title "Installing Sublime Text";

    sudo apt install -y sublime-text;
    sudo apt install -y python-pip;
    sudo pip install -U CodeIntel;
    
    sudo chown -R $(whoami) ~/;
    
    mkdir -p ~/.config/sublime-text-3/Packages/User/;
    
    notify "Adding pre-installed packages for sublime";
    curlToFile "${repoUrl}settings/PackageControl.sublime-settings" ".config/sublime-text-3/Packages/User/Package Control.sublime-settings";
    
    notify "Applying default preferences to sublime";
    curlToFile "${repoUrl}settings/Preferences.sublime-settings" ".config/sublime-text-3/Packages/User/Preferences.sublime-settings";
    
    notify "Installing additional binaries for sublime auto-complete";
    curlToFile "https://github.com/emmetio/pyv8-binaries/raw/master/pyv8-linux64-p3.zip" "bin.zip";
    
    sudo mkdir -p ".config/sublime-text-3/Installed Packages/PyV8/";
    sudo unzip ~/bin.zip -d ".config/sublime-text-3/Installed Packages/PyV8/";
    sudo rm ~/bin.zip;
    breakLine;
}

# PHP Storm
##########################################################
installPhpStorm() {
    title "Installing PhpStorm IDE";
    curlToFile "https://download.jetbrains.com/webide/PhpStorm-2018.2.2.tar.gz" "phpstorm.tar.gz";
    sudo tar xfz ~/phpstorm.tar.gz;
    
    sudo rm -rf /opt/phpstorm/;
    sudo mkdir /opt/phpstorm/;
    sudo mv ~/PhpStorm-*/* /opt/phpstorm/;
    sudo rm -rf ~/phpstorm.tar.gz;
    sudo rm -rf ~/PhpStorm-*;
    
    notify "Adding desktop file for PhpStorm";
    curlToFile ${repoUrl}"desktop/jetbrains-phpstorm.desktop" "/usr/share/applications/jetbrains-phpstorm.desktop";
    breakLine;
}

# FileZilla
##########################################################
installFileZilla() {
    title "Installing FileZilla";
    sudo apt install -y filezilla;
    breakLine;
}

# Remmina
##########################################################
installRemmina() {
    title "Installing Remmina Client";
    sudo apt install -t -y stretch-backports remmina remmina-plugin-rdp remmina-plugin-secret;
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
    06 "Yarn (package manager)" on
    07 "Composer (package manager)" on
    08 "React Native" off
    09 "Apache Cordova" off
    10 "Phonegap" off
    11 "Webpack" on
    12 "Memcached server" off
    13 "Redis server" off
    14 "Docker CE (with docker compose)" off
    15 "Lando"
    16 "Kubernetes (Kubectl)" off
    17 "Postman" off
    18 "Laravel installer" off
    19 "Wine" off
    20 "SQLite (database tool)" on
    21 "DBeaver (database tool)" off
    22 "Atom IDE" off
    23 "VS Code IDE" on
    24 "Sublime Text IDE" off
    25 "PhpStorm IDE" off
    26 "Software Center" on
    27 "Remmina (Remote Desktop Client)" off
    28 "FileZilla" off
    29 "Pinta" off
    30 "GIMP" off
    31 "GitKraken" off
    32 "NPM Tools" off
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
        14) repoDocker ;;
        16) repoKubernetes ;;
        19) repoWine ;;
        22) repoAtom ;;
        23) repoVsCode ;;
        24) repoSublime ;;
	    27) repoRemmina ;;
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
            installCordova
        ;;
        10) 
            if [ $gotNode -ne 1 ]; then 
                installNode 
            fi
            installPhoneGap
        ;;
        11) 
            if [ $gotNode -ne 1 ]; then 
                installNode 
            fi
            installWebpack
        ;;
        12) installMemcached ;;
        13) installRedis ;;
        14) installDocker ;;
        16) installKubernetes ;;
        17) installPostman ;;
        18) 
            if [ $gotPhp -ne 1 ]; then 
                installPhp
            fi
            installLaravel
        ;;
        19) installWine ;;
        20) installSqLite ;;
        21) installDbeaver ;;
        22) installAtom ;;
        23) installVsCode ;;
        24) installSublime ;;
        25) installPhpStorm ;;
        26) installSoftwareCenter ;;
	    27) installRemmina ;;
        28) installFileZilla ;;
        29) installPinta ;;
        30) installGIMP ;;
        31) installGitkraken ;;
        32) installNPMtools ;;
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