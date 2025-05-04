#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status
set -o pipefail  # Prevent errors in a pipeline from being masked

# Define the list of required packages
PACKAGES=("zsh" "git" "openssh" "which" "neovim" "fzf")

spin () {

local pid=$!
local delay=0.25
local spinner=( '█■■■■' '■█■■■' '■■█■■' '■■■█■' '■■■■█' )

while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do

for i in "${spinner[@]}"
do
	echo -ne "\033[34m\r[*] Working in Progress. Please wait.......\e[33m[\033[32m$i\033[33m]\033[0m   ";
	sleep $delay
	printf "\b\b\b\b\b\b\b\b";
done
done
printf "   \b\b\b\b\b"
printf "\e[1;33m [Done]\e[0m";
echo "";

}

update_system() {
    echo "Updating The packages..."
    if [[ $TERMUX_VERSION ]]; then
        apt-get update -y &> /dev/null & spin
    else
        sudo apt-get update -y &> /dev/null & spin
    fi
}

# Additional setup for Termux
setup_termux() {
    if [[ $TERMUX_VERSION ]]; then
        echo "You are using Termux. Additional setup will be done."
        cp -r .config/.termux ~/ &> /dev/null & spin
    fi
}

# Function to install required packages
install_packages() {
    echo "Installing required packages..."
    for package in "${PACKAGES[@]}"; do
        if ! command -v "$package" &> /dev/null; then
            echo "Installing $package..."
            if [[ $TERMUX_VERSION ]]; then
                (apt-get install -y "$package") &> /dev/null & spin
            else
                (sudo apt-get install -y "$package") &> /dev/null & spin
            fi
        else
            echo "$package is already installed. Skipping."
        fi
    done
}

# Function to install Oh My Zsh
install_oh_my_zsh() {
    if [ ! -d ~/.oh-my-zsh ]; then
        echo "Setting up Oh My Zsh..."
        (bash -c 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended') &> /dev/null & spin
        # Set Zsh as the default shell for Termux
        if [[ $TERMUX_VERSION ]]; then
            echo "export SHELL=$(which zsh)" >> ~/.bashrc
            echo "exec zsh" >> ~/.bashrc
        else
            chsh -s "$(which zsh)"
        fi
    else
        echo "Oh My Zsh is already installed. Skipping."
    fi
}

# Function to install Zsh plugins
install_zsh_plugins() {
    echo "Installing Zsh plugins..."
    ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions" &> /dev/null & spin
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" &> /dev/null & spin
    git clone https://github.com/zsh-users/zsh-completions.git "$ZSH_CUSTOM/plugins/zsh-completions" &> /dev/null & spin
}

# Function to install Powerlevel10k theme
install_powerlevel10k() {
    echo "Installing Powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k &> /dev/null & spin
    echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
}

# Function to copy configuration files
copy_config_files() {
    echo "Copying configuration files..."
    mkdir -p ~/.config
    cp .config/.zshrc ~/
    cp .config/.p10k.zsh ~/
    cp -r .config/nvim ~/.config
}

# Main function to orchestrate the setup
main() {
    clear
    update_system
    setup_termux
    install_packages
    install_oh_my_zsh
    install_zsh_plugins
    install_powerlevel10k
    copy_config_files
    echo "Setup completed successfully! please restart your terminal."
}

# Execute the main function
main