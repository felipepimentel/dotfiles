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

log_message "Installing Visual Studio Code..."

if ! command -v code &> /dev/null; then
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
    sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
    rm -f packages.microsoft.gpg

    sudo apt-get update
    sudo apt-get install -y code
    log_message "Visual Studio Code installed successfully."
else
    log_message "Visual Studio Code is already installed."
fi

# Configure VS Code settings
REAL_USER_HOME=$(eval echo ~$(get_config_value '.user.username'))
VSCODE_SETTINGS_DIR="$REAL_USER_HOME/.config/Code/User"
run_as_user mkdir -p "$VSCODE_SETTINGS_DIR"

run_as_user cat > "$VSCODE_SETTINGS_DIR/settings.json" <<EOF
{
    "workbench.colorTheme": "$(get_config_value '.apps.vscode.theme')",
    "editor.fontFamily": "$(get_config_value '.apps.vscode.font_family')",
    "editor.fontSize": $(get_config_value '.apps.vscode.font_size')
}
EOF

log_message "Visual Studio Code configured successfully."