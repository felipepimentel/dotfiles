# ~/.bash_profile: executed by bash(1) for login shells.

# If ~/.bashrc exists, source it
if [ -f ~/.bashrc ]; then
   . ~/.bashrc
fi

# User-specific environment and startup programs

# Set PATH so it includes user's private bin directories
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

# Add any other environment variables or commands below
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
. "$HOME/.cargo/env"
