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

log_message "Downloading and installing Obsidian..."

if ! dpkg -l | grep -q "obsidian"; then
    wget https://github.com/obsidianmd/obsidian-releases/releases/download/v1.3.4/obsidian_1.3.4_amd64.deb -O /tmp/obsidian.deb
    sudo dpkg -i /tmp/obsidian.deb | tee -a "$LOGFILE"
    sudo apt-get -f install -y | tee -a "$LOGFILE"
    rm /tmp/obsidian.deb
    log_message "Obsidian installed successfully."
else
    log_message "Obsidian is already installed."
fi