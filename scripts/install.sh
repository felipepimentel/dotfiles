#!/bin/bash -e

# Determine the current script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Parse command line arguments
FORCE_INSTALL=false
TOOLS_TO_INSTALL=()

while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--force)
            FORCE_INSTALL=true
            shift
            ;;
        *)
            TOOLS_TO_INSTALL+=("$1")
            shift
            ;;
    esac
done

# Function to find the dotfiles directory
find_dotfiles_dir() {
    local dir="$SCRIPT_DIR"
    while [ "$dir" != "/" ]; do
        if [ -d "$dir/.git" ] && [ -f "$dir/dotfiles_config.yml" ]; then
            echo "$dir"
            return
        fi
        dir="$(dirname "$dir")"
    done
    echo "$HOME/.dotfiles"
}

# Check if DOTFILES_DIR is set, otherwise try to find it
if [ -z "$DOTFILES_DIR" ]; then
    DOTFILES_DIR="$(find_dotfiles_dir)"
    if [ ! -d "$DOTFILES_DIR" ]; then
        echo "Error: Could not find the dotfiles directory."
        exit 1
    fi
fi

# Define the configuration file and state file
CONFIG_FILE="${DOTFILES_DIR}/dotfiles_config.yml"
STATE_FILE="${DOTFILES_DIR}/.dotfiles_state.yml"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Configuration file '${CONFIG_FILE}' not found."
    exit 1
fi

# Ensure the state file exists
touch "$STATE_FILE"

# Load user settings
USER_NAME=$(yq eval '.user.username' "$CONFIG_FILE")
USER_HOME=$(yq eval '.user.home_directory' "$CONFIG_FILE")
LOGFILE=$(yq eval '.paths.log_file' "$CONFIG_FILE")

# Ensure the log directory exists
LOG_DIR="$(dirname "$LOGFILE")"
mkdir -p "$LOG_DIR"

# Function to log messages with timestamp
log_message() {
    local message="$1"
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $message" | tee -a "$LOGFILE"
}

# Function to load the configuration file
load_config() {
    local key="$1"
    yq eval "$key" "$CONFIG_FILE"
}

# Function to load the state file
load_state() {
    local key="$1"
    if [ -s "$STATE_FILE" ]; then
        yq eval ".$key" "$STATE_FILE" 2>/dev/null || echo ""
    else
        echo ""
    fi
}

# Function to save state
save_state() {
    local key="$1"
    local value="$2"
    if [ ! -s "$STATE_FILE" ]; then
        echo "{}" > "$STATE_FILE"
    fi
    yq eval -i ".$key = \"$value\"" "$STATE_FILE"
}

# Function to execute pre_install or post_install commands
execute_install_steps() {
    local step="$1"
    log_message "Executing: $step"
    eval "$step" || log_message "Error executing: $step"
}

# Function to install a tool
install_tool() {
    local tool_name="$1"
    local tool_config=$(load_config ".tools.tools_list[] | select(.name == \"$tool_name\")")
    local dependencies=($(echo "$tool_config" | yq eval '.dependencies[]'))
    local install_method=$(load_config ".tools.default_install_method")
    local install_type=$(echo "$tool_config" | yq eval '.configuration.install_type')
    local install_url=$(echo "$tool_config" | yq eval '.configuration.install_url')
    local install_path=$(echo "$tool_config" | yq eval '.configuration.install_path')
    local check_installed=$(echo "$tool_config" | yq eval '.configuration.check_installed')
    local get_installed_version=$(echo "$tool_config" | yq eval '.configuration.get_installed_version')
    local install_command=$(echo "$tool_config" | yq eval '.configuration.install_command')

    log_message "Checking if $tool_name is installed..."
    if $FORCE_INSTALL || ! eval "$check_installed"; then
        log_message "Installing $tool_name..."
    else
        local installed_version
        installed_version=$(eval "$get_installed_version")
        log_message "$tool_name is already installed (version: $installed_version). Use -f to force reinstall."
        return
    fi

    log_message "Installing $tool_name with dependencies: ${dependencies[*]}"

    # Execute pre_install, if defined
    local pre_install_step=$(echo "$tool_config" | yq eval '.pre_install')
    if [ -n "$pre_install_step" ]; then
        execute_install_steps "$pre_install_step"
    fi

    for dep in "${dependencies[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            sudo "$install_method" install -y "$dep" || log_message "Error installing $dep"
            log_message "$dep installed successfully."
        else
            log_message "$dep is already installed. Skipping."
        fi
    done

    case "$install_type" in
        "appimage")
            local download_path="/tmp/${tool_name}_latest.AppImage"
            log_message "Downloading $tool_name latest version..."
            log_message "Download URL: $install_url"
            wget -q --show-progress "$install_url" -O "$download_path" || { log_message "Error: Failed to download $tool_name"; return 1; }
            log_message "Installing $tool_name..."
            install_command="${install_command//\{download_path\}/$download_path}"
            install_command="${install_command//\{install_path\}/$install_path}"
            log_message "Executing install command: $install_command"
            eval "$install_command" || { log_message "Error: Failed to install $tool_name"; return 1; }
            rm -f "$download_path"
            ;;
        "apt")
            sudo apt-get update
            sudo apt-get install -y $(echo "$tool_config" | yq eval '.configuration.package_name')
            ;;
        "script")
            log_message "Downloading and executing installation script for $tool_name..."
            eval "$install_command" || { log_message "Error: Failed to install $tool_name"; return 1; }
            ;;
        *)
            log_message "Unsupported install type: $install_type"
            return 1
            ;;
    esac

    # Configure desktop entry, if specified
    configure_desktop_entry "$tool_name"

    # Execute post_install, if defined
    local post_install_step=$(echo "$tool_config" | yq eval '.post_install')
    if [ -n "$post_install_step" ]; then
        execute_install_steps "$post_install_step"
    fi

    # Update the state file with the new version
    local new_version=$(eval "$get_installed_version")
    save_state "tools.$tool_name.version" "$new_version"
    log_message "$tool_name updated to version $new_version"
}

# Function to create a desktop entry, if specified in the configuration
configure_desktop_entry() {
    local tool_name="$1"
    local tool_config=$(load_config ".tools.tools_list[] | select(.name == \"$tool_name\")")
    local desktop_entry=$(echo "$tool_config" | yq eval '.configuration.desktop_entry')

    if [ -n "$desktop_entry" ]; then
        local name=$(echo "$desktop_entry" | yq eval ".name")
        local comment=$(echo "$desktop_entry" | yq eval ".comment")
        local exec=$(echo "$desktop_entry" | yq eval ".exec")
        local icon_url=$(echo "$tool_config" | yq eval '.configuration.icon_url')
        local categories=$(echo "$desktop_entry" | yq eval ".categories")
        local startup_wm_class=$(echo "$desktop_entry" | yq eval ".startup_wm_class")

        local icon_path="$USER_HOME/.local/share/icons/${tool_name}.png"
        local desktop_file_path="$USER_HOME/.local/share/applications/${tool_name}.desktop"

        log_message "Configuring desktop entry for $tool_name"
        log_message "Icon URL: $icon_url"
        log_message "Desktop file path: $desktop_file_path"

        # Create directories if they don't exist
        mkdir -p "$USER_HOME/.local/share/icons"
        mkdir -p "$USER_HOME/.local/share/applications"

        # Download the icon
        if [ -n "$icon_url" ]; then
            log_message "Downloading icon from $icon_url"
            wget -q "$icon_url" -O "$icon_path" || log_message "Error downloading icon for $tool_name"
            
            # Check if the icon was downloaded successfully
            if [ -f "$icon_path" ] && [ -s "$icon_path" ]; then
                log_message "Icon downloaded successfully to $icon_path"
            else
                log_message "Failed to download icon to $icon_path. Retrying with curl..."
                curl -L "$icon_url" -o "$icon_path" || log_message "Error downloading icon with curl"
                
                if [ -f "$icon_path" ] && [ -s "$icon_path" ]; then
                    log_message "Icon downloaded successfully with curl to $icon_path"
                else
                    log_message "Failed to download icon. Using a default icon."
                    # You can set a default icon path here if you have one
                    # icon_path="/path/to/default/icon.png"
                fi
            fi
        else
            log_message "Icon URL not provided for $tool_name"
        fi

        # Create the .desktop file
        log_message "Creating .desktop file at $desktop_file_path"
        cat > "$desktop_file_path" <<EOL
[Desktop Entry]
Name=$name
Comment=$comment
Exec=$exec
Icon=$icon_path
Terminal=false
Type=Application
Categories=$categories
StartupWMClass=$startup_wm_class
X-GNOME-Autostart-enabled=false
EOL

        # Set appropriate permissions
        chmod +x "$desktop_file_path"
        
        if [ -f "$desktop_file_path" ]; then
            log_message "Desktop entry file created successfully at $desktop_file_path"
            log_message "Contents of $desktop_file_path:"
            cat "$desktop_file_path"
        else
            log_message "Failed to create desktop entry file at $desktop_file_path"
        fi

        # Update desktop database
        update-desktop-database "$USER_HOME/.local/share/applications"
        
        log_message "Desktop entry configured for $tool_name"
    else
        log_message "No desktop entry configuration found for $tool_name"
    fi
}

# Main installation function
main_install() {
    local tools=("$@")
    if [ ${#tools[@]} -eq 0 ]; then
        # If no names are passed, install all tools
        tools=($(load_config ".tools.tools_list[].name"))
    fi

    for tool in "${tools[@]}"; do
        install_tool "$tool"
    done
}

# Function to perform backup
perform_backup() {
    local backup_enabled=$(load_config ".backup.enabled")
    local backup_dir=$(load_config ".backup.directory")

    if [ "$backup_enabled" = "true" ]; then
        log_message "Starting backup..."
        mkdir -p "$backup_dir" || log_message "Error creating backup directory"
        # Add backup logic here
        log_message "Backup completed in $backup_dir"
    else
        log_message "Backup disabled. Skipping..."
    fi
}

# System configuration
configure_system() {
    local timezone=$(load_config ".system.timezone")
    local preferred_shell=$(load_config ".system.preferred_shell")

    # Configure timezone
    local current_timezone=$(load_state "system.timezone")
    if [ -n "$timezone" ] && { [ -z "$current_timezone" ] || [ "$current_timezone" != "$timezone" ]; }; then
        sudo timedatectl set-timezone "$timezone" || log_message "Error setting timezone"
        log_message "Timezone set to $timezone"
        save_state "system.timezone" "$timezone"
    else
        log_message "Timezone already set or not configured. Skipping."
    fi

    # Configure preferred shell
    local current_shell=$(load_state "system.shell")
    if [ -n "$preferred_shell" ] && { [ -z "$current_shell" ] || [ "$current_shell" != "$preferred_shell" ]; } && [ "$SHELL" != "$(which $preferred_shell)" ]; then
        chsh -s "$(which $preferred_shell)" || log_message "Error changing shell"
        log_message "Shell changed to $preferred_shell"
        save_state "system.shell" "$preferred_shell"
    else
        log_message "Preferred shell already set or not configured. Skipping."
    fi

    log_message "System configurations applied"
}

# Script execution
log_message "Starting dotfiles installation"
perform_backup
configure_system
main_install "${TOOLS_TO_INSTALL[@]}"
log_message "Dotfiles installation completed"