#!/bin/bash

# Carregar as configurações do Zsh a partir do config.yml
ZSH_THEME=$(yq eval '.theme' config.yml)
PLUGINS=$(yq eval '.plugins' config.yml)

# Configurar o Zsh
export ZSH="$HOME/.oh-my-zsh"
echo "ZSH_THEME=\"$ZSH_THEME\"" > ~/.zshrc
echo "plugins=(${PLUGINS[@]})" >> ~/.zshrc
source $ZSH/oh-my-zsh.sh

# Aplicar configurações adicionais
for config_file in "$DOTFILES_DIR/apps/zsh/config/*.zsh"; do
  [ -f "$config_file" ] && source "$config_file"
done
