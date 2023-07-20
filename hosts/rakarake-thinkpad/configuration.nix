# Thinkpad X1 Carbon Gen 4 Specific settings
# I wish the fingerprint reader worked
{ config, pkgs, ... }@attrs:
{
  networking.hostName = "rakarake-thinkpad";  # Define your hostname.
  # Plymouth has problems covering the initial part of the boot, this makes
  # things black.
  boot.kernelParams = ["quiet"];

  # Enable swap on luks
  boot.initrd.luks.devices."luks-28308eb8-f78c-4235-982e-a0df1555eb1c".device = "/dev/disk/by-uuid/28308eb8-f78c-4235-982e-a0df1555eb1c";
  boot.initrd.luks.devices."luks-28308eb8-f78c-4235-982e-a0df1555eb1c".keyFile = "/crypto_keyfile.bin";

  # Enable tlp
  services.power-profiles-daemon.enable = false;
  services.tlp.enable = true;

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];
}
