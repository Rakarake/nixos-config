# Gnome settings
# Use: `dconf watch /` to find the names of gnome settings
{ lib, config, ... }:
with lib;
let
  cfg = config.home-bash;
in {
  options.home-bash = {
    enable = mkEnableOption "User bash config";
    historyFileSize = 100000;
    prompt = mkOption {
      type = types.str;
      # Minimal prompt without hostname
      default = ''\[\033[1;32m\]\W $ \[\033[m\]'';
    };
  };
  config = mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };
    programs.bash = {
      enable = true;
      bashrcExtra = ''
        # Prompt
        PS1='${cfg.prompt}'
        
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
