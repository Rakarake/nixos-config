{ lib, config, ... }:
with lib;                      
let
  cfg = config.cfg-cosmic;
in {
  options.cfg-cosmic = {
    enable = mkEnableOption "Custom cosmic system configuration";
  };
  config = mkIf cfg.enable {
    # Nix caches
    nix.settings = {
      substituters = [ "https://cosmic.cachix.org/" ];
      trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
    };
    #services.desktopManager.cosmic.enable = true;
    #services.displayManager.cosmic-greeter.enable = true;
  };
}
