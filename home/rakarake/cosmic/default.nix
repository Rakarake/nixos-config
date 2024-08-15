{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.home-cosmic;
in {
  options.home-cosmic = {
    enable = mkEnableOption "Custom cosmic user configuration";
  };
  config = mkIf cfg.enable {
    home.file.".config/cosmic/com.system76.CosmicComp/v1/xkb_config".source = ./xkb_config;
  };
}
