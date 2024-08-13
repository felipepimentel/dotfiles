#!/bin/bash

# Determine the directory of the current script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Include the common.sh file
if [ -f "$SCRIPT_DIR/common.sh" ]; then
    source "$SCRIPT_DIR/common.sh"
else
    echo "Error: common.sh not found in $SCRIPT_DIR"
    exit 1
fi

log_message "Installing fonts with ligatures (including Fira Code)..."

mkdir -p "$FONT_DIR"
cd "$FONT_DIR"

if [ ! -f "FiraCode-Regular.ttf" ]; then
    wget https://github.com/tonsky/FiraCode/releases/download/6.2/Fira_Code_v6.2.zip -O /tmp/firacode.zip
    unzip /tmp/firacode.zip -d /tmp/firacode
    cp /tmp/firacode/ttf/*.ttf "$FONT_DIR/"
    rm -rf /tmp/firacode /tmp/firacode.zip
    fc-cache -f -v
    log_message "Fira Code installed successfully."
else
    log_message "Fira Code is already installed."
fi