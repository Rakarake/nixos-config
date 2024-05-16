{ lib, config, ... }:
let
  cfg = config.home-server;
in
{
  options.home-server = {
    enable = lib.mkEnableOption "I don't wanna suffer";
  };

  config = lib.mkIf cfg.enable {
    home-common.enable = true;
  };
}
