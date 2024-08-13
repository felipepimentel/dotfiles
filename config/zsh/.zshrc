# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Zsh configuration
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# VimRuntime configuration
alias nvim='~/.local/bin/nvim-flatpak'

# Aliases
alias vim='flatpak run io.neovim.nvim'
alias calibre='flatpak run com.calibre_ebook.calibre'

# Add plugins
plugins=(git zsh-syntax-highlighting zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

# Path configurations
path=(
  $HOME/.local/bin
  $HOME/.poetry/bin
  $HOME/.pyenv/bin
  /usr/local/bin
  /usr/local/go/bin
  $path
)
export PATH

# Pyenv initialization
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# Load Powerlevel10k configuration
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Set the default terminal font to a Nerd Font (if using iTerm2)
if [[ $TERM_PROGRAM == "iTerm.app" ]]; then
  p10k configure
fi