#!/bin/bash -e

# Check if DOTFILES_DIR is set
if [ -z "$DOTFILES_DIR" ]; then
    echo "Error: DOTFILES_DIR is not set"
    exit 1
fi

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
    local real_user=$(get_config_value '.user.username')
    if [ -z "$real_user" ]; then
        real_user="$SUDO_USER"
    fi
    if [ -z "$real_user" ]; then
        real_user="$USER"
    fi
    sudo -u "$real_user" "$@"
}

# ... rest of the file ...