# apps/zsh/zshrc.sh

# Caminho para o diretório de apps e arquivo de configuração
DOTFILES_APPS="$HOME/.dotfiles/apps"
DOTFILES_CONFIG="$HOME/.dotfiles/config/dotfiles_config.yml"

# Configuração do Oh My Zsh (carregado condicionalmente)
# Zsh config
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Load Powerlevel10k config
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

plugins=(git zsh-syntax-highlighting zsh-autosuggestions)

# Path configs
path=(
  $HOME/.local/bin
  $HOME/.poetry/bin
  /usr/local/bin
  /usr/local/go/bin
  $path
)
export PATH


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
# export PNPM_HOME="/home/pimentel/.local/share/pnpm"
# case ":$PATH:" in
#   *":$PNPM_HOME:"*) ;;
#   *) export PATH="$PNPM_HOME:$PATH" ;;
# esac
# pnpm end

# tabtab source for electron-forge package
# uninstall by removing these lines or running `tabtab uninstall electron-forge`
# [[ -f /home/pimentel/Workspace/loomia/node_modules/.pnpm/tabtab@2.2.2/node_modules/tabtab/.completions/electron-forge.zsh ]] && . /home/pimentel/Workspace/loomia/node_modules/.pnpm/tabtab@2.2.2/node_modules/tabtab/.completions/electron-forge.zsh

# if [[ $TERM_PROGRAM = "WarpTerminal" ]]; then
#     if [ -z "$WARP_BOOTSTRAPPED" ]; then
#             export WARP_HONOR_PS1=0
#             setopt hist_ignore_space
#             unsetopt ZLE
#             WARP_IS_SUBSHELL=1
#             WARP_SESSION_ID="$(command -p date +%s)$RANDOM"
#             _hostname=$(command -pv hostname >/dev/null 2>&1 && command -p hostname 2>/dev/null || command -p uname -n)
#             _user=$(command -pv whoami >/dev/null 2>&1 && command -p whoami 2>/dev/null || echo $USER)
#             _msg=$(printf "{\"hook\": \"InitShell\", \"value\": {\"session_id\": \"$WARP_SESSION_ID\", \"shell\": \"zsh\", \"user\": \"$_user\", \"hostname\": \"$_hostname\", \"is_subshell\": true}}" | command -p od -An -v -tx1 | command -p tr -d " \n")
#             printf '\x1b\x50\x24\x64%s\x9c' "$_msg"
#             unset _hostname _user _msg
#     fi
# fi