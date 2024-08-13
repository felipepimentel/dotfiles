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

log_message "Installing WhatsApp Desktop..."

if ! dpkg -l | grep -q "whatsapp-for-linux"; then
    wget https://github.com/enesbcs/whatsapp-for-linux/releases/download/v1.1.0/whatsapp-for-linux_amd64.deb -O /tmp/whatsapp.deb
    sudo dpkg -i /tmp/whatsapp.deb | tee -a "$LOGFILE"
    sudo apt-get -f install -y | tee -a "$LOGFILE"
    rm /tmp/whatsapp.deb
    log_message "WhatsApp Desktop installed successfully."
else
    log_message "WhatsApp Desktop is already installed."
fi