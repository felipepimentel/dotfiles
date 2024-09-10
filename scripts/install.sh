#!/bin/bash

set -euo pipefail

# Diretório do script atual
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

# Função principal
main() {
    # Configurações e diretórios
    local config_file="$SCRIPT_DIR/config/dotfiles_config.yml"
    local dotfiles_dir=$(yq e '.paths.dotfiles_directory' "$config_file")
    local log_file=$(yq e '.paths.log_file' "$config_file")

    # Configurar logging
    setup_logging "$log_file"

    # Carregar variáveis de ambiente e arquivos centrais
    load_env_variables "$config_file"
    load_core_files "$SCRIPT_DIR/core"

    # Criar symlinks e verificar symlinks quebrados
    create_symlinks "$dotfiles_dir"
    check_symlinks "$dotfiles_dir"

    # Instalar ferramentas configuradas
    local tools
    mapfile -t tools < <(yq e ".tools.apps[]" "$config_file")

    for tool in "${tools[@]}"; do
        if ! install_tool "$tool" "$dotfiles_dir" "$config_file"; then
            log_error "Falha ao instalar $tool"
            exit 1
        fi
    done

    # Instalar plugins de terceiros
    install_third_party_plugins "$SCRIPT_DIR/third_party_plugins.sh"

    log_info "Execução concluída com sucesso!"
}

main "$@"
