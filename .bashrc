# Nix direnv
eval "$(direnv hook bash)"

# Load aliases
source ~/.alias

# Minimal prompt
PS1='\[\033[1;32m\]\W $ \[\033[m\]'

# vi-mode
set -o vi
bind -x '"\C-l": clear;'  # ctrl-l clearing the screen
