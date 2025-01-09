# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Enable bash completion
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# Aliases
alias ll='ls -la'
alias l='ls -CF'
alias update='sudo apt update && sudo apt upgrade -y'
alias cls='clear'

# Fancy prompt settings with colors
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi

# If this is an xterm set the title to user@host:dir
case "$TERM" in
    xterm*|rxvt*)
        PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
        ;;
    *)
        ;;
esac

# Add an "alert" alias for long running commands.
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history | tail -n1 | sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Path settings
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

# .NET SDK settings (to use ~/.dotnet as the main .NET directory)
export DOTNET_ROOT="$HOME/.dotnet"
if [[ ":$PATH:" != *":$DOTNET_ROOT:"* ]]; then
    export PATH="$DOTNET_ROOT:$DOTNET_ROOT/tools:$PATH"
fi

# History settings
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s histappend  # Append to the history file, don't overwrite it
PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

# Auto-correct typos in path names when using 'cd'
shopt -s cdspell

# Enable bash completion features (already in /etc/bash.bashrc)
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Cargo environment (Rust)
. "$HOME/.cargo/env"
. "/home/pimentel/.deno/env"

[[ "$TERM_PROGRAM" == "vscode" ]] && unset ARGV0