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

# Include the installation_control.sh file
if [ -f "$SCRIPT_DIR/installation_control.sh" ]; then
    source "$SCRIPT_DIR/installation_control.sh"
else
    echo "Error: installation_control.sh not found in $SCRIPT_DIR"
    exit 1
fi

if script_executed "$(basename "$0")"; then
    log_message "Docker installation script has already been executed. Skipping."
    exit 0
fi

log_message "Installing Docker..."

if ! command -v docker &> /dev/null; then
    # Remove old versions
    sudo apt-get remove docker docker-engine docker.io containerd runc

    # Set up the repository
    sudo apt-get update
    sudo apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release

    # Add Docker's official GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

    # Set up the stable repository
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Install Docker Engine
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io

    # Add current user to docker group
    sudo usermod -aG docker $USER

    log_message "Docker installed successfully. You may need to log out and log back in for group permissions to take effect."
    mark_script_executed "$(basename "$0")"
else
    log_message "Docker is already installed."
    mark_script_executed "$(basename "$0")"
fi