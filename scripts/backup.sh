#!/bin/bash

source "$DOTFILES_DIR/scripts/common.sh"

BACKUP_ENABLED=$(get_config_value '.backup.enabled')
BACKUP_DIR=$(get_config_value '.backup.directory')

if [ "$BACKUP_ENABLED" = "true" ]; then
    log_message "Starting dotfiles backup..."

    mkdir -p "$BACKUP_DIR"

    # List of files and directories to backup
    backup_items=(
      "$HOME/.zshrc"
      "$HOME/.gitconfig"
      "$HOME/.config/nvim"
      "$HOME/.config/Code/User/settings.json"
    )

    for item in "${backup_items[@]}"; do
      if [ -e "$item" ]; then
        cp -R "$item" "$BACKUP_DIR/"
        log_message "Backup completed: $item"
      else
        log_message "Item not found, skipping: $item"
      fi
    done

    log_message "Backup completed in $BACKUP_DIR"
else
    log_message "Backup is disabled in the config. Skipping..."
fi