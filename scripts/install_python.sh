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
    log_message "Python installation script has already been executed. Skipping."
    exit 0
fi

log_message "Checking Python installation..."

if ! command -v python3 &> /dev/null; then
    log_message "Installing Python..."
    sudo apt-get update
    sudo apt-get install -y python3 python3-pip python3-venv
    log_message "Python and associated tools installed successfully."
else
    log_message "Python is already installed. Checking for updates..."
    sudo apt-get install --only-upgrade -y python3 python3-pip python3-venv
    log_message "Python and associated tools updated successfully."
fi

mark_script_executed "$(basename "$0")"