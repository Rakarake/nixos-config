# Load aliases
source ~/.alias

# Minimal prompt
PROMPT='\[\033[1;32m\]\W $ \[\033[m\]'
NIX_PROMPT='\[\033[1;35m\]\W $ \[\033[m\]'

# Set the prompt "after" initialization
function restore_prompt_after_nix_shell() {
  if [ "$PS1" != "$PROMPT" ]; then
	if [ -n "$IN_NIX_SHELL" ]; then
	  PS1=$NIX_PROMPT
	else
      PS1=$PROMPT
	fi
    PROMPT_COMMAND=""
  fi
}
PROMPT_COMMAND=restore_prompt_after_nix_shell

# vi-mode
set -o vi
set vi-cmd-mode-string "\1\e[2 q\2"
set vi-ins-mode-string "\1\e[6 q\2"

# vi-mode with ctrl-l clearing the screen
bind -x '"\C-l": clear;'
