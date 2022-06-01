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
GIT_EDITOR="code"
HOMEBREW_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
NVM_URL="https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh"
PLATFORMSH_URL="https://platform.sh/cli/installer"

###############################################################
## INSTALLATION
###############################################################

# Generate SSH Key
generateSshKey() {
    title "Generate SSH Key";
    
    breakLine;
}

# Homebrew
installHomebrew() {
    title "Installing Homebrew";
    /bin/bash -c "$(curl -fsSL $HOMEBREW_URL)"
    brew update
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
    brew install git
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

# Microsoft Teams
installMSTeams() {
    title "Installing Microsoft Teams";
    brew install --cask microsoft-teams;
    breakLine;
}

# Node and NVM
installNode() {
    title "Installing Node and NVM";
    brew install node;
    nvm install-latest-npm;
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash;
    npm config set @university-of-missouri:registry https://gitlab.com/api/v4/packages/npm/
    read -p -s 'Enter your GitLab token: ' GITLAB_TOKEN
    npm config set '//gitlab.com/api/v4/packages/npm/:_authToken' "${GITLAB_TOKEN}"
    gotNode=1;
    breakLine;
}

# NPM Tools
installNPMtools() {
    title "Installing NPM Tools";
    npm i -g npm
    npm install -g sass
    npm install -g gulp-cli gulp-dart-sass gulp-notify gulp-autoprefixer gulp-jshint gulp-uglify gulp-concat
    npm install -g browser-sync jshint
    npm install gulp -D
    breakLine;
}

# PHP 7.4
installPhp() {
    title "Installing PHP 7.4";
    brew install php
    brew install php@7.4
    brew link --force --overwrite php@7.4
    brew services start php@7.4
    export PATH="/usr/local/opt/php@7.4/bin:$PATH"
    gotPhp=1;
    breakLine;
}

# Platform.sh CLI
installPlatform() {
    title "Installing Platform CLI";
    curl -fsS $PLATFORMSH_URL | php
    echo "Platform CLI is installed."
    breakLine;
}

# Screamingfrog
installScreamingfrog() {
    title "Installing Screamingfrog";
    brew install --cask screaming-frog-seo-spider
    breakLine;
}

# Slack
installSlack() {
    title "Installing Slack";
    brew install --cask slack;
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
    01 "Git" on
    02 "ZSH" on
    03 "Node v8" on
    04 "PHP v7.4" on
    05 "NPM Tools" on
    06 "Yarn (package manager)" on
    07 "Composer (package manager)" on
    08 "Platform.sh CLI" on
    09 "Webpack" on
    10 "Lando" on
    11 "VS Code" on
    12 "Firefox" off
    13 "Firefox Developer Edition" off
    14 "Microsoft Edge" off
    15 "Microsoft Teams" off
    16 "Screamingfrog" on
    17 "Tower Git" off
    18 "DBeaver (database tool)" on
    19 "Sublime Text IDE" off
    20 "Slack" off
    21 "Generate SSH Key" off
);

choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty);

clear;

# Preperation
##########################################################
title "Installing Pre-Requisite Packages";
    cd ~/;
    sudo chown -R $(whoami) ~/
    installHomebrew
breakLine;

title "Updating brew";
    brew update;
    notify "The apt package manager is fully updated...";
breakLine;

for choice in $choices
do
    case $choice in
        01) installGit ;;
        02) installZsh ;;
        03) installNode ;;
        04) installPhp ;;
        05) installNPMtools ;;
        06) installYarn ;;
        07) installComposer ;;
        08) installPlatform ;;
        09) installWebpack ;;
        10) installLando ;;
        11) installVsCode ;;
        12) installFirefox ;;
        13) installFirefoxDeveloper ;;
        14) installMSEdge ;;
        15) installMSTeams ;;
        16) installScreamingfrog ;;
        17) installTowerGit ;;
        18) installDbeaver ;;
        19) installSublime ;;
        20) installSlack ;;
        21) generateSshKey ;;
    esac
done

notify "Great, the installation is complete";