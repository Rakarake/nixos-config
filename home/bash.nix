# Gnome settings
# Use: `dconf watch /` to find the names of gnome settings
{ lib, config, ... }:
with lib;
let
  cfg = config.home-bash;
in {
  options.home-bash = {
    enable = mkEnableOption "User bash config";
  };
  config = mkIf cfg.enable {
    home.file.".bashrc".text = "
      # Load aliases
      source ~/.alias
      
      # Minimal prompt
      PS1='\\[\\033[1;32m\\]\\W $ \\[\\033[m\\]'
      
      # vi-mode
      set -o vi
      bind -x '\"\\C-l\": clear;'  # ctrl-l clearing the screen
    ";
  };
}
