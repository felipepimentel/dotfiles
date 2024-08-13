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

log_message "Downloading and installing Cursor IDE..."

if ! dpkg -l | grep -q "cursor"; then
    wget https://github.com/getcursor/cursor/releases/download/v0.2.3/cursor_0.2.3_amd64.deb -O /tmp/cursor.deb
    sudo dpkg -i /tmp/cursor.deb
    sudo apt-get -f install -y
    rm /tmp/cursor.deb
    log_message "Cursor IDE installed successfully."
else
    log_message "Cursor IDE is already installed."
fi