# Desktop PC

{ config, pkgs, ... }@attrs: {
  # Hostname
  networking.hostName = "rakarake-pc";  # Define your hostname.

  # Guest User
  users.users.guest = {
    isNormalUser = true;
    description = "Guest";
    extraGroups = [ "networkmanager" ];
  };

  # Mount music
  fileSystems = {
    "/home/rakarake/MOD" = {
      label = "MOD";
      fsType = "btrfs";
    };
    "/home/rakarake/MORB" = {
      label = "MORB";
      fsType = "btrfs";
    };
    "/home/rakarake/Music" = {
      label = "MORB";
      fsType = "btrfs";
      options = [ "subvol=Music" ];
    };
  };

  # Include the results of the hardware scan.
  imports = [ ./hardware-configuration.nix ];
}
