#!/bin/bash -e

# Determine the directory of the current script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Include the common.sh file (if you have common functions in your dotfiles setup)
if [ -f "$SCRIPT_DIR/common.sh" ]; then
    source "$SCRIPT_DIR/common.sh"
else
    echo "Error: common.sh not found in $SCRIPT_DIR"
    exit 1
fi

log_message "Installing Warp Terminal..."

# Define the Warp installation directory
WARP_INSTALL_DIR="$HOME/Applications"

# Create the directory if it doesn't exist
if [ ! -d "$WARP_INSTALL_DIR" ]; then
    mkdir -p "$WARP_INSTALL_DIR"
    log_message "Created Warp installation directory at $WARP_INSTALL_DIR"
fi

# Download Warp (adjust the URL based on the latest version)
WARP_URL="https://example.com/path/to/warp-linux.tar.gz"  # This should be the actual URL to download Warp
WARP_TAR="$WARP_INSTALL_DIR/warp-linux.tar.gz"

# Download Warp if it doesn't exist
if [ ! -f "$WARP_TAR" ]; then
    wget -O "$WARP_TAR" "$WARP_URL"
    log_message "Warp downloaded successfully."
else
    log_message "Warp tarball already exists. Skipping download."
fi

# Extract the Warp tarball
tar -xzvf "$WARP_TAR" -C "$WARP_INSTALL_DIR"
log_message "Warp extracted successfully."

# Create a symbolic link to the executable (if needed)
if [ ! -L "/usr/local/bin/warp" ]; then
    sudo ln -s "$WARP_INSTALL_DIR/warp/warp" /usr/local/bin/warp
    log_message "Created a symbolic link for Warp in /usr/local/bin."
fi

# Create a .desktop entry for Warp (if needed)
DESKTOP_DIR="$HOME/.local/share/applications"
if [ ! -d "$DESKTOP_DIR" ]; then
    mkdir -p "$DESKTOP_DIR"
fi

WARP_DESKTOP="$DESKTOP_DIR/warp.desktop"
if [ ! -f "$WARP_DESKTOP" ]; then
    cat > "$WARP_DESKTOP" <<EOL
[Desktop Entry]
Version=1.0
Name=Warp Terminal
Comment=Warp - A modern terminal for developers
Exec=$WARP_INSTALL_DIR/warp/warp
Icon=$WARP_INSTALL_DIR/warp/icon.png  # Adjust the path to the correct icon
Terminal=false
Type=Application
Categories=Development;TerminalEmulator;
EOL
    log_message "Warp desktop entry created."
else
    log_message "Warp desktop entry already exists."
fi

log_message "Warp installation completed."
