{ inputs, dotfiles, ... }: {
  flake.nixosModules.hyprland = { lib, system, config, pkgs, ... }: {
    hardware.bluetooth.enable = true;
    environment.systemPackages = [
      inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
    programs.hyprland = {
      enable = true;
      withUWSM = true;
    };
  };
  flake.homeModules.hyprland = { config, pkgs, ... }: {
    imports = [
      inputs.noctalia.homeModules.default
    ];

    programs.noctalia = {
      enable = true;

      settings = { # This may also be a string or path to a .toml file.
        #theme = {
        #  mode = "dark";
        #  source = "builtin";
        #  builtin = "Catppuccin";
        #};

        #wallpaper = {
        #  enabled = true;
        #  default.path = ../rakarake/wallpaper.png;
        #};
        bar.order = [ "main" ];
        bar.main = {
          margin_edge        = 0;
          padding = 0;
        };
      };
    };

    home.packages = with pkgs; [
      kitty
      pcmanfm-qt
    ];
    programs.rofi.enable = true;
    xdg.configFile."hypr/extra.lua" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/modules/hyprland/extra.lua";
      force = true;
      recursive = true;
    };
    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = false;
      configType = "lua";
      extraConfig = ''
        -- Load the extra.lua file here
        require("extra")
      '';
    };
  };
}
