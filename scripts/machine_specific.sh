#!/bin/bash -e

# Determine the directory of the current script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Include the common.sh file
if [ -f "$SCRIPT_DIR/common.sh" ]; then
    source "$SCRIPT_DIR/common.sh"
else
    echo "Error: common.sh not found in $SCRIPT_DIR"
    exit 1
fi

log_message "Applying machine-specific configurations..."

HOSTNAME=$(hostname)

case $HOSTNAME in
  "laptop")
    # Laptop-specific configurations
    ;;
  "desktop")
    # Desktop-specific configurations
    ;;
  *)
    log_message "No specific configuration for $HOSTNAME"
    ;;
esac

log_message "Machine-specific configurations applied."