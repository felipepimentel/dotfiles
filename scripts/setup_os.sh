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

log "Setting up OS"

# Update and upgrade
sudo apt update && sudo apt upgrade -y

# Install essential packages
essential_packages=(
    curl wget git vim xclip unzip dconf-cli jq zsh tilix
)

for package in "${essential_packages[@]}"; do
    install_if_not_exists $package
done

# Setup fonts
source "$DOTFILES_DIR/scripts/setup_fonts.sh"

# Setup themes
source "$DOTFILES_DIR/scripts/setup_themes.sh"

# Setup keyboard
source "$DOTFILES_DIR/scripts/setup_keyboard.sh"

log "OS setup completed"