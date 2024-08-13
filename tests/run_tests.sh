#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
source "$DOTFILES_DIR/scripts/common.sh"  # Corrigir o caminho do common.sh

log_message "Executando testes..."

# Teste 1: Verifica se o Zsh está instalado e configurado como shell padrão
if [ "$SHELL" = "/bin/zsh" ]; then
  log_message "Teste 1 passou: Zsh está configurado como shell padrão"
else
  log_message "Teste 1 falhou: Zsh não está configurado como shell padrão"
fi

# Teste 2: Verifica se o Neovim está instalado
if command -v nvim &> /dev/null; then
  log_message "Teste 2 passou: Neovim está instalado"
else
  log_message "Teste 2 falhou: Neovim não está instalado"
fi

# Adicione mais testes conforme necessário

log_message "Testes concluídos"