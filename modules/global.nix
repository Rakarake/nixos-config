{ pkgs, config, lib, inputs, system, ... }:
with lib;                      
let
  cfg = config.cfg-global;
in {
  options.cfg-global = {
    enable = mkEnableOption "A module which should be enabled everywhare";
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      # Make the home manager command available
      pkgs.home-manager
      inputs.agenix.packages."${system}".default
    ];
    nixpkgs.overlays = [
      # Replace openssl with libressl
      (final: super: { 
        nginxStable = super.nginxStable.override { openssl = super.pkgs.libressl; }; 
      })
    ];
    # Enable Flakes
    nix.settings.experimental-features = [ "flakes" "nix-command" ];
    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;
  };
}

