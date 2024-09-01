#!/bin/bash

THIRD_PARTY_FILE="$DOTFILES_DIR/third_party_plugins.yml"

if [ -f "$THIRD_PARTY_FILE" ]; then
    while IFS=: read -r plugin_name plugin_url; do
        log "Instalando plugin de terceiros: $plugin_name"
        git clone "$plugin_url" "$DOTFILES_DIR/plugins/$plugin_name"
        # Adicione lógica adicional para configurar o plugin, se necessário
    done < "$THIRD_PARTY_FILE"
fi
