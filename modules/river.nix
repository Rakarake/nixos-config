{ lib, inputs, outputs, system, config, pkgs, ... }:
with lib;                      
let
  cfg = config.cfg-river;
in {
  options.cfg-river = {
    enable = mkEnableOption "river system config";
    useLoginManager = mkEnableOption "Stupidly simple login manager";
  };
  config = mkIf cfg.enable {
    programs.river.enable = true;
    cfg-wlroots.enable = true;

    services.greetd = {
      enable = cfg.useLoginManager;
      settings = {
        default_session.command = ''${pkgs.dbus}/bin/dbus-run-session ${pkgs.river}/bin/river \
          -c "${pkgs.greetd.wlgreet}/bin/wlgreet --command river; riverctl exit"
        '';
      };
    };
  };
}
