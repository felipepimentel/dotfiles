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

# Ensure the log directory exists
LOG_DIR=$(dirname "$LOGFILE")
mkdir -p "$LOG_DIR"

# Function to ensure log file permissions
ensure_log_permissions() {
    if [ ! -f "$LOGFILE" ]; then
        sudo -u "$REAL_USER" touch "$LOGFILE"
    fi
    sudo chown "$REAL_USER:$REAL_USER" "$LOGFILE"
    sudo chmod 644 "$LOGFILE"
}

# Call the function to ensure permissions
ensure_log_permissions

echo "DOTFILES_DIR: $DOTFILES_DIR"
echo "SCRIPTS_DIR: $SCRIPTS_DIR"
echo "LOGFILE: $LOGFILE"

# Function to log messages
log_message() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOGFILE"
}

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

# Ensure .installation_control file has the correct ownership and permissions
CONTROL_FILE="$DOTFILES_DIR/.installation_control"
if [ ! -f "$CONTROL_FILE" ]; then
    sudo -u "$REAL_USER" touch "$CONTROL_FILE"
    sudo chown "$REAL_USER:$REAL_USER" "$CONTROL_FILE"
    sudo chmod 644 "$CONTROL_FILE"
fi

# Function to check if a script has been executed
script_executed() {
    grep -q "^$1$" "$CONTROL_FILE" 2>/dev/null
}

# Function to mark a script as executed
mark_script_executed() {
    echo "$1" >> "$CONTROL_FILE"
}

# Function to run a script if it hasn't been executed before
run_script_once() {
    local script_name=$(basename "$1")
    if ! script_executed "$script_name"; then
        if bash "$1"; then
            mark_script_executed "$script_name"
            echo "Script $script_name executed successfully and marked as completed."
        else
            echo "Script $script_name failed. It will be attempted again on next run."
        fi
    else
        echo "Script $script_name has already been executed. Skipping."
    fi
}

# Function to read values from YAML file
get_config_value() {
    yq eval "$1" "$CONFIG_FILE"
}

# Function to run commands as the real user
run_as_user() {
    sudo -u "$REAL_USER" "$@"
}

log_message "Starting dotfiles installation"

### OS Setup
log_message "Setting up OS..."
sudo apt-get update && sudo apt-get upgrade -y

essential_packages=(
    curl wget git vim xclip unzip dconf-cli jq zsh tilix
)

for package in "${essential_packages[@]}"; do
    if ! command_exists "$package"; then
        sudo apt-get install -y "$package"
        log_message "Installed $package"
    else
        log_message "$package is already installed. Skipping."
    fi
done

log_message "OS setup completed."

### Shell Setup
log_message "Setting up shell configuration..."

PREFERRED_SHELL=$(get_config_value '.system.preferred_shell')

if ! command_exists "$PREFERRED_SHELL"; then
    log_message "Installing $PREFERRED_SHELL..."
    sudo apt-get update && sudo apt-get install -y "$PREFERRED_SHELL"
fi

if [ "$SHELL" != "$(which $PREFERRED_SHELL)" ]; then
    log_message "Changing default shell to $PREFERRED_SHELL..."
    sudo chsh -s "$(which $PREFERRED_SHELL)" "$REAL_USER"
fi

log_message "Shell configuration completed."

### Install Tools and Apps
log_message "Installing tools and apps..."
for tool in $(yq eval '.tools[].name' "$CONFIG_FILE"); do
    case "$tool" in
        "edge")
            log_message "Installing Microsoft Edge..."

            if ! grep -q "^deb .*microsoft.com" /etc/apt/sources.list /etc/apt/sources.list.d/*; then
                curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
                sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
                sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main" > /etc/apt/sources.list.d/microsoft-edge.list'
                rm microsoft.gpg
                log_message "Microsoft Edge repository added."
            else
                log_message "Microsoft Edge repository already exists. Skipping addition."
            fi

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
            ;;
        *)
            run_script_once "$SCRIPTS_DIR/install_${tool}.sh" || log_message "Installation script for $tool not found. Skipping."
            ;;
    esac
done

### Run Tests
log_message "Running tests..."
if [ -f "$SCRIPTS_DIR/run_tests.sh" ]; then
    run_script_once "$SCRIPTS_DIR/run_tests.sh" || log_message "run_tests.sh not found. Skipping tests."
fi

log_message "Dotfiles installation completed."

# Reminder for the user
echo "Remember to check for updates periodically using:"
echo "bash $SCRIPTS_DIR/install_dotfiles.sh"

# Suggest a system reboot
# echo "It's recommended to reboot your system to ensure all changes take effect."
# read -p "Do you want to reboot now? (y/n) " -n 1 -r
# echo
# if [[ $REPLY =~ ^[Yy]$ ]]; then
#     sudo reboot
# fi
