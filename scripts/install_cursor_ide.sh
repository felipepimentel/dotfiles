#!/bin/bash -e

# Determina o diretório do script atual
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Carrega o common.sh
COMMON_SH="${SCRIPT_DIR}/common.sh"
if [ -f "$COMMON_SH" ]; then
    source "$COMMON_SH"
else
    echo "Erro: common.sh não encontrado em $SCRIPT_DIR"
    exit 1
fi

log_message "Iniciando instalação do Cursor IDE..."

# Determina o diretório home do usuário real
if [ "$(id -u)" -eq 0 ] && [ -n "$SUDO_USER" ]; then
    USER_HOME=$(eval echo "~$SUDO_USER")
    REAL_USER="$SUDO_USER"
else
    USER_HOME="$HOME"
    REAL_USER="$USER"
fi

# Define o diretório de aplicações do usuário
APPLICATIONS_DIR="$USER_HOME/Applications"
mkdir -p "$APPLICATIONS_DIR"

# Define a versão mais recente do Cursor IDE
CURSOR_VERSION="0.2.3"
CURSOR_DEB_URL="https://github.com/getcursor/cursor/releases/download/v${CURSOR_VERSION}/cursor_${CURSOR_VERSION}_amd64.deb"
CURSOR_DEB_PATH="/tmp/cursor_${CURSOR_VERSION}_amd64.deb"

# Função para verificar se o Cursor está instalado
is_cursor_installed() {
    dpkg -l | grep -q "cursor"
}

# Função para baixar e instalar o Cursor
install_cursor() {
    log_message "Baixando Cursor IDE versão ${CURSOR_VERSION}..."
    wget -q --show-progress "$CURSOR_DEB_URL" -O "$CURSOR_DEB_PATH"
    log_message "Instalando Cursor IDE..."
    sudo dpkg -i "$CURSOR_DEB_PATH" || sudo apt-get install -f -y
    rm -f "$CURSOR_DEB_PATH"
}

# Função para configurar o ícone e o arquivo .desktop
configure_desktop_entry() {
    log_message "Configurando entrada de desktop para o Cursor IDE..."

    ICON_DIR="$USER_HOME/.local/share/icons"
    DESKTOP_ENTRY_DIR="$USER_HOME/.local/share/applications"

    mkdir -p "$ICON_DIR" "$DESKTOP_ENTRY_DIR"

    # Baixa o ícone
    ICON_URL="https://raw.githubusercontent.com/getcursor/cursor/main/resources/icon.png"
    ICON_PATH="$ICON_DIR/cursor.png"
    wget -q "$ICON_URL" -O "$ICON_PATH"

    # Cria o arquivo .desktop
    DESKTOP_FILE_PATH="$DESKTOP_ENTRY_DIR/cursor.desktop"
    cat > "$DESKTOP_FILE_PATH" <<EOL
[Desktop Entry]
Name=Cursor IDE
Comment=Cursor é um ambiente de codificação com foco em IA.
Exec=/usr/bin/cursor
Icon=$ICON_PATH
Terminal=false
Type=Application
Categories=Development;IDE;
StartupWMClass=Cursor
EOL

    # Define permissões apropriadas
    chmod +x "$DESKTOP_FILE_PATH"

    log_message "Entrada de desktop configurada em $DESKTOP_FILE_PATH"
}

# Verifica se o Cursor já está instalado
if is_cursor_installed; then
    log_message "Cursor IDE já está instalado. Verificando atualizações..."
    INSTALLED_VERSION=$(dpkg -l | grep cursor | awk '{print $3}')
    if [ "$INSTALLED_VERSION" != "$CURSOR_VERSION" ]; then
        log_message "Atualizando Cursor IDE da versão $INSTALLED_VERSION para $CURSOR_VERSION..."
        install_cursor
        configure_desktop_entry
        log_message "Cursor IDE atualizado com sucesso."
    else
        log_message "Cursor IDE já está na versão mais recente."
    fi
else
    log_message "Cursor IDE não está instalado. Iniciando instalação..."
    install_cursor
    configure_desktop_entry
    log_message "Cursor IDE instalado com sucesso."
fi
