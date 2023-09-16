# Desktop PC

{ config, pkgs, ... }@attrs: {
  # Hostname
  networking.hostName = "rakarake-pc";  # Define your hostname.

  environment.systemPackages = with pkgs; [
    corectrl
  ];

  # Guest User
  users.users.guest = {
    isNormalUser = true;
    description = "Guest";
    extraGroups = [ "networkmanager" ];
  };

  # Mount music
  fileSystems = {
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

