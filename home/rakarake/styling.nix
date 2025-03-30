{ pkgs, ... }: {
  # Styling
  catppuccin.accent = "pink";
  stylix.enable = true;
  stylix.image = ./wallpaper.png;
  stylix.cursor = {
    package = pkgs.adwaita-icon-theme;
    name = "Adwaita";
    size = 24;
  };
  stylix.fonts = {
    monospace = {
      package = pkgs.fira-code;
      name = "Fira Code";
    };
    sizes = {
      desktop = 11;
      applications = 10;
      terminal = 12;
    };
  };

  # Qt
  #qt = {
  #  enable = true;
  #  platformTheme.name = "kvantum";
  #  style = {
  #    name = "kvantum";
  #  };
  #};
  #catppuccin.kvantum.enable = true;
  catppuccin.kvantum = {
    enable = true;
    apply = true;
    accent = "pink";
  };

  # Mangohud
  stylix.targets.mangohud.enable = false;

  # Hyprland
  stylix.targets.hyprland.enable = false;

  # Neovim
  stylix.targets.neovim.enable = false;
  catppuccin.nvim.enable = true;
}

