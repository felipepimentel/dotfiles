# apps/zsh/zshrc.sh

# Path for apps and configuration files
DOTFILES_APPS="$HOME/.dotfiles/apps"
DOTFILES_CONFIG="$HOME/.dotfiles/config/dotfiles_config.yml"

# Oh My Zsh configuration
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Load Oh My Zsh
if [[ -d "$ZSH" ]]; then
    source "$ZSH/oh-my-zsh.sh"
fi

# Load Powerlevel10k configuration
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# Plugins
plugins=(git zsh-syntax-highlighting zsh-autosuggestions)

# Path configuration
typeset -U path
path+=(
    $HOME/.local/bin
    $HOME/.poetry/bin
    /usr/local/bin
    /usr/local/go/bin
)
export PATH

# Function to load Zsh extensions
load_zsh_extensions() {
    local app_name=$1
    local app_dir="$DOTFILES_APPS/$app_name"
    
    if [[ -d "$app_dir" ]]; then
        for extension_file in "$app_dir"/*.zsh(N); do
            [[ -f "$extension_file" ]] && source "$extension_file"
        done
    fi
}

# Function to read apps from the configuration file
read_apps_from_config() {
    if [[ -f "$DOTFILES_CONFIG" ]] && command -v yq &> /dev/null; then
        yq e '.apps[]' "$DOTFILES_CONFIG"
    else
        return 1
    fi
}

# Load extensions from apps listed in the configuration file
apps=$(read_apps_from_config)

if [[ $? -eq 0 ]]; then
    while IFS= read -r app; do
        load_zsh_extensions "$app"
    done <<< "$apps"
else
    default_apps=(git neovim)
    for app in "${default_apps[@]}"; do
        load_zsh_extensions "$app"
    done
fi

# PNPM configuration
export PNPM_HOME="$HOME/.local/share/pnpm"
if [[ ":$PATH:" != *":$PNPM_HOME:"* ]]; then
    export PATH="$PNPM_HOME:$PATH"
fi

# Tabtab source for electron-forge package
if [[ -f "$HOME/Workspace/loomia/node_modules/.pnpm/tabtab@2.2.2/node_modules/tabtab/.completions/electron-forge.zsh" ]]; then
    source "$HOME/Workspace/loomia/node_modules/.pnpm/tabtab@2.2.2/node_modules/tabtab/.completions/electron-forge.zsh"
fi

export PATH=$PATH:$HOME/dotnet
export DOTNET_ROOT=$HOME/dotnet