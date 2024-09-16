#!/bin/bash

# Colors and formatting
BOLD='\033[1m'
RESET='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'

log_info() {
    echo -e "${BLUE}ℹ ${RESET}$1"
}

log_success() {
    echo -e "${GREEN}✔ ${RESET}$1"
}

log_warning() {
    echo -e "${YELLOW}⚠ ${RESET}$1"
}

log_error() {
    echo -e "${RED}✖ ${RESET}$1" >&2
}

log_section() {
    echo -e "\n${BOLD}${MAGENTA}$1${RESET}"
    echo -e "${MAGENTA}$(printf '=%.0s' {1..50})${RESET}"
}

# Progress bar function
progress_bar() {
    local current=$1
    local total=$2
    local width=40
    local percentage=$((current * 100 / total))
    local completed=$((width * current / total))
    local remaining=$((width - completed))

    printf "\r[${CYAN}"
    printf "%0.s█" $(seq 1 $completed)
    printf "${RESET}"
    printf "%0.s░" $(seq 1 $remaining)
    printf "${RESET}] ${CYAN}%d%%${RESET}" $percentage
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

# Determine if an app needs installation
needs_installation() {
    local app_dir="$1"
    local config_file="$app_dir/config.yml"
    
    if [ ! -f "$config_file" ]; then
        return 1  # No config file, assume no installation needed
    fi
    
    local install_type=$(yq e '.config.install_type' "$config_file")
    if [ -n "$install_type" ] && [ "$install_type" != "null" ]; then
        return 0  # Installation type specified, needs installation
    else
        return 1  # No installation type, only needs configuration
    fi
}

# Create symlinks for specified apps
create_all_symlinks() {
    local dotfiles_dir="$1"
    local config_file="$dotfiles_dir/config/dotfiles_config.yml"
    
    log_info "Creating symlinks for specified apps"

    local apps_to_process
    mapfile -t apps_to_process < <(yq e '.apps[]' "$config_file")

    for app_name in "${apps_to_process[@]}"; do
        create_app_symlinks "$app_name" "$dotfiles_dir"
    done
}

# Create symlinks for a specific app
create_app_symlinks() {
    local app_name="$1"
    local dotfiles_dir="$2"
    local app_dir="$dotfiles_dir/apps/$app_name"
    local config_file="$app_dir/config.yml"

    log_info "Creating symlinks for app: $app_name"

    if [ ! -f "$config_file" ]; then
        log_warning "Config file not found for $app_name, skipping symlink creation"
        return
    fi

    local config_files
    config_files=$(yq e '.config_files' "$config_file")
    if [ -n "$config_files" ] && [ "$config_files" != "null" ]; then
        while IFS=": " read -r source_file target_file; do
            source_file=$(echo "$source_file" | tr -d '"')
            target_file=$(echo "$target_file" | tr -d '"')
            local full_source_path="$app_dir/$source_file"
            local full_target_path="${target_file/#\~/$HOME}"
            if [ -f "$full_source_path" ]; then
                create_symlink "$full_source_path" "$full_target_path"
            else
                log_warning "Source file not found: $full_source_path"
            fi
        done <<< "$config_files"
    fi
}

create_symlink() {
    local source_file="$1"
    local target_file="$2"
    local target_dir=$(dirname "$target_file")
    
    if [ ! -d "$target_dir" ]; then
        mkdir -p "$target_dir"
    fi
    
    ln -sf "$source_file" "$target_file"
    log_info "Symlink created: $target_file -> $source_file"
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
    local get_installed_version=$(yq e '.config.get_installed_version' "$config_file")
    local pre_install=$(yq e '.pre_install' "$config_file")
    local post_install=$(yq e '.post_install' "$config_file")

    if eval "$check_installed"; then
        log_info "$app_name is already installed. Checking for updates..."
        local installed_version=$(eval "$get_installed_version")
        log_info "Installed version: $installed_version"
        
        # Here you would typically check against the latest version available
        # For demonstration, we'll assume an update is needed if installed
        # In a real scenario, you'd compare versions and only update if needed
        
        if [ "$install_type" == "appimage" ] || [ "$install_type" == "script" ]; then
            log_info "$app_name is already up to date. Skipping installation."
            return 0
        fi
    fi

    log_info "Running pre-installation steps for $app_name..."
    eval "$pre_install" || true

    case "$install_type" in
        "apt")
            local package_name=$(yq e '.config.package_name' "$config_file")
            log_info "Installing/updating $app_name using apt with package name $package_name"
            sudo apt-get install -y $package_name || {
                log_error "Failed to install $app_name using apt"
                return 1
            }
            ;;
        "flatpak")
            local package_name=$(yq e '.config.package_name' "$config_file")
            log_info "Installing/updating $app_name using flatpak with package name $package_name"
            flatpak install -y flathub $package_name || {
                log_error "Failed to install $app_name using flatpak"
                return 1
            }
            ;;
        "appimage")
            local install_url=$(yq e '.config.install_url' "$config_file")
            local install_path=$(yq e '.config.install_path' "$config_file")

            if [ -f "$install_path" ]; then
                log_info "Removing existing AppImage before update"
                rm -f "$install_path" || {
                    log_error "Failed to remove existing AppImage at $install_path"
                    return 1
                }
            fi

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
        "script")
            local install_command=$(yq e '.install_command' "$config_file")
            log_info "Installing $app_name using custom script"
            eval "$install_command" || {
                log_error "Failed to install $app_name using custom script"
                return 1
            }
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