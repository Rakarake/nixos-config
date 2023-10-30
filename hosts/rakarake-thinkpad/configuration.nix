# Thinkpad X1 Carbon Gen 4 Specific settings
# I wish the fingerprint reader worked
{ config, pkgs, ... }@attrs: {
  imports = [ ../../modules ./hardware-configuration.nix ];

  # Simple gnome config
  cfg-desktop.enable = true;
  cfg-hyprland.enable = true;

  # Hostname
  networking.hostName = "rakarake-thinkpad";  # Define your hostname.

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

  # Enable SSD trimming
  services.fstrim = {
    enable = true;
    interval = "weekly"; # the default
  };

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  # Enable swap on luks
  boot.initrd.luks.devices."luks-28308eb8-f78c-4235-982e-a0df1555eb1c".device = "/dev/disk/by-uuid/28308eb8-f78c-4235-982e-a0df1555eb1c";
  boot.initrd.luks.devices."luks-28308eb8-f78c-4235-982e-a0df1555eb1c".keyFile = "/crypto_keyfile.bin";
}

