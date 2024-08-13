#!/bin/bash

CONTROL_FILE="$DOTFILES_DIR/.installation_control"

# Function to check if a script has been executed
script_executed() {
    grep -q "^$1$" "$CONTROL_FILE" 2>/dev/null
}

# Function to mark a script as executed
mark_script_executed() {
    echo "$1" >> "$CONTROL_FILE"
}

# Function to run a script if it hasn't been executed before
run_script_once() {
    local script_name=$(basename "$1")
    if ! script_executed "$script_name"; then
        if bash "$1"; then
            mark_script_executed "$script_name"
            echo "Script $script_name executed successfully and marked as completed."
        else
            echo "Script $script_name failed. It will be attempted again on next run."
        fi
    else
        echo "Script $script_name has already been executed. Skipping."
    fi
}

# Ensure the control file exists
touch "$CONTROL_FILE"