{ pkgs, config, ... }: {
  # Styling
  catppuccin.accent = "pink";
  stylix.enable = true;
  stylix.image = config.home-xdg.wallpaper;
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
  home.packages = with pkgs; [
    adw-gtk3
  ];

  # Qt
  #qt = {
  #  enable = true;
  #  platformTheme.name = "kvantum";
  #  style = {
  #    name = "kvantum";
  #  };
  #};
  #catppuccin.kvantum.enable = true;
  #stylix.targets.qt.enable = true;

  # Home manager option needed???
  qt.enable = true;
  qt.style.name = "kvantum";
  qt.platformTheme.name = "kvantum";
  catppuccin.kvantum.enable = true;
  catppuccin.kvantum.apply = true;

  #catppuccin.kvantum = {
  #  enable = true;
  #  apply = true;
  #  accent = "pink";
  #};

  # Enable for firefox/librewolf
  stylix.targets.librewolf.profileNames = [ "default" ];
  stylix.targets.librewolf.colorTheme.enable = true;
  stylix.targets.firefox.profileNames = [ "default" ];
  stylix.targets.firefox.colorTheme.enable = true;

  # Mangohud
  stylix.targets.mangohud.enable = false;

  # Hyprland
  stylix.targets.hyprland.enable = false;

  # Neovim
  stylix.targets.neovim.enable = false;
  catppuccin.nvim.enable = true;
}

