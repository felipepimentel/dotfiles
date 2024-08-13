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

log_message "Baixando e instalando Google Chrome..."

if ! dpkg -l | grep -q "google-chrome-stable"; then
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/google-chrome.deb
    sudo dpkg -i /tmp/google-chrome.deb | tee -a "$LOGFILE"
    sudo apt-get -f install -y | tee -a "$LOGFILE"
    rm /tmp/google-chrome.deb
    log_message "Google Chrome installed successfully."
else
    log_message "Google Chrome is already installed."
fi