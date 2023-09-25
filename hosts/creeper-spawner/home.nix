{ lib, config, pkgs, ... }: {
  home.username = "rakarake";
  home.homeDirectory = "/home/rakarake";
  home.stateVersion = "23.05";
  programs.home-manager.enable = true;

  # Generic shell options
  home.file.".alias".source = ../../.alias;
  home.file.".bashrc".source = ./.bashrc;
}
