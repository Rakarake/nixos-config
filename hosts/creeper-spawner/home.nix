{ lib, config, pkgs, ... }: {
  home.username = "rakarake";
  home.homeDirectory = "/home/rakarake";
  home.stateVersion = "23.05";
  programs.home-manager.enable = true;

  # Direnv, used for bash nice
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Comfy shell
  imports = [ ../../home-shell.nix ];
}
