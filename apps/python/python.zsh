# Adicionar o Poetry ao shell
export POETRY_SHELL=zsh
if command -v poetry >/dev/null 2>&1; then
  export PATH="$HOME/.poetry/bin:$PATH"
fi

# Adicionar o Pyenv ao shell
if command -v pyenv >/dev/null 2>&1; then
  export PATH="$HOME/.pyenv/bin:$PATH"
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
fi
