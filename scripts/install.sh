#!/bin/bash

# Obtenha o diretório do script atual
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Define o diretório base do dotfiles
DOTFILES_DIR="$SCRIPT_DIR/.."

# Caminho para o arquivo de configuração
CONFIG_FILE="$DOTFILES_DIR/dotfiles_config.yml"

# Caminho para o arquivo de log
LOG_FILE="$(yq eval '.paths.log_file' "$CONFIG_FILE")"

# Função de logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Carregar variáveis de ambiente globais
export DOTFILES_EDITOR="$(yq eval '.dotfiles.editor' "$CONFIG_FILE")"
export DOTFILES_THEME="$(yq eval '.dotfiles.theme' "$CONFIG_FILE")"

# Carregar os arquivos centrais
source "$SCRIPT_DIR/core/aliases.sh"
source "$SCRIPT_DIR/core/functions.sh"
source "$SCRIPT_DIR/core/exports.sh"

# Função para carregar paths dinamicamente de cada ferramenta
load_paths() {
    local tool=$1
    local config_file="$DOTFILES_DIR/apps/$tool/config.yml"
    
    if [ -f "$config_file" ]; then
        paths=$(yq eval '.paths[]' "$config_file")

        for path in $paths; do
            export PATH="$path:$PATH"
        done
    fi
}

# Função para executar hooks
run_hook() {
    local tool=$1
    local hook=$2
    local hook_script="$DOTFILES_DIR/apps/$tool/hooks/$hook.sh"
    if [ -f "$hook_script" ]; then
        log "Executando $hook hook para $tool"
        bash "$hook_script"
    fi
}

# Função para criar symlinks
create_symlinks() {
    local module_dir="$1"
    local symlink_dir="$module_dir/linked_files"
    
    if [ -d "$symlink_dir" ]; then
        for file in "$symlink_dir/"*; do
            if [ -f "$file" ]; then
                ln -sf "$file" "$HOME/$(basename "$file")"
                log "Criado symlink para $(basename "$file")"
            fi
        done
    fi
}

# Carregar perfis de instalação do arquivo de configuração
PROFILES=$(yq eval '.profiles' "$CONFIG_FILE")

# Verifica se o perfil foi passado como argumento
if [ -n "$1" ]; then
    profile=$1
    if [[ -z $(yq eval ".profiles.$profile" "$CONFIG_FILE") ]]; then
        echo "Perfil '$profile' não encontrado no dotfiles_config.yml."
        exit 1
    fi
    TOOLS=($(yq eval ".profiles.$profile[]" "$CONFIG_FILE"))
else
    # Se nenhum perfil foi passado, pergunta ao usuário
    echo "Selecione um perfil de instalação:"
    select profile in "${!PROFILES[@]}" "Personalizado" "Sair"; do
        case $profile in
            "Personalizado")
                # Lógica para seleção personalizada de ferramentas
                break
                ;;
            "Sair")
                exit
                ;;
            *)
                if [ -n "$profile" ]; then
                    TOOLS=($(yq eval ".profiles.$profile[]" "$CONFIG_FILE"))
                    break
                fi
                ;;
        esac
    done
fi

# Instalar e configurar cada ferramenta
for tool in "${TOOLS[@]}"; do
    tool_dir="$DOTFILES_DIR/apps/$tool"
    config_file="$tool_dir/config.yml"

    if [ -d "$tool_dir" ]; then
        log "Configurando $tool"
        
        # Carregar paths dinamicamente
        load_paths "$tool"

        # Executar hook pré-instalação
        run_hook "$tool" "pre_install"

        # Criar symlinks para arquivos em linked_files
        create_symlinks "$tool_dir"

        # Executar o setup para injeção de configurações
        if [ -f "$tool_dir/setup.sh" ]; then
            bash "$tool_dir/setup.sh"
        fi

        # Executar hook pós-instalação
        run_hook "$tool" "post_install"

        log "$tool configurado com sucesso"
    else
        log "Configuração para $tool não encontrada."
    fi
done

# Verificar e instalar plugins de terceiros
if [ -f "$SCRIPT_DIR/third_party_plugins.sh" ]; then
    source "$SCRIPT_DIR/third_party_plugins.sh"
fi

log "Instalação concluída com sucesso!"
