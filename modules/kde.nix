{ inputs, ... }: {
  flake.nixosModules.kde = { lib, system, config, pkgs, ... }: {
    services = {
      desktopManager.plasma6.enable = true;
      displayManager.plasma-login-manager.enable = true;
    };   

    environment.systemPackages = with pkgs; [
      kdePackages.oxygen
      tesseract
    ];
  };
}

