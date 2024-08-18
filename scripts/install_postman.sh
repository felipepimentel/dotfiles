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

log_message "Installing Postman..."

# Verify and install snap if not available
if ! command_exists snap; then
    log_message "Snap not found. Installing..."
    sudo apt-get update
    sudo apt-get install -y snapd
fi

# Install Postman via Snap
if ! command -v postman &> /dev/null; then
    sudo snap install postman
    log_message "Postman installed successfully."
else
    log_message "Postman is already installed."
    sudo snap refresh postman
    log_message "Postman updated successfully."
fi

# Create desktop icon
DESKTOP_DIR=$(yq eval '.paths.desktop_directory' "$CONFIG_FILE")
if [ ! -d "$DESKTOP_DIR" ]; then
    mkdir -p "$DESKTOP_DIR"
fi

if [ "$(yq eval '.tools[] | select(.name == "postman") | .configuration.create_desktop_icon' "$CONFIG_FILE")" == "true" ]; then
    if [ ! -f "$DESKTOP_DIR/postman.desktop" ]; then
        cat > "$DESKTOP_DIR/postman.desktop" <<EOL
[Desktop Entry]
Name=Postman
Exec=/snap/bin/postman
Terminal=false
Type=Application
Icon=/snap/postman/current/icon.png
Categories=Development;
EOL
        log_message "Postman desktop icon created successfully."
    else
        log_message "Postman desktop icon already exists."
    fi
fi
