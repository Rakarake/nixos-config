# Desktop PC
{ pkgs, ... }: {
  imports = [ ../../modules ./hardware-configuration.nix ];
  # Cool simple gnome config
  cfg-desktop.enable = true;
  cfg-gnome.enable = true;

  # Hostname
  networking.hostName = "rakarake-pc";  # Define your hostname.

  environment.systemPackages = with pkgs; [
    corectrl  # We like big graphics
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
}

