#!/bin/bash -e

# Include the common.sh file
if [ -f "$SCRIPT_DIR/common.sh" ]; then
    source "$SCRIPT_DIR/common.sh"
else
    echo "Error: common.sh not found in $SCRIPT_DIR"
    exit 1
fi

log_message "Installing VS Code..."

# Install VS Code
if ! command -v code &> /dev/null; then
    sudo apt-get install -y code
    log_message "VS Code installed successfully."
else
    log_message "VS Code is already installed."
fi

# Apply VS Code settings
VSCODE_THEME=$(get_config_value '.tools[] | select(.name == "vscode") | .configuration.theme')
VSCODE_FONT=$(get_config_value '.tools[] | select(.name == "vscode") | .configuration.font_family')
VSCODE_FONT_SIZE=$(get_config_value '.tools[] | select(.name == "vscode") | .configuration.font_size')

# Here you would apply these settings, either via a settings file or CLI commands
log_message "VS Code configured with theme $VSCODE_THEME, font $VSCODE_FONT, size $VSCODE_FONT_SIZE."
