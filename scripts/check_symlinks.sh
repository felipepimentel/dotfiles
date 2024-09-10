#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Load helper functions
source "$SCRIPT_DIR/utils.sh"

# Check for broken symlinks
check_symlinks() {
    log_info "Checking for broken symlinks"
    local directories=("$HOME" "$DOTFILES_DIR")
    local logfile="$DOTFILES_DIR/logs/broken_symlinks.log"

    mkdir -p "$(dirname "$logfile")"
    > "$logfile"

    for dir in "${directories[@]}"; do
        find "$dir" -xtype l >> "$logfile"
    done

    if [ -s "$logfile" ]; then
        log_warning "Broken symlinks found. Check the log: $logfile"
        cat "$logfile"
    else
        log_info "No broken symlinks found."
        rm "$logfile"
    fi
}

# Main function
main() {
    setup_logging "$DOTFILES_DIR/logs/symlink_check.log"
    check_symlinks
}

main "$@"