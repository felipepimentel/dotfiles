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

# Include the installation_control.sh file
if [ -f "$SCRIPT_DIR/installation_control.sh" ]; then
    source "$SCRIPT_DIR/installation_control.sh"
else
    echo "Error: installation_control.sh not found in $SCRIPT_DIR"
    exit 1
fi

if script_executed "$(basename "$0")"; then
    log_message "WezTerm installation script has already been executed. Skipping."
    exit 0
fi

log_message "Checking WezTerm installation..."

if ! command -v wezterm &> /dev/null; then
    log_message "Installing WezTerm..."
    
    # Add WezTerm APT repository
    if ! [ -f /usr/share/keyrings/wezterm-fury.gpg ]; then
        log_message "Adding WezTerm APT repository..."
        curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
        echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
    else
        log_message "WezTerm APT repository already added."
    fi

    # Update package lists
    log_message "Updating package lists..."
    sudo apt update

    # Install WezTerm
    log_message "Installing WezTerm..."
    if sudo apt install -y wezterm; then
        log_message "WezTerm installed successfully."
        mark_script_executed "$(basename "$0")"
    else
        log_message "Error: Failed to install WezTerm."
        exit 1
    fi
else
    log_message "WezTerm is already installed."
    mark_script_executed "$(basename "$0")"
fi

# Create symbolic link for wezterm.lua
WEZTERM_CONFIG_DIR="$HOME/.config/wezterm"
mkdir -p "$WEZTERM_CONFIG_DIR"

if [ -f "$DOTFILES_DIR/config/wezterm/wezterm.lua" ]; then
    ln -sf "$DOTFILES_DIR/config/wezterm/wezterm.lua" "$WEZTERM_CONFIG_DIR/wezterm.lua"
    log_message "Created symbolic link for WezTerm configuration."
else
    log_message "WezTerm configuration file not found in dotfiles."
fi