# Desktop PC

{ config, pkgs, ... }@attrs: {
  # Hostname
  networking.hostName = "rakarake-pc";  # Define your hostname.

  # Mount music
  fileSystems = {
    "/home/rakarake/Music" = {
      label = "MORB";
      fsType = "btrfs";
      options = [ "subvol=Music" ];
    };
  };

  # Include the results of the hardware scan.
  imports = [ ./hardware-configuration.nix ];
}

