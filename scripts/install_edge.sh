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

log_message "Installing Microsoft Edge..."

# Add the Microsoft Edge repository if not already added
if ! grep -q "^deb .*microsoft.com" /etc/apt/sources.list /etc/apt/sources.list.d/*; then
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
    sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
    sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main" > /etc/apt/sources.list.d/microsoft-edge.list'
    rm microsoft.gpg
    log_message "Microsoft Edge repository added."
else
    log_message "Microsoft Edge repository already exists. Skipping addition."
fi

# Update package lists and install Microsoft Edge
sudo apt-get update
if sudo apt-get install -y microsoft-edge-stable; then
    log_message "Microsoft Edge installed successfully."
else
    log_message "Failed to install Microsoft Edge."
    exit 1
fi

# Create a .desktop entry for Edge (if needed)
DESKTOP_DIR=$(get_config_value '.paths.desktop_directory')
if [ ! -d "$DESKTOP_DIR" ]; then
    mkdir -p "$DESKTOP_DIR"
fi

EDGE_DESKTOP="$DESKTOP_DIR/microsoft-edge.desktop"
if [ ! -f "$EDGE_DESKTOP" ]; then
    cat > "$EDGE_DESKTOP" <<EOL
[Desktop Entry]
Version=1.0
Name=Microsoft Edge
Comment=Browse the web
Exec=/usr/bin/microsoft-edge-stable
Icon=microsoft-edge
Terminal=false
Type=Application
Categories=Network;WebBrowser;
EOL
    log_message "Microsoft Edge desktop entry created."
else
    log_message "Microsoft Edge desktop entry already exists."
fi

log_message "Microsoft Edge installation completed."
