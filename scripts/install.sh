#!/bin/bash 

set -uo pipefail

# Global error handler
trap 'catch_error $? $LINENO' ERR

catch_error() {
    local exit_code=$1
    local line_no=$2
    echo -e "${RED}✖ Error encountered in script at line $line_no with exit code $exit_code${RESET}" >&2
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
    log_section "Initializing Dotfiles Installation"
    
    check_required_variables

    local log_file=$(yq e '.paths.log_file' "$CONFIG_FILE")
    local dotfiles_dir=$(yq e '.paths.dotfiles_directory' "$CONFIG_FILE")

    setup_logging "$log_file"
    load_env_variables "$CONFIG_FILE"
    load_core_files "$SCRIPT_DIR/core"

    log_section "Creating Symlinks"
    create_all_symlinks "$dotfiles_dir"

    local apps_to_process
    mapfile -t apps_to_process < <(yq e '.apps[]' "$CONFIG_FILE")

    log_info "Apps to process: ${BOLD}${CYAN}${apps_to_process[*]}${RESET}"

    local total_apps=${#apps_to_process[@]}
    local processed=0
    local installed=0
    local configured=0
    local failed=0

    log_section "Processing Apps"
    for app_name in "${apps_to_process[@]}"; do
        ((processed++))
        progress_bar $processed $total_apps
        echo -e "\n${BOLD}${CYAN}Processing: $app_name${RESET}"
        
        local app_dir="$dotfiles_dir/apps/$app_name"
        
        if [ ! -d "$app_dir" ]; then
            log_error "Directory for $app_name not found at $app_dir"
            ((failed++))
            continue
        fi

        if needs_installation "$app_dir"; then
            if install_app "$app_name" "$dotfiles_dir"; then
                log_success "$app_name was installed/updated successfully"
                ((installed++))
            else
                log_error "Failed to install/update $app_name"
                ((failed++))
            fi
        else
            create_app_symlinks "$app_name" "$dotfiles_dir"
            log_info "$app_name only needs configuration, skipping installation"
            ((configured++))
        fi
    done

    log_section "Installation Summary"
    echo -e "${GREEN}✔ Installed/Updated:${RESET} $installed"
    echo -e "${BLUE}ℹ Configured:${RESET}       $configured"
    echo -e "${RED}✖ Failed:${RESET}           $failed"
    echo -e "${CYAN}Total processed:${RESET}    $total_apps"

    if [ $failed -eq 0 ]; then
        log_success "Dotfiles installation completed successfully!"
    else
        log_warning "Dotfiles installation completed with some issues. Check the log for details."
    fi
}

main "$@"