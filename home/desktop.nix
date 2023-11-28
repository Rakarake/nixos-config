# My cozy home UwU
# Some config must be anbled manually, such as the gnome-config.
# This is done so that e.g. gnome and kde settings don't clash.
{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.home-desktop;
in {
  imports = [
    ./bash.nix
    ./xdg.nix
  ];

  options.home-desktop = {
    enable = mkEnableOption "Cozy home desktop (or laptop (or anything else)) config";
  };

  config = mkIf cfg.enable {
    home.username = "rakarake";
    home.homeDirectory = "/home/rakarake";
    home.stateVersion = "23.05";
    programs.home-manager.enable = true;

    # Enable default applications
    home-xdg.enable = true;

    # Direnv
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    # Programming environment
    dev-stuff.enable = true;

    # Generic shell options
    home.file.".alias".source = ./.alias;
    # Bash config
    home-bash.enable = true;
    # ZSH config
    home.file.".zshrc".source = ./.zshrc;

    # Git config
    home.file.".gitconfig".source = ./.gitconfig;
    # Kitty config
    home.file.".config/kitty/kitty.conf".source = ./kitty/kitty.conf;
    home.file.".config/kitty/Catppuccin-Macchiato.conf".source = ./kitty/Catppuccin-Macchiato.conf;
    # Ghci prompt
    home.file.".ghci".source = ./.ghci;

    # Neovim config
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      plugins = with pkgs.vimPlugins; [
        nvim-lspconfig
        nvim-treesitter.withAllGrammars
        plenary-nvim
        telescope-nvim
        catppuccin-nvim  # Theme
        toggleterm-nvim
        vimwiki
        typst-vim
        # LSP
        nvim-lspconfig
        nvim-cmp
        cmp-nvim-lsp
        luasnip
      ];
    };
    # Make sure undodir exists
    home.file.".config/nvim/undodir/gamnangstyle".text = "whop\n";
    # Neovim main configuration file
    home.file.".config/nvim/init.lua".source = ./nvim/init.lua;
    # Neovim filetype specific configs
    home.file.".config/nvim/ftplugin/gdscript.lua".source = ./nvim/ftplugin/gdscript.lua;
    home.file.".config/nvim/ftplugin/html.lua".source = ./nvim/ftplugin/html.lua;

    # Godot single single window
    xdg.desktopEntries.godotOneWindow = {
      name = "Godot 4 Single Window";
      genericName = "Godot 4 Single Window";
      exec = "godot4 --single-window";
    };

    # Logseq Wayland
    xdg.desktopEntries.logseqWayland = {
      name = "Logseq Wayland";
      genericName = "Logseq Wayland";
      exec = "logseq --ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-webrtc-pipewire-capturer";
    };

    # Discord Wayland
    xdg.desktopEntries.discordWayland = {
      name = "Discord Wayland";
      genericName = "Discord Wayland";
      exec = "discord --ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-webrtc-pipewire-capturer";
    };

    # Webcord Wayland
    xdg.desktopEntries.webcordWayland = {
      name = "Webcord Wayland";
      genericName = "Webcord Wayland";
      exec = "webcord --ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-webrtc-pipewire-capturer";
    };
    
    # Steam Gamescope
    xdg.desktopEntries.steamGamescope = {
      name = "Steam Gamescope";
      genericName = "Steam";
      # -e enables steam integration, -f fullscreens the window by default
      exec = "gamescope -W 1920 -H 1080 --adaptive-sync -f -r 600 -e -- steam";
    };
  };
}
