# Configuração do Oh My Zsh (carregado condicionalmente)
if [[ -d "$HOME/.oh-my-zsh" ]]; then
  export ZSH="$HOME/.oh-my-zsh"
  ZSH_THEME="robbyrussell"
  plugins=(git)
  source $ZSH/oh-my-zsh.sh
fi