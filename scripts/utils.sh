#!/bin/bash

# Logging functions with colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Check required variables
check_required_variables() {
    log_info "Checking required variables"
    local -a required_vars=("SCRIPT_DIR" "DOTFILES_DIR" "CONFIG_FILE")
    for var in "${required_vars[@]}"; do
        if [ -z "${!var:-}" ]; then
            log_error "Required variable $var is not set"
            exit 1
        fi
    done
    log_info "All required variables are set"
}

# Set up logging
setup_logging() {
    log_info "Setting up logging"
    local log_file="$1"
    if [ -z "$log_file" ]; then
        log_error "Log file path is not defined."
        exit 1
    fi
    mkdir -p "$(dirname "$log_file")"
    touch "$log_file" || {
        log_error "Unable to create log file: $log_file"
        exit 1
    }
    exec > >(tee -i "$log_file") 2>&1
    log_info "Logging set up at: $log_file"
}

# Load environment variables from config file
load_env_variables() {
    log_info "Loading environment variables"
    local config_file="$1"
    export HOME_DIR=$(yq e '.user.home_directory' "$config_file")
    export USERNAME=$(yq e '.user.username' "$config_file")
    export PREFERRED_SHELL=$(yq e '.system.preferred_shell' "$config_file")
    log_info "Environment variables loaded from $config_file"
}

# Load core files
load_core_files() {
    log_info "Loading core files"
    local core_dir="$1"
    for file in "$core_dir"/*.sh; do
        if [ -f "$file" ]; then
            source "$file"
            log_info "Core file loaded: $file"
        fi
    done
}

# Create symlinks for extension files
create_extension_symlinks() {
    log_info "Creating symlinks for extension files"
    local dotfiles_dir="$1"
    local apps_dir="$dotfiles_dir/apps"

    for app_dir in "$apps_dir"/*; do
        if [ -d "$app_dir" ]; then
            local app_name=$(basename "$app_dir")
            local extension_file="$app_dir/.${app_name}_extension.sh"
            if [ -f "$extension_file" ]; then
                local target_file="$HOME/.${app_name}_extension.sh"
                ln -sf "$extension_file" "$target_file"
                log_info "Symlink created for $app_name extension: $target_file"
            fi
        fi
    done
}

# Install app
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

    local install_type=$(yq e '.config.install_type' "$config_file")
    local check_installed=$(yq e '.config.check_installed' "$config_file")
    local pre_install=$(yq e '.pre_install' "$config_file")
    local post_install=$(yq e '.post_install' "$config_file")
    local override_install=$(yq e '.override_install' "$config_file")

    if eval "$check_installed"; then
        log_info "$app_name is already installed. Proceeding with installation/update."
    fi

    log_info "Running pre-installation steps for $app_name..."
    eval "$pre_install" || true

    if [ "$override_install" == "true" ]; then
        log_info "Using custom installation for $app_name"
        bash "$app_dir/setup.sh" || {
            log_error "Custom installation for $app_name failed"
            return 1
        }
    else
        if [ "$install_type" == "apt" ]; then
            local package_name=$(yq e '.config.package_name' "$config_file")
            log_info "Installing/updating $app_name using apt with package name $package_name"
            sudo apt-get install -y $package_name || {
                log_error "Failed to install $app_name using apt"
                return 1
            }
        elif [ "$install_type" == "flatpak" ]; then
            local package_name=$(yq e '.config.package_name' "$config_file")
            log_info "Installing/updating $app_name using flatpak with package name $package_name"
            flatpak install -y flathub $package_name || {
                log_error "Failed to install $app_name using flatpak"
                return 1
            }
        else
            log_error "Unsupported install type: $install_type"
            return 1
        fi
    fi

    log_info "Running post-installation steps for $app_name..."
    eval "$post_install" || true
    
    log_success "$app_name installed/updated successfully"
    return 0
}