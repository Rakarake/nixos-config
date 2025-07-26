# Desktop PC
{ inputs, ... }: {
  imports = [
    ./hardware-configuration.nix
    inputs.jovian-nixos.nixosModules.default
  ];

  cfg-desktop.enable = true;
  cfg-river.enable = true;
  services.xserver.displayManager.gdm.enable = true;

  networking.hostName = "steamed-deck";

  # This is a steam deck ok?
  jovian.steam.enable = true;
  jovian.devices.steamdeck.enable = true;
  jovian.steamos.useSteamOSConfig = true;
  jovian.steam.desktopSession = "river";
}

