#!/bin/bash

# Determine the directory of the current script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Include the common.sh file
if [ -f "$SCRIPT_DIR/common.sh" ]; then
    source "$SCRIPT_DIR/common.sh"
else
    echo "Error: common.sh not found in $SCRIPT_DIR"
    exit 1
fi

log_message "Creating symlinks..."

# List of files to create symlinks
files=(
    ".gitconfig"
    # Add other config files here
)

for file in "${files[@]}"; do
    if [ -f "$HOME/$file" ]; then
        mv "$HOME/$file" "$HOME/${file}.bak"
        log_message "Backup created for $file"
    fi
    ln -s "$DOTFILES_DIR/config/$file" "$HOME/$file"
    log_message "Symlink created for $file"
done

log_message "Symlinks created successfully."