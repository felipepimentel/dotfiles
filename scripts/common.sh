#!/bin/bash -e

# Load configuration values
CONFIG_FILE="${DOTFILES_DIR}/dotfiles_config.yml"
LOGFILE="${DOTFILES_DIR}/install.log"

# Ensure the log directory exists
LOG_DIR=$(dirname "$LOGFILE")
mkdir -p "$LOG_DIR"

# Function to log messages
log_message() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOGFILE"
}

# Function to read values from YAML file
get_config_value() {
    yq eval "$1" "$CONFIG_FILE"
}

# Function to run commands as the real user
run_as_user() {
    sudo -u "$REAL_USER" "$@"
}
