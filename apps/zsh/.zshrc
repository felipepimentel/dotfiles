# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Zsh config
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# VimRuntime config
alias nvim='~/.local/bin/nvim-flatpak'

# Aliases
alias vim='flatpak run io.neovim.nvim'
alias calibre='flatpak run com.calibre_ebook.calibre'

# Add plugins
plugins=(git zsh-syntax-highlighting zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

# Path configs
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

# Adicione isso ao seu .zshrc

docker_clean() {
    echo "🛠️ Removendo todos os contêineres..."
    docker rm -f $(docker ps -a -q)

    echo "🖼️ Removendo todas as imagens..."
    docker rmi -f $(docker images -q)

    echo "🔗 Removendo todas as redes não utilizadas..."
    docker network prune -f

    echo "📦 Removendo todos os volumes não utilizados..."
    docker volume prune -f

    echo "🧹 Docker limpo e espaço liberado!"
}

# Load Powerlevel10k config
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Set the default terminal font to a Nerd Font (if using iTerm2)
if [[ $TERM_PROGRAM == "iTerm.app" ]]; then
  p10k configure
fi
# pnpm
export PNPM_HOME="/home/pimentel/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
