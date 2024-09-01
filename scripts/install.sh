#!/bin/bash

set -euo pipefail

# Obtenha o diretório do script atual
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers/utils.sh"

main() {
    local log_file
    log_file="$(yq e '.paths.log_file' "$CONFIG_FILE")"
    setup_logging "$log_file"

    load_env_variables "$CONFIG_FILE"
    load_core_files "$SCRIPT_DIR/core"

    local profile
    profile=$(select_profile "$CONFIG_FILE" "$@")
    
    local tools
    mapfile -t tools < <(yq e ".profiles.$profile[]" "$CONFIG_FILE")

    for tool in "${tools[@]}"; do
        if ! install_tool "$tool" "$DOTFILES_DIR" "$CONFIG_FILE"; then
            log_error "Failed to install $tool"
            exit 1
        fi
    done

    install_third_party_plugins "$SCRIPT_DIR/third_party_plugins.sh"

    log_info "Installation completed successfully!"
}

main "$@"
