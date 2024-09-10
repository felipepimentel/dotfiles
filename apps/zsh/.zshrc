# apps/zsh/zshrc.sh

# Caminho para o diretório de apps
DOTFILES_APPS="$HOME/.dotfiles/apps"

# Função para carregar extensões
load_zsh_extension() {
    local app_name=$1
    local extension_file="$DOTFILES_APPS/$app_name/zsh_extension.sh"
    
    # Verificar se o arquivo de extensão existe
    if [ -f "$extension_file" ]; then
        source "$extension_file"
        echo "Zsh extension loaded for $app_name"
    fi
}

# Lista de apps que podem ter extensões para o Zsh
apps=(poetry git neovim)

# Carregar extensões de apps instalados
for app in "${apps[@]}"; do
    load_zsh_extension "$app"
done
