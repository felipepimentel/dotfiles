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

log_message "Installing Calibre..."

if ! dpkg -l | grep -q "calibre"; then
    sudo -v && wget -nv -O- https://download.calibre-ebook.com/linux-installer.sh | sudo sh /dev/stdin
    
    # Install missing library
    sudo apt-get update
    sudo apt-get install -y libxcb-cursor0
    
    log_message "Calibre installed successfully."
else
    log_message "Calibre is already installed."
fi