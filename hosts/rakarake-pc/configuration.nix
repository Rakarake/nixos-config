# Desktop PC

{ config, pkgs, ... }@attrs: {
  # Hostname
  networking.hostName = "rakarake-pc";  # Define your hostname.

  # Include the results of the hardware scan.
  imports = [ ./hardware-configuration.nix ];
}

