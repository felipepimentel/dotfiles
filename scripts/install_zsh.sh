#!/bin/bash -e

# Determine the directory of the current script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Include the common.sh file
if [ -f "$SCRIPT_DIR/common.sh" ]; then
    source "$SCRIPT_DIR/common.sh"
else
    echo "Error: common.sh not found in $SCRIPT_DIR"
    exit 1
fi

log_message "Installing and configuring Zsh and Oh My Zsh..."

# Install Zsh
if ! command -v zsh &> /dev/null; then
    sudo apt-get update
    sudo apt-get install -y zsh
    log_message "Zsh installed successfully."
else
    log_message "Zsh is already installed."
fi

# Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    log_message "Oh My Zsh installed successfully."
else
    log_message "Oh My Zsh is already installed."
fi

# Install Powerlevel10k
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    log_message "Powerlevel10k installed successfully."
else
    log_message "Powerlevel10k is already installed."
fi

# Install plugins
plugins=(zsh-syntax-highlighting zsh-autosuggestions)
for plugin in "${plugins[@]}"; do
    if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$plugin" ]; then
        git clone https://github.com/zsh-users/$plugin.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$plugin
        log_message "Plugin $plugin installed successfully."
    else
        log_message "Plugin $plugin is already installed."
    fi
done

# Create symbolic link for .zshrc
if [ -f ~/.zshrc ]; then
    mv ~/.zshrc ~/.zshrc.backup
    log_message "Existing .zshrc backed up to ~/.zshrc.backup"
fi
ln -s "$DOTFILES_DIR/config/zsh/.zshrc" ~/.zshrc
log_message "Symbolic link for .zshrc created successfully."

# Set Zsh as the default shell
if [[ $SHELL != "/bin/zsh" ]]; then
    chsh -s $(which zsh)
    log_message "Zsh set as the default shell. Please log out and log back in to apply the changes."
fi

log_message "Zsh, Oh My Zsh, and Powerlevel10k installation and configuration completed."