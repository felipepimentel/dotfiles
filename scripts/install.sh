#!/bin/bash 

set -uo pipefail

# Global error handler
trap 'catch_error $? $LINENO' ERR

catch_error() {
    local exit_code=$1
    local line_no=$2
    echo "Error encountered in script at line $line_no with exit code $exit_code" >&2
}

# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Dotfiles root directory
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Correct path to the configuration file
CONFIG_FILE="$DOTFILES_DIR/config/dotfiles_config.yml"

# Load helper functions
source "$SCRIPT_DIR/utils.sh"

# Main function
main() {
    # Check required variables
    check_required_variables

    # Configurations and directories
    local log_file=$(yq e '.paths.log_file' "$CONFIG_FILE")
    local dotfiles_dir=$(yq e '.paths.dotfiles_directory' "$CONFIG_FILE")

    # Set up logging
    setup_logging "$log_file"

    # Load environment variables and core files
    load_env_variables "$CONFIG_FILE"
    load_core_files "$SCRIPT_DIR/core"

    # Create symlinks for extension files and app-specific configs
    create_extension_symlinks "$dotfiles_dir"

    # Get the list of apps to install from the config file
    local apps_to_install
    mapfile -t apps_to_install < <(yq e '.apps[]' "$CONFIG_FILE")

    log_info "Apps to install: ${apps_to_install[*]}"

    local installed=0
    local failed=0

    log_info "Starting app installation/update..."
    for app_name in "${apps_to_install[@]}"; do
        log_info "Processing app: $app_name"
        if install_app "$app_name" "$dotfiles_dir"; then
            log_success "$app_name was installed/updated successfully"
            ((installed++))
        else
            log_error "Failed to install/update $app_name"
            ((failed++))
        fi
    done

    # Installation summary
    log_info "Installation/update summary:"
    log_success "$installed apps installed/updated successfully."
    log_error "$failed apps failed to install/update."

    log_info "Execution completed successfully!"
}

main "$@"