#!/bin/bash

# Define a variável CODENAME de acordo com sua versão do Ubuntu.
# Para Ubuntu 22.04, use "jammy".
CODENAME="jammy"

echo "Adicionando a chave pública do repositório pgAdmin4..."
curl -fsS https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo gpg --dearmor -o /usr/share/keyrings/packages-pgadmin-org.gpg

echo "Adicionando o repositório pgAdmin4..."
echo "deb [signed-by=/usr/share/keyrings/packages-pgadmin-org.gpg] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$CODENAME pgadmin4 main" | sudo tee /etc/apt/sources.list.d/pgadmin4.list

echo "Atualizando a lista de pacotes..."
sudo apt update

echo "Escolha o modo de instalação do pgAdmin4:"
echo "1 - Modo Desktop"
echo "2 - Modo Web"
echo "3 - Ambos (Desktop e Web)"
read -p "Digite sua escolha [1/2/3]: " choice

case $choice in
  1)
    echo "Instalando pgAdmin4 no modo Desktop..."
    sudo apt install -y pgadmin4-desktop
    ;;
  2)
    echo "Instalando pgAdmin4 no modo Web..."
    sudo apt install -y pgadmin4-web
    echo "Configurando o modo Web do pgAdmin4..."
    sudo /usr/pgadmin4/bin/setup-web.sh
    ;;
  3)
    echo "Instalando pgAdmin4 em ambos os modos..."
    sudo apt install -y pgadmin4
    ;;
  *)
    echo "Escolha inválida. Por favor, execute o script novamente e selecione uma opção válida."
    exit 1
    ;;
esac

echo "Instalação concluída com sucesso!"
