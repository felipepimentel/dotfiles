#!/bin/bash -e

# Determine the directory of the current script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Include the common.sh file
if [ -f "$SCRIPT_DIR/common.sh" ]; then
    source "$SCRIPT_DIR/common.sh"
else
    echo "Error: common.sh not found in $SCRIPT_DIR"
    exit 1
fi

log_message "Configuring Git..."

# Obtenha os valores das configurações
git_name=$(get_config_value '.git.user_name')
git_email=$(get_config_value '.git.user_email')
git_editor=$(get_config_value '.git.editor')

# Caminho para o template e o destino do .gitconfig
TEMPLATE_FILE="$DOTFILES_DIR/config/git/.gitconfig.template"
DEST_FILE="$DOTFILES_DIR/config/git/.gitconfig"  # Salva o arquivo no mesmo diretório do template

# Substitua as variáveis no template e crie o .gitconfig
export GIT_USER_NAME="$git_name"
export GIT_USER_EMAIL="$git_email"
export GIT_EDITOR="$git_editor"

# Substitui as variáveis no template e salva o resultado no arquivo de destino
envsubst < "$TEMPLATE_FILE" > "$DEST_FILE"

# Crie o link simbólico no diretório home do usuário
ln -s $DEST_FILE $USER_HOME/.gitconfig

log_message "Git configuration applied successfully and symbolic link created."
