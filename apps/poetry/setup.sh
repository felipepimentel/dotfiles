#!/bin/bash

# Carregar as configurações do Poetry a partir do config.yml
paths=$(yq eval '.paths[]' config.yml)

# Aplicar os caminhos ao PATH
for path in $paths; do
  export PATH="$path:$PATH"
done

# Outras configurações, se necessário
version=$(yq eval '.version' config.yml)
echo "Poetry version configurada: $version"
