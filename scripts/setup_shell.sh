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
source "$SCRIPT_DIR/installation_control.sh"

log_message "Setting up shell configuration..."

# Determine the user's preferred shell from the config
PREFERRED_SHELL=$(get_config_value '.system.preferred_shell')

# Install the preferred shell if it's not already installed
if ! command -v "$PREFERRED_SHELL" &> /dev/null; then
    log_message "Installing $PREFERRED_SHELL..."
    sudo apt-get update && sudo apt-get install -y "$PREFERRED_SHELL"
fi

# Set the preferred shell as the default shell for the user
if [ "$SHELL" != "$(which $PREFERRED_SHELL)" ]; then
    log_message "Changing default shell to $PREFERRED_SHELL..."
    sudo chsh -s "$(which $PREFERRED_SHELL)" "$USER"
fi

log_message "Shell configuration completed."