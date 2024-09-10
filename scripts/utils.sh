#!/bin/bash

set -euo pipefail

# Variáveis globais
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
CONFIG_FILE="$DOTFILES_DIR/config/dotfiles_config.yml"

# Verificar variáveis necessárias
check_required_variables() {
    local -a required_vars=("SCRIPT_DIR" "DOTFILES_DIR" "CONFIG_FILE")
    for var in "${required_vars[@]}"; do
        if [ -z "${!var:-}" ]; then
            echo "Erro: Variável $var não está definida" >&2
            exit 1
        fi
    done
}

check_required_variables

# Configurar logging
setup_logging() {
    local log_file="$1"
    mkdir -p "$(dirname "$log_file")"
    touch "$log_file"
    exec > >(tee -i "$log_file") 2>&1
    log_info "Configuração de logging completa. Arquivo de log: $log_file"
}

# Funções de logging
log_info() {
    echo -e "[INFO] $1"
}

log_error() {
    echo -e "[ERROR] $1" >&2
}

# Carregar variáveis de ambiente do arquivo de configuração
load_env_variables() {
    local config_file="$1"
    export HOME_DIR=$(yq e '.user.home_directory' "$config_file")
    export USERNAME=$(yq e '.user.username' "$config_file")
    export PREFERRED_SHELL=$(yq e '.system.preferred_shell' "$config_file")
    log_info "Variáveis de ambiente carregadas."
}

# Carregar arquivos centrais
load_core_files() {
    local core_dir="$1"
    for file in "$core_dir"/*.sh; do
        [ -f "$file" ] && source "$file" && log_info "Arquivo central carregado: $file"
    done
}

# Criar symlinks
create_symlinks() {
    local dotfiles_dir="$1"
    log_info "Criando symlinks..."

    local files=(
        ".gitconfig"
        # Adicione outros arquivos aqui
    )

    for file in "${files[@]}"; do
        [ -f "$HOME/$file" ] && mv "$HOME/$file" "$HOME/${file}.bak" && log_info "Backup criado para $file"
        ln -s "$dotfiles_dir/config/$file" "$HOME/$file"
        log_info "Symlink criado para $file"
    done
}

# Verificar symlinks quebrados
check_symlinks() {
    local directories=("$HOME" "$HOME/.dotfiles")
    local logfile=~/broken_symlinks.log

    log_info "Verificando symlinks quebrados..."
    > "$logfile"

    for dir in "${directories[@]}"; do
        find "$dir" -xtype l >> "$logfile"
    done

    if [ -s "$logfile" ]; then
        log_info "Symlinks quebrados encontrados. Veja o log: $logfile"
    else
        log_info "Nenhum symlink quebrado encontrado."
        rm "$logfile"
    fi
}

# Instalar ferramentas
install_tool() {
    local tool="$1"
    local dotfiles_dir="$2"
    local config_file="$3"

    local setup_script="$dotfiles_dir/apps/$tool/setup.sh"

    if [ -f "$setup_script" ]; then
        log_info "Instalando $tool..."
        source "$setup_script"
        return 0
    else
        log_error "Script de setup para $tool não encontrado."
        return 1
    fi
}

# Instalar plugins de terceiros
install_third_party_plugins() {
    local plugin_script="$1"
    log_info "Instalando plugins de terceiros..."

    if [ -f "$plugin_script" ]; then
        bash "$plugin_script"
    else
        log_error "Script de plugins de terceiros não encontrado: $plugin_script"
    fi
}
