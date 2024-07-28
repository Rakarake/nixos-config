# Desktop PC
{ ... }: {
  imports = [ ../../modules/global.nix ../../modules ./hardware-configuration.nix ];

  cfg-desktop.enable = true;
  cfg-gnome.enable = true;

  networking.hostName = "steamed-deck";
}

