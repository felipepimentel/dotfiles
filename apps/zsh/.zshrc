# ===========================
# Dynamic Python Environment
# ===========================
autoload -U add-zsh-hook

# Function to dynamically adjust PYTHONPATH based on the presence of pyproject.toml
function update_pythonpath() {
  if [[ -f pyproject.toml ]]; then
    export PYTHONPATH=$(poetry env info --path 2>/dev/null)/bin/python
  else
    unset PYTHONPATH
  fi
}

# Hook to call the function whenever the directory changes
add-zsh-hook chpwd update_pythonpath

# Execute the function on terminal startup to configure the initial directory
update_pythonpath

# ===========================
# Powerlevel10k Configuration
# ===========================
# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ===========================
# Path Management
# ===========================
# Function to add directories to PATH if not already present
add_to_path() {
  for dir in "$@"; do
    if [[ ":$PATH:" != *":$dir:"* ]]; then
      PATH="$dir:$PATH"
    fi
  done
}

# Configure PATH
add_to_path \
  "$HOME/.local/bin" \
  "$HOME/.poetry/bin" \
  "/usr/local/bin" \
  "/usr/local/go/bin"

# ===========================
# PNPM Configuration
# ===========================
export PNPM_HOME="$HOME/.local/share/pnpm"
add_to_path "$PNPM_HOME"

# ===========================
# Tabtab Configuration
# ===========================
TABTAB_COMPLETION="$HOME/Workspace/loomia/node_modules/.pnpm/tabtab@2.2.2/node_modules/tabtab/.completions/electron-forge.zsh"
if [[ -f "$TABTAB_COMPLETION" ]]; then
  source "$TABTAB_COMPLETION"
fi

# ===========================
# .NET Configuration
# ===========================
export DOTNET_ROOT="$HOME/.dotnet"
add_to_path "$DOTNET_ROOT" "$DOTNET_ROOT/tools"

# ===========================
# Oh My Zsh Configuration
# ===========================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Enable plugins
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  poetry
)

# Source Oh My Zsh
if [[ -f "$ZSH/oh-my-zsh.sh" ]]; then
  source "$ZSH/oh-my-zsh.sh"
fi

# ===========================
# Custom Aliases
# ===========================
alias ll='ls -la'
alias gs='git status'

# ===========================
# Powerlevel10k Prompt Configuration
# ===========================
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ===========================
# PKG_CONFIG_PATH
# ===========================
export PKG_CONFIG_PATH=/usr/lib/x86_64-linux-gnu/pkgconfig:$PKG_CONFIG_PATH

# ===========================
# Bun Configuration
# ===========================
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
export BUN_INSTALL="$HOME/.bun"
add_to_path "$BUN_INSTALL/bin"

# # ===========================
# # Pyenv Configuration
# # ===========================
# if command -v pyenv >/dev/null 2>&1; then
#   export PATH="$HOME/.pyenv/bin:$PATH"
#   eval "$(pyenv init --path)"
#   eval "$(pyenv init -)"
# fi


# ===========================
# Go Configuration
# ===========================
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
add_to_path "$GOROOT/bin" "$GOPATH/bin"

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

[[ "$TERM_PROGRAM" == "vscode" ]] && unset ARGV0