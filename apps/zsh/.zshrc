# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path configuration
typeset -U path
path+=(
    $HOME/.local/bin
    $HOME/.poetry/bin
    /usr/local/bin
    /usr/local/go/bin
)
export PATH

# PNPM configuration
export PNPM_HOME="$HOME/.local/share/pnpm"
if [[ ":$PATH:" != *":$PNPM_HOME:"* ]]; then
    export PATH="$PNPM_HOME:$PATH"
fi

# Tabtab source for electron-forge package
TABTAB_COMPLETION="$HOME/Workspace/loomia/node_modules/.pnpm/tabtab@2.2.2/node_modules/tabtab/.completions/electron-forge.zsh"
if [[ -f "$TABTAB_COMPLETION" ]]; then
    source "$TABTAB_COMPLETION"
fi

# .NET configuration
export DOTNET_ROOT="$HOME/.dotnet"
if [[ ":$PATH:" != *":$DOTNET_ROOT:"* ]]; then
    export PATH="$PATH:$DOTNET_ROOT"
fi

if [[ ":$PATH:" != *":$DOTNET_ROOT/tools:"* ]]; then
    export PATH="$PATH:$DOTNET_ROOT/tools"
fi

# Oh My Zsh configuration
export ZSH="$HOME/.oh-my-zsh"

# Set Zsh theme (change this to any theme of your choice, such as "agnoster", "robbyrussell", etc.)
ZSH_THEME="powerlevel10k/powerlevel10k"

# Enable plugins (you can add or remove plugins as needed)
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

# Source Oh My Zsh
if [ -f "$ZSH/oh-my-zsh.sh" ]; then
    source $ZSH/oh-my-zsh.sh
fi

# Custom Aliases (add your aliases here)
alias ll='ls -la'
alias gs='git status'

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
