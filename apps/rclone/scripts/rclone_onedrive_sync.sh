#!/bin/bash
# Caminho do disco de destino
DESTINATION_PATH="/media/pimentel/Data/OneDrive"
# Caminho remoto do OneDrive
REMOTE="pimentel-onedrive:/"
# Caminho do arquivo de log
LOG_FILE="/home/seu_usuario/rclone_sync.log"

# Sincronizar usando o rclone
rclone sync $REMOTE $DESTINATION_PATH --log-file=$LOG_FILE --verbose
