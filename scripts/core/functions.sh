#!/bin/bash

# Função para navegar rapidamente para o diretório dotfiles
cd_dotfiles() {
    cd "$(yq eval '.paths.dotfiles_directory' ../dotfiles_config.yml)"
}

# Função para criar um backup rápido de um arquivo
backup_file() {
    local file=$1
    cp "$file" "${file}.bak"
    echo "Backup de $file criado como ${file}.bak"
}
