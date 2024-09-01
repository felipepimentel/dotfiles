#!/bin/bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$DOTFILES_DIR/scripts/helpers/utils.sh"

main() {
    local log_file
    log_file="$(yq e '.paths.log_file' "$DOTFILES_DIR/dotfiles_config.yml")"
    setup_logging "$log_file"

    log_info "Updating dotfiles repository..."
    if ! git -C "$DOTFILES_DIR" pull; then
        log_error "Failed to update dotfiles repository"
        exit 1
    fi

    log_info "Re-running install script..."
    if ! bash "$DOTFILES_DIR/scripts/install.sh"; then
        log_error "Failed to run install script"
        exit 1
    fi

    log_info "Dotfiles updated successfully!"
}

main "$@"