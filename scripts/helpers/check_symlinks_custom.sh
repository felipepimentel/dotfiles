#!/bin/bash

# Define os diretórios que você quer verificar para symlinks quebrados
DIRECTORIES=(
    "$HOME"
    "$HOME/.dotfiles"
    # Adicione outros diretórios que você deseja verificar
)

# Arquivo de log para salvar os symlinks quebrados
LOGFILE=~/broken_symlinks_custom.log

echo "Verificando links simbólicos quebrados nos diretórios especificados..."

# Limpa o arquivo de log anterior
> "$LOGFILE"

# Busca por links simbólicos quebrados nos diretórios especificados
for DIR in "${DIRECTORIES[@]}"; do
    find "$DIR" -xtype l >> "$LOGFILE"
done

# Verifica se encontrou algum symlink quebrado
if [ -s "$LOGFILE" ]; then
    echo "Links simbólicos quebrados encontrados nos diretórios especificados. Verifique o arquivo de log: $LOGFILE"
else
    echo "Nenhum link simbólico quebrado encontrado nos diretórios especificados."
    # Remove o arquivo de log se estiver vazio
    rm "$LOGFILE"
fi