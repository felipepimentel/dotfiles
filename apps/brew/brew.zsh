# Homebrew Zsh Extension

# Source Homebrew configurations
[[ -f ~/.brewrc ]] && source ~/.brewrc

# Add Homebrew to PATH and initialize
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Homebrew Aliases
alias brewup='brew update && brew upgrade'
alias brewcl='brew cleanup'
alias brewls='brew list'
alias brewsr='brew search'
alias brewi='brew install'
alias brewun='brew uninstall'

# Homebrew functions
brew_install_or_upgrade() {
    if brew ls --versions "$1" >/dev/null; then
        HOMEBREW_NO_AUTO_UPDATE=1 brew upgrade "$1"
    else
        HOMEBREW_NO_AUTO_UPDATE=1 brew install "$1"
    fi
}

brew_uninstall_if_exists() {
    if brew ls --versions "$1" >/dev/null; then
        HOMEBREW_NO_AUTO_UPDATE=1 brew uninstall "$1"
    fi
}

# Homebrew completion
if type brew &>/dev/null; then
    FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
    autoload -Uz compinit
    compinit
fi

# Print Homebrew configuration
brew_config() {
    echo "Homebrew Configuration:"
    echo "----------------------"
    echo "PATH: $PATH"
    echo "HOMEBREW_PREFIX: $HOMEBREW_PREFIX"
    echo "HOMEBREW_CELLAR: $HOMEBREW_CELLAR"
    echo "HOMEBREW_REPOSITORY: $HOMEBREW_REPOSITORY"
    [[ -n $HOMEBREW_TEMP ]] && echo "HOMEBREW_TEMP: $HOMEBREW_TEMP"
    [[ -n $HOMEBREW_NO_ANALYTICS ]] && echo "HOMEBREW_NO_ANALYTICS: $HOMEBREW_NO_ANALYTICS"
    [[ -n $HOMEBREW_NO_INSTALL_CLEANUP ]] && echo "HOMEBREW_NO_INSTALL_CLEANUP: $HOMEBREW_NO_INSTALL_CLEANUP"
    [[ -n $HOMEBREW_FORCE_BREWED_CURL ]] && echo "HOMEBREW_FORCE_BREWED_CURL: $HOMEBREW_FORCE_BREWED_CURL"
    [[ -n $HOMEBREW_COLOR ]] && echo "HOMEBREW_COLOR: $HOMEBREW_COLOR"
}