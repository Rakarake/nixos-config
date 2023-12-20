# Desktop PC
{ pkgs, ... }: {
  imports = [ ../../modules ./hardware-configuration.nix ];

  # Cool simple Hyprland config
  cfg-desktop.enable = true;
  cfg-hyprland.enable = true;

  # Hostname
  networking.hostName = "rakarake-pc";  # Define your hostname.

  # Desktop specific packages
  environment.systemPackages = with pkgs; [
    corectrl  # We like big graphics
  ];

  # Enable Plymouth
  boot.plymouth.enable = true;
  boot.initrd.systemd.enable = true;

  # Enable hardware acceleration, VA-API
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  
    extraPackages = with pkgs; [
      libva  # Main package for VA-API
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
  };
}

