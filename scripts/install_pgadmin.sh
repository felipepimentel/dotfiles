#!/bin/bash -e

# Determine o diretório do script atual
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Inclui o arquivo common.sh
if [ -f "$SCRIPT_DIR/common.sh" ]; then
    source "$SCRIPT_DIR/common.sh"
else
    echo "Error: common.sh not found in $SCRIPT_DIR"
    exit 1
fi

log_message "Setting up the repository for pgAdmin 4..."

# Instalar a chave pública para o repositório
if [ ! -f /usr/share/keyrings/packages-pgadmin-org.gpg ]; then
    curl -fsS https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo gpg --dearmor -o /usr/share/keyrings/packages-pgadmin-org.gpg
    log_message "Public key for pgAdmin repository installed."
else
    log_message "Public key for pgAdmin repository already exists. Skipping."
fi

# Criar o arquivo de configuração do repositório
if [ ! -f /etc/apt/sources.list.d/pgadmin4.list ]; then
    sudo sh -c 'echo "deb [signed-by=/usr/share/keyrings/packages-pgadmin-org.gpg] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list'
    sudo apt update
    log_message "pgAdmin repository configuration file created."
else
    log_message "pgAdmin repository configuration file already exists. Skipping."
fi

# Instalar pgAdmin 4 conforme a escolha do usuário
read -p "Choose installation mode (1 for desktop, 2 for web, 3 for both): " INSTALL_MODE

case $INSTALL_MODE in
    1)
        sudo apt install -y pgadmin4-desktop
        log_message "pgAdmin 4 installed in desktop mode."
        ;;
    2)
        sudo apt install -y pgadmin4-web
        sudo /usr/pgadmin4/bin/setup-web.sh
        log_message "pgAdmin 4 installed in web mode."
        ;;
    3)
        sudo apt install -y pgadmin4
        sudo /usr/pgadmin4/bin/setup-web.sh
        log_message "pgAdmin 4 installed in both desktop and web modes."
        ;;
    *)
        echo "Invalid option. Exiting."
        exit 1
        ;;
esac

log_message "pgAdmin 4 installation completed."
