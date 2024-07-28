# Desktop PC
{ inputs, ... }: {
  imports = [ ../../modules/global.nix ../../modules ./hardware-configuration.nix inputs.jovian-nixos.nixosModules.default ];

  networking.hostName = "steamed-deck";

  # This is a steam deck ok?
  jovian.steam.enable = true;
  jovian.devices.steamdeck.enable = true;
  jovian.steamos.useSteamOSConfig = true;
  jovian.steam.desktopSession = "gnome";

  cfg-desktop.enable = true;
  cfg-gnome.enable = true;
}

