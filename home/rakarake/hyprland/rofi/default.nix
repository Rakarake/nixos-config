{ lib, config, pkgs, ... }:
with lib;                      
let
  cfg = config.home-rofi;
in {
  options.home-rofi = {
    enable = mkEnableOption "Custom gnome system configuration";
  };
  config = mkIf cfg.enable {
    programs.rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
      terminal = "${pkgs.kitty}/bin/kitty";
    };
  };
}

