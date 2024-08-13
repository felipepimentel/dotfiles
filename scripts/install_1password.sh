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

log_message "Installing 1Password CLI..."

if ! command -v op &> /dev/null; then
    curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo apt-key add -
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(lsb_release -cs) $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/1password.list
    sudo apt update && sudo apt install 1password-cli
    log_message "1Password CLI installed successfully."
else
    log_message "1Password CLI is already installed."
fi

if ! command -v 1password &> /dev/null; then
    sudo apt-get update | tee -a "$LOGFILE"
    sudo apt-get install -y 1password | tee -a "$LOGFILE"
    log_message "1Password installed successfully."
else
    log_message "1Password is already installed."
    sudo apt-get install --only-upgrade -y 1password | tee -a "$LOGFILE"
    log_message "1Password updated successfully."
fi