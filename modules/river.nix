{ lib, inputs, outputs, system, config, pkgs, ... }:
with lib;                      
let
  cfg = config.cfg-river;
in {
  options.cfg-river = {
    enable = mkEnableOption "river system config";
  };
  config = mkIf cfg.enable {
    programs.river.enable = true;
    cfg-wlroots.enable = true;
  };
}
