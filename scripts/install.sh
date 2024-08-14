#!/bin/bash -e

# Determine o usuário real e seu diretório home, mesmo quando executado como root
if [ "$(id -u)" -eq 0 ]; then
    if [ -n "${SUDO_USER:-}" ]; then
        REAL_USER="$SUDO_USER"
        USER_HOME=$(eval echo ~"$SUDO_USER")
    else
        REAL_USER="$USER"
        USER_HOME="$HOME"
    fi
else
    REAL_USER="$USER"
    USER_HOME="$HOME"
fi

# Debug information
echo "Current working directory: $(pwd)"
echo "HOME directory: $HOME"
echo "REAL_USER: $REAL_USER"
echo "USER_HOME: $USER_HOME"

# Load configuration
CONFIG_FILE="$USER_HOME/.dotfiles/dotfiles_config.yml"
DOTFILES_DIR=$(yq eval '.paths.dotfiles_directory' "$CONFIG_FILE")
SCRIPTS_DIR="$DOTFILES_DIR/scripts"
LOGFILE=$(yq eval '.paths.log_file' "$CONFIG_FILE")

echo "DOTFILES_DIR: $DOTFILES_DIR"
echo "SCRIPTS_DIR: $SCRIPTS_DIR"
echo "LOGFILE: $LOGFILE"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install yq
install_yq() {
    echo "yq not found. Installing..."
    if command_exists apt-get; then
        sudo apt-get update && sudo apt-get install -y wget
        YQ_VERSION="v4.30.6"
        YQ_BINARY="yq_linux_amd64"
        sudo wget https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/${YQ_BINARY} -O /usr/bin/yq && sudo chmod +x /usr/bin/yq
    elif command_exists brew; then
        brew install yq
    else
        echo "Unable to install yq automatically. Please install it manually and run the script again."
        exit 1
    fi
}

# Check and install yq if necessary
if ! command_exists yq; then
    install_yq
fi

# Source common functions
if [ -f "$SCRIPTS_DIR/common.sh" ]; then
    source "$SCRIPTS_DIR/common.sh"
else
    echo "Error: common.sh not found in $SCRIPTS_DIR"
    exit 1
fi

# Source installation control script
if [ -f "$SCRIPTS_DIR/installation_control.sh" ]; then
    source "$SCRIPTS_DIR/installation_control.sh"
else
    echo "Error: installation_control.sh not found in $SCRIPTS_DIR"
    exit 1
fi

log_message "Starting dotfiles installation"

# OS configuration
sudo timedatectl set-timezone "$(yq eval '.system.timezone' "$CONFIG_FILE")" || log_message "Failed to set timezone"

# Update system packages
log_message "Updating system packages..."
if command_exists apt-get; then
    sudo apt-get update && sudo apt-get upgrade -y
elif command_exists dnf; then
    sudo dnf upgrade -y
elif command_exists pacman; then
    sudo pacman -Syu --noconfirm
else
    log_message "Unable to update system packages. Unknown package manager."
fi

# Install tools and apps
for tool in $(yq eval '.tools[].name' "$CONFIG_FILE"); do
    run_script_once "$SCRIPTS_DIR/install_${tool}.sh" || log_message "Installation script for $tool not found. Skipping."
done

# Run tests
run_script_once "$SCRIPTS_DIR/run_tests.sh" || log_message "run_tests.sh not found. Skipping tests."

log_message "Dotfiles installation completed"

# Reminder for the user
echo "Remember to check for updates periodically using:"
echo "bash $SCRIPTS_DIR/update.sh"

# Suggest a system reboot
echo "It's recommended to reboot your system to ensure all changes take effect."
read -p "Do you want to reboot now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo reboot
fi
