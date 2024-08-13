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

log_message "Checking for updates..."

# Update the local repository
git -C "$DOTFILES_DIR" fetch origin

LOCAL=$(git -C "$DOTFILES_DIR" rev-parse @)
REMOTE=$(git -C "$DOTFILES_DIR" rev-parse @{u})

if [ $LOCAL != $REMOTE ]; then
  log_message "Updates available. Applying..."
  git -C "$DOTFILES_DIR" pull origin main
  bash "$DOTFILES_DIR/install.sh"
else
  log_message "Dotfiles are already up to date."
fi