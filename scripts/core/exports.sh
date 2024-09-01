#!/bin/bash

# Exportar variáveis globais
export EDITOR="vim"
export PATH="$HOME/bin:$PATH"

# Carregar variáveis específicas de configuração do usuário
if [ -f "$HOME/.user_exports" ]; then
    source "$HOME/.user_exports"
fi
