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

log_message "Installing Git..."

if ! command -v git &> /dev/null; then
    sudo apt-get update
    sudo apt-get install -y git
    log_message "Git installed successfully."
else
    log_message "Git is already installed."
fi