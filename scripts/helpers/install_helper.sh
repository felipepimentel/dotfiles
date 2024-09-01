#!/bin/bash

install_tool() {
    local tool_name="$1"
    local force_install="$2"
    local config_file="$3"
    local state_file="$4"

    local tool_config
    tool_config=$(load_config ".tools.tools_list[] | select(.name == \"$tool_name\")" "$config_file")
    local dependencies=($(echo "$tool_config" | yq eval '.dependencies[]'))
    local install_type=$(echo "$tool_config" | yq eval '.config.install_type')
    local check_installed=$(echo "$tool_config" | yq eval '.config.check_installed')

    log_info "Checking if $tool_name is installed..."
    if $force_install || ! eval "$check_installed"; then
        log_info "Installing $tool_name..."
        install_dependencies "${dependencies[@]}"
        execute_install "$tool_name" "$install_type" "$tool_config"
        configure_desktop_entry "$tool_name" "$config_file"
        update_state "$tool_name" "$state_file"
    else
        local installed_version
        installed_version=$(eval "$(echo "$tool_config" | yq eval '.config.get_installed_version')")
        log_info "$tool_name is already installed (version: $installed_version). Use -f to force reinstall."
    fi
}

install_dependencies() {
    local deps=("$@")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            sudo apt-get install -y "$dep" || log_error "Error installing $dep"
            log_info "$dep installed successfully."
        else
            log_info "$dep is already installed. Skipping."
        fi
    done
}

execute_install() {
    local tool_name="$1"
    local install_type="$2"
    local tool_config="$3"
    # Add logic to execute different install types
}

configure_desktop_entry() {
    local tool_name="$1"
    local config_file="$2"
    # Logic to configure desktop entry
}

update_state() {
    local tool_name="$1"
    local state_file="$2"
    # Logic to update state file
}

configure_timezone() {
    local timezone="$1"
    local state_file="$2"
    local current_timezone=$(load_state "system.timezone" "$state_file")

    if [ -n "$timezone" ] && { [ -z "$current_timezone" ] || [ "$current_timezone" != "$timezone" ]; }; then
        sudo timedatectl set-timezone "$timezone" || log_error "Error setting timezone"
        log_info "Timezone set to $timezone"
        save_state "system.timezone" "$timezone" "$state_file"
    else
        log_info "Timezone already set or not configured. Skipping."
    fi
}

configure_shell() {
    local preferred_shell="$1"
    local state_file="$2"
    local current_shell=$(load_state "system.shell" "$state_file")

    if [ -n "$preferred_shell" ] && { [ -z "$current_shell" ] || [ "$current_shell" != "$preferred_shell" ]; } && [ "$SHELL" != "$(which $preferred_shell)" ]; then
        chsh -s "$(which $preferred_shell)" || log_error "Error changing shell"
        log_info "Shell changed to $preferred_shell"
        save_state "system.shell" "$preferred_shell" "$state_file"
    else
        log_info "Preferred shell already set or not configured. Skipping."
    fi
}
