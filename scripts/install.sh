#!/bin/bash

set -euo pipefail

VERSION="1.1.4"

# Colors and formatting
BOLD='\033[1m'
RESET='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'

# Global error handler
trap 'catch_error $? $LINENO' ERR

catch_error() {
    local exit_code=$1
    local line_no=$2
    echo -e "${RED}✖ Error encountered in script at line $line_no with exit code $exit_code${RESET}" >&2
}

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_FILE="$DOTFILES_DIR/config/dotfiles_config.yml"

# Logging functions
log() {
    local color=$1
    local symbol=$2
    shift 2
    echo -e "${color}${symbol} ${RESET}$*"
}

log_info() { log "$BLUE" "ℹ" "$@"; }
log_success() { log "$GREEN" "✔" "$@"; }
log_warning() { log "$YELLOW" "⚠" "$@"; }
log_error() { log "$RED" "✖" "$@" >&2; }

log_section() {
    echo -e "\n${BOLD}${MAGENTA}$1${RESET}"
    echo -e "${MAGENTA}$(printf '=%.0s' {1..50})${RESET}"
}

# Check if the required commands exist
check_dependencies() {
    local deps=("yq" "wget" "curl")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            log_error "Required dependency not found: $dep"
            exit 1
        fi
    done
    log_info "All required dependencies are installed"
}

# Check required variables
check_required_variables() {
    log_info "Checking required variables"
    local required_vars=("SCRIPT_DIR" "DOTFILES_DIR" "CONFIG_FILE")
    for var in "${required_vars[@]}"; do
        if [ -z "${!var:-}" ]; then
            log_error "Required variable $var is not set or empty"
            exit 1
        fi
    done
    log_info "All required variables are set and valid"
}

# Set up logging
setup_logging() {
    log_info "Setting up logging"
    local log_file
    log_file=$(yq e '.paths.log_file' "$CONFIG_FILE")
    if [ -z "$log_file" ]; then
        log_error "Log file path is not defined."
        exit 1
    fi
    mkdir -p "$(dirname "$log_file")"
    touch "$log_file" || { log_error "Unable to create log file: $log_file"; exit 1; }
    exec > >(tee -i "$log_file") 2>&1
    log_info "Logging set up at: $log_file"
}

# Load environment variables
load_env_variables() {
    log_info "Loading environment variables"
    local config_file="$1"
    export HOME_DIR=$(yq e '.user.home_directory' "$config_file")
    export USERNAME=$(yq e '.user.username' "$config_file")
    export PREFERRED_SHELL=$(yq e '.system.preferred_shell' "$config_file")
    log_info "Environment variables loaded from $config_file"
}

# Check if an app needs installation
needs_installation() {
    local app_dir="$1"
    local config_file="$app_dir/config.yml"
    if [ ! -f "$config_file" ]; then
        log_warning "Config file not found for $app_dir"
        return 1
    fi
    local install_type
    install_type=$(yq e '.config.install_type' "$config_file")
    if [ -n "$install_type" ] && [ "$install_type" != "null" ]; then
        return 0  # Needs installation
    fi
    return 1  # No installation required
}

# Install the app
install_app() {
    local app_name="$1"
    local dotfiles_dir="$2"
    local app_dir="$dotfiles_dir/apps/$app_name"
    local config_file="$app_dir/config.yml"

    log_info "Installing app: $app_name"
    if [ ! -f "$config_file" ]; then
        log_error "Config for $app_name not found at $config_file"
        return 1
    fi

    local install_type
    install_type=$(yq e '.config.install_type' "$config_file")
    local pre_install
    pre_install=$(yq e '.pre_install' "$config_file")
    local post_install
    post_install=$(yq e '.post_install' "$config_file")

    log_info "Running pre-installation steps for $app_name..."
    eval "$pre_install" || true

    case "$install_type" in
        "appimage")
            local install_url
            install_url=$(yq e '.config.install_url' "$config_file")
            local install_path
            install_path=$(yq e '.config.install_path' "$config_file")
            log_info "Downloading AppImage from $install_url"
            wget -O "$install_path" "$install_url" || {
                log_error "Failed to download AppImage from $install_url"
                return 1
            }
            chmod +x "$install_path" || {
                log_error "Failed to make $install_path executable"
                return 1
            }
            log_success "AppImage for $app_name downloaded and made executable at $install_path"
            ;;
        *)
            log_error "Unsupported install type: $install_type"
            return 1
            ;;
    esac

    log_info "Running post-installation steps for $app_name..."
    eval "$post_install" || true
    
    log_success "$app_name installed/updated successfully"
    return 0
}

# Process each app
process_app() {
    local app_name="$1"
    local dotfiles_dir="$2"
    local app_dir="$dotfiles_dir/apps/$app_name"

    log_info "Processing: $app_name"
    if [ ! -d "$app_dir" ]; then
        log_error "Directory for $app_name not found at $app_dir"
        return 1
    fi

    if needs_installation "$app_dir"; then
        install_app "$app_name" "$dotfiles_dir"
    else
        log_info "$app_name is up to date or does not need installation."
    fi
}

# Main function to process all apps
process_apps() {
    local apps_to_process=("$@")
    local total_apps=${#apps_to_process[@]}
    local processed=0
    local installed=0
    local failed=0

    log_info "Total apps to process: $total_apps"
    log_info "Apps to process: ${apps_to_process[*]}"

    for app_name in "${apps_to_process[@]}"; do
        log_info "Preparing to process app: $app_name"
        if process_app "$app_name" "$DOTFILES_DIR"; then
            ((installed++))
        else
            ((failed++))
        fi
    done

    log_section "Installation Summary"
    echo -e "${GREEN}✔ Installed/Updated:${RESET} $installed"
    echo -e "${RED}✖ Failed:${RESET}           $failed"
    echo -e "${CYAN}Total processed:${RESET}    $total_apps"
}

# Main setup function
setup_environment() {
    check_required_variables
    setup_logging
    load_env_variables "$CONFIG_FILE"
}

# Main script entry
main() {
    local verbose=false
    local specific_app=""
    local skip_os_check=false
    local skip_symlinks=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help) usage ;;
            -v|--verbose) verbose=true; shift ;;
            --version) echo "Version: $VERSION"; exit 0 ;;
            --skip-os-check) skip_os_check=true; shift ;;
            --skip-symlinks) skip_symlinks=true; shift ;;
            *) 
                if [ -z "$specific_app" ]; then
                    specific_app="$1"
                else
                    log_error "Unknown option: $1"
                    usage
                fi
                shift ;;
        esac
    done

    log_section "Initializing Dotfiles Installation (v$VERSION)"
    log_info "Verbose mode: $verbose"
    log_info "Skip OS check: $skip_os_check"
    log_info "Skip symlinks: $skip_symlinks"
    log_info "Specific app: $specific_app"

    check_dependencies
    setup_environment

    local apps_to_process
    if [ -n "$specific_app" ]; then
        apps_to_process=("$specific_app")
    else
        mapfile -t apps_to_process < <(yq e '.apps[]' "$CONFIG_FILE")
    fi

    log_info "Apps to process: ${BOLD}${CYAN}${apps_to_process[*]}${RESET}"
    log_info "Starting to process apps"
    process_apps "${apps_to_process[@]}"
    log_info "Finished processing apps"
}

main "$@"
