#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status
set -o pipefail  # Prevent errors in a pipeline from being masked

# Define the list of required packages
PACKAGES=("git" "openssh" "which")

# Function to update and upgrade the system
update_system() {
    echo "Updating and upgrading the system..."
    apt update -y > /dev/null
}

# Function to check if the script is running in Termux
setup_termux() {
    if [[ $TERMUX_VERSION ]]; then
        echo "You are using Termux. Additional setup will be done."
        cp -r .config/.termux ~/ > /dev/null
    fi
}

# Function to install required packages
install_packages() {
    echo "Installing required packages..."
    for package in "${PACKAGES[@]}"; do
        if ! command -v "$package" &> /dev/null; then
            echo "Installing $package..."
            apt install -y "$package" > /dev/null
        else
            echo "$package is already installed. Skipping."
        fi
    done
}

# Function to install Oh My Zsh
install_oh_my_zsh() {
    if [ ! -d ~/.oh-my-zsh ]; then
        echo "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        # Set Zsh as the default shell for Termux
        if [[ $TERMUX_VERSION ]]; then
            echo "export SHELL=$(which zsh)" >> ~/.bashrc
            echo "exec zsh" >> ~/.bashrc
        fi
        # Set Zsh as the default shell
        chsh -s "$(which zsh)"
    else
        echo "Oh My Zsh is already installed. Skipping."
    fi
}

# Function to install Zsh plugins
install_zsh_plugins() {
    echo "Installing Zsh plugins..."
    ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions" > /dev/null 2>&1
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" > /dev/null 2>&1
    git clone https://github.com/zsh-users/zsh-completions.git "$ZSH_CUSTOM/plugins/zsh-completions" > /dev/null 2>&1
}

# Function to install Powerlevel10k theme
install_powerlevel10k() {
    echo "Installing Powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k > /dev/null 2>&1
    echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
}

# Function to copy configuration files
copy_config_files() {
    echo "Copying configuration files..."
    cp .config/.zshrc ~/
    cp .config/.p10k.zsh ~/
}

# Main function to orchestrate the setup
main() {
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