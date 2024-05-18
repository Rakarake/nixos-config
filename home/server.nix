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
    home-bash = {
      enable = true;
      prompt = ''\[\033[1;92m\]\u@\h: \W $ \[\033[m\]'';
    };
  };
}
