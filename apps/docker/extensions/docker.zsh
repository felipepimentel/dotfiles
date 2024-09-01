# Docker-specific aliases for Zsh
alias dclean='docker system prune -af'
alias dps='docker ps -a'
alias drm='docker rm $(docker ps -a -q)'

docker_clean() {
    echo "🛠️ Removendo todos os contêineres..."
    docker rm -f $(docker ps -a -q)

    echo "🖼️ Removendo todas as imagens..."
    docker rmi -f $(docker images -q)

    echo "🔗 Removendo todas as redes não utilizadas..."
    docker network prune -f

    echo "📦 Removendo todos os volumes não utilizados..."
    docker volume prune -f

    echo "🧹 Docker limpo e espaço liberado!"
}

# Load Docker completions (if available)
if [ -f /etc/bash_completion.d/docker ]; then
  source /etc/bash_completion.d/docker
fi
