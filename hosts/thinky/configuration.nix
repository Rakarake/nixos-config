# Thinkpad X1 Carbon Gen 4 Specific settings
# I wish the fingerprint reader worked
{ pkgs, ... }: {
  imports = [ ../../modules/global.nix ../../modules ./hardware-configuration.nix ];

  # Desktop config
  cfg-desktop.enable = true;
  cfg-hyprland.enable = true;
  #services.xserver.displayManager.gdm.enable = true;
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet";
      };
    };
  };

  # Hostname
  networking.hostName = "thinky";  # Define your hostname.

  # Linux kernel package
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Plymouth has problems covering the initial part of the boot, this makes
  # things black. Kinda stupid, but I like it.
  boot.kernelParams = ["quiet"];

  # Enable automatic login for the user.
  #services.xserver.displayManager.autoLogin.enable = true;
  #services.xserver.displayManager.autoLogin.user = "rakarake";
  ## Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  #systemd.services."getty@tty1".enable = false;
  #systemd.services."autovt@tty1".enable = false;

  # Enable tlp
  services.power-profiles-daemon.enable = false;
  services.tlp.enable = true;

  # Enable Plymouth
  boot.plymouth = {
    enable = true;
    logo = ./fraud.png;
  };
  boot.initrd.systemd.enable = true;

  # Fans???
  programs.coolercontrol.enable = true;

  # Enable SSD trimming
  services.fstrim = {
    enable = true;
    interval = "weekly"; # the default
  };

  # Hardware video encoding / decoding
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver intel-ocl intel-vaapi-driver
    ];
  };

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  # Enable swap on luks
  boot.initrd.luks.devices."luks-28308eb8-f78c-4235-982e-a0df1555eb1c".device = "/dev/disk/by-uuid/28308eb8-f78c-4235-982e-a0df1555eb1c";
  boot.initrd.luks.devices."luks-28308eb8-f78c-4235-982e-a0df1555eb1c".keyFile = "/crypto_keyfile.bin";
}

