{ pkgs, config, ... }: {
  # Styling
  #catppuccin.accent = "pink";
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
  qt = {
    enable = true;
    #platformTheme.name = "kvantum";
    #style = {
    #  name = "kvantum";
    #};
  };
  #catppuccin.kvantum.enable = true;
  stylix.targets.qt.enable = true;

  # Home manager option needed???
  #qt.enable = true;
  #qt.style.name = "kvantum";
  #qt.platformTheme.name = "kvantum";
  #catppuccin.kvantum.enable = true;
  #catppuccin.kvantum.apply = true;

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
  #stylix.targets.hyprland.enable = false;

  # Neovim
  #stylix.targets.neovim.enable = false;
  #catppuccin.nvim.enable = true;

  #stylix.targets.rofi.enable = false;
  #catppuccin.rofi.enable = true;

  # Write a file with the final base16 colors
  home.file.".base16".text = ''base00: ${config.lib.stylix.colors.base00}
base01: ${config.lib.stylix.colors.base01}
base02: ${config.lib.stylix.colors.base02}
base03: ${config.lib.stylix.colors.base03}
base04: ${config.lib.stylix.colors.base04}
base05: ${config.lib.stylix.colors.base05}
base06: ${config.lib.stylix.colors.base06}
base07: ${config.lib.stylix.colors.base07}
base08: ${config.lib.stylix.colors.base08}
base09: ${config.lib.stylix.colors.base09}
base0A: ${config.lib.stylix.colors.base0A}
base0B: ${config.lib.stylix.colors.base0B}
base0C: ${config.lib.stylix.colors.base0C}
base0D: ${config.lib.stylix.colors.base0D}
base0E: ${config.lib.stylix.colors.base0E}
base0F: ${config.lib.stylix.colors.base0F}
'';
}

