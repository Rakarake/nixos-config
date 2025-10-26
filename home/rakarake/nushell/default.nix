{ pkgs, config, ... }:
{
  home.packages = with pkgs; [
    fish  # for autocompletion stuff
  ];
  xdg.configFile."nushell/extra.nu".source = ./extra.nu;
  programs.nushell = {
    enable = true;
    shellAliases = config.home.shellAliases;
    extraConfig = ''
      # Load extra.nu
      source ~/.config/nushell/extra.nu
    '';
  };
}

