{ lib, config, pkgs, ... }:
with lib;                      
let
  cfg = config.home-rofi;
in {
  options.home-rofi = {
    enable = mkEnableOption "Rofi config";
  };
  config = mkIf cfg.enable {
    programs.rofi = {
      enable = true;
      terminal = "${pkgs.foot}/bin/foot";
    };
  };
}

