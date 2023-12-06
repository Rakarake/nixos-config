# Desktop PC
{ pkgs, ... }: {
  imports = [ ../../modules ./hardware-configuration.nix ];

  # Cool simple gnome config
  cfg-desktop.enable = true;
  cfg-hyprland.enable = true;

  # Hostname
  networking.hostName = "rakarake-pc";  # Define your hostname.

  environment.systemPackages = with pkgs; [
    corectrl  # We like big graphics
  ];

  # Enable hardware acceleration, VA-API
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  
    extraPackages = with pkgs; [
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

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

