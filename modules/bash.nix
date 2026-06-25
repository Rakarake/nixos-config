{ inputs, ... }: {
  flake.homeModules.bash = { prompt ? ''\[\033[1;32m\]\W\[\033[m\]\[\033[1;32m\] $\[\033[m\] '' }: { config, ... }: {
    programs.direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };
    programs.bash = {
      enable = true;
      bashrcExtra = ''
        # Prompt
        PS1='${prompt}'
        
        # vi-mode
        set -o vi
        bind -x '"\C-l": clear;'  # ctrl-l clearing the screen

        # Colors?
        export COLORTERM='truecolor'
        # Makes history ignore duplicates and ones starting with whitespace
        export HISTCONTROL='ignoreboth'  
      '';
    };
  };
}
