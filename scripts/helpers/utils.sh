#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
CONFIG_FILE="$DOTFILES_DIR/dotfiles_config.yml"

# Load paths from config file
DOTFILES_ROOT=$(yq e '.paths.dotfiles_directory' "$CONFIG_FILE")
HOME_DIR=$(yq e '.user.home_directory' "$CONFIG_FILE")
LOG_FILE=$(yq e '.paths.log_file' "$CONFIG_FILE")

check_required_variables() {
    local -a required_vars=("SCRIPT_DIR" "DOTFILES_DIR" "DOTFILES_ROOT" "CONFIG_FILE" "HOME_DIR" "LOG_FILE")
    for var in "${required_vars[@]}"; do
        if [ -z "${!var:-}" ]; then
            echo "Error: Required variable $var is not set" >&2
            exit 1
        fi
    done
}

check_required_variables

# Color variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Setup logging
setup_logging() {
    local log_file="$1"
    mkdir -p "$(dirname "$log_file")"
    touch "$log_file"
    log_info "Logging setup complete. Log file: $log_file"
}

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

# Progress bar function
show_progress() {
    local duration=$1
    local steps=$2
    local sleep_time=$(bc <<< "scale=3; $duration / $steps")
    local progress=0
    local bar_width=40

    echo -ne "\n"
    while [ $progress -le 100 ]; do
        local bar=$(printf "[%-${bar_width}s]" $(printf "=%.0s" $(seq 1 $(($progress * $bar_width / 100)))))
        printf "\r\033[KProgress: $bar ${progress}%%"
        sleep "$sleep_time"
        progress=$((progress + 100 / steps))
    done
    echo -ne "\n"
}

# Add missing functions
load_env_variables() {
    local config_file="$1"
    log_info "Loading environment variables from $config_file"
    # Implement environment variable loading here
}

load_core_files() {
    local core_dir="$1"
    log_info "Loading core files from $core_dir"
    for file in "$core_dir"/*.sh; do
        if [ -f "$file" ]; then
            source "$file"
            log_info "Loaded core file: $file"
        fi
    done
}

select_profile() {
    local config_file="$1"
    shift
    local default_profile=$(yq e '.profiles.default' "$config_file")
    local selected_profile=${1:-$default_profile}
    echo "$selected_profile"
}

install_tool() {
    local tool="$1"
    local dotfiles_root="$2"
    local config_file="$3"
    log_info "Installing $tool"
    # Implement tool installation logic here
    return 0
}

install_third_party_plugins() {
    local plugin_script="$1"
    log_info "Installing third-party plugins using $plugin_script"
    if [ -f "$plugin_script" ]; then
        bash "$plugin_script"
    else
        log_warning "Third-party plugin script not found: $plugin_script"
    fi
    return 0
}

main() {
    setup_logging "$LOG_FILE"
    log_info "Starting installation process..."
    
    load_env_variables "$CONFIG_FILE"
    load_core_files "$SCRIPT_DIR/core"

    local profile
    profile=$(select_profile "$CONFIG_FILE" "$@")
    log_info "Selected profile: $profile"
    
    local tools
    mapfile -t tools < <(yq e ".profiles.$profile[]" "$CONFIG_FILE")
    
    local total_tools=${#tools[@]}
    local current_tool=0

    for tool in "${tools[@]}"; do
        current_tool=$((current_tool + 1))
        log_info "Installing tool ($current_tool/$total_tools): $tool"
        if install_tool "$tool" "$DOTFILES_ROOT" "$CONFIG_FILE"; then
            log_success "Successfully installed $tool"
            show_progress 2 20  # Show a 2-second progress bar
        else
            log_error "Failed to install $tool"
            exit 1
        fi
    done

    log_info "Installing third-party plugins..."
    if install_third_party_plugins "$SCRIPT_DIR/third_party_plugins.sh"; then
        log_success "Third-party plugins installed successfully"
    else
        log_error "Failed to install third-party plugins"
        exit 1
    fi

    log_success "Installation completed successfully!"
}

# Only run main if this script is being run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi