# Shared Home Manager config for rakarake
{ config, pkgs, ... }: {
  home.username = "rakarake";
  home.homeDirectory = "/home/rakarake";
  home.stateVersion = "23.05";
  programs.home-manager.enable = true;
  home.packages = with pkgs; [
    firefox
    thunderbird
    mullvad-vpn
  ];
}
