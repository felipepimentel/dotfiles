# apps/zsh/zshrc.sh

# Caminho para o diretório de apps e arquivo de configuração
DOTFILES_APPS="$HOME/.dotfiles/apps"
DOTFILES_CONFIG="$HOME/.dotfiles/config/dotfiles_config.yml"

# Função para carregar extensões
load_zsh_extensions() {
    local app_name=$1
    local app_dir="$DOTFILES_APPS/$app_name"
    
    # Verificar se o diretório da app existe
    if [ -d "$app_dir" ]; then
        # Procurar por todos os arquivos .zsh_extension no diretório da app
        local extension_files=("$app_dir"/*.zsh(N))
        
        # Carregar cada arquivo de extensão encontrado
        if [ ${#extension_files[@]} -gt 0 ]; then
            for extension_file in "${extension_files[@]}"; do
                if [ -f "$extension_file" ]; then
                    source "$extension_file"
                fi
            done
        fi
    else
        echo "App directory not found: $app_dir"
    fi
}

# Função para ler apps do arquivo de configuração
read_apps_from_config() {
    if [ -f "$DOTFILES_CONFIG" ] && command -v yq &> /dev/null; then
        yq e '.apps[]' "$DOTFILES_CONFIG"
    else
        echo "Error: dotfiles_config.yml not found or yq not installed" >&2
        return 1
    fi
}

# Carregar extensões de apps listados no arquivo de configuração
apps=$(read_apps_from_config)

if [ $? -eq 0 ]; then
    while IFS= read -r app; do
        load_zsh_extensions "$app"
    done <<< "$apps"
else
    echo "Failed to read apps from config. Loading default extensions."
    # Lista de apps padrão caso a leitura do arquivo de configuração falhe
    default_apps=(git neovim)
    for app in "${default_apps[@]}"; do
        load_zsh_extensions "$app"
    done
fi
# pnpm
export PNPM_HOME="/home/pimentel/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
