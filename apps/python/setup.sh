#!/bin/bash

# Caminho para o arquivo de configuração
CONFIG_FILE="config.yml"

# Verifique se o Python já está instalado
check_installed=$(yq eval '.config.check_installed' "$CONFIG_FILE")

if eval "$check_installed"; then
    echo "Python já está instalado. Pulando instalação."
else
    # Instalar o Python
    echo "Instalando Python..."
    package_name=$(yq eval '.config.package_name' "$CONFIG_FILE")
    sudo apt-get install -y $package_name

    echo "Python instalado com sucesso."
fi

# Executar pós-instalação
post_install=$(yq eval '.post_install' "$CONFIG_FILE")
eval "$post_install"
