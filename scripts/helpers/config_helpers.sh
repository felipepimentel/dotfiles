#!/bin/bash

load_config() {
    local key="$1"
    local config_file="$2"
    yq eval "$key" "$config_file"
}

find_dotfiles_dir() {
    local script_dir="$1"
    local dir="$script_dir"
    while [ "$dir" != "/" ]; do
        if [ -d "$dir/.git" ] && [ -f "$dir/dotfiles_config.yml" ]; then
            echo "$dir"
            return
        fi
        dir="$(dirname "$dir")"
    done
    echo "$HOME/.dotfiles"
}
