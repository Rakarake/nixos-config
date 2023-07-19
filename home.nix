# Shared Home Manager config for rakarake
{ lib, config, pkgs, ... }: 
let
  mkTuple = lib.hm.gvariant.mkTuple;
in
{
  home.username = "rakarake";
  home.homeDirectory = "/home/rakarake";
  home.stateVersion = "23.05";
  programs.home-manager.enable = true;
  home.packages = with pkgs; [
    # HTML / CSS / JSON / ESLint language server
    vscode-langservers-extracted
    # Rust
    rustc
    cargo
    rust-analyzer # Rust language server
    # C
    clang
    pkgconfig
    ccls          # A C/C++ language server
    # Haskell
    ghc
    haskell-language-server
    # Nix??? 😲
    nil  # Nix language server
    # Godot
    godot_4
  ];

  # Direnv
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Godot single single window
  xdg.desktopEntries.godotOneWindow = {
    name = "Godot 4 Single Window";
    genericName = "Godot 4 Single Window";
    exec = "godot4 --single-window";
  };

  # Git config
  home.file.".gitconfig".source = ./.gitconfig;
  # Generic shell options
  home.file.".alias".source = ./.alias;
  # Bash config
  home.file.".bashrc".source = ./.bashrc;
  # ZSH config
  home.file.".zshrc".source = ./.zshrc;
  # Kitty config
  home.file.".config/kitty/kitty.conf".source = ./kitty.conf;
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
      catppuccin-nvim
      toggleterm-nvim
      vimwiki
      # LSP
      nvim-lspconfig
      nvim-cmp
      luasnip
    ];
  };
  # Make sure undodir exists
  home.file.".config/nvim/undodir/gamnangstyle".text = "whop\n";
  # Neovim main configuration file
  home.file.".config/nvim/init.lua".source = ./init.lua;

  # Gnome settings
  # Use: `dconf watch /` to find the names of gnome settings
  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3";
      package = pkgs.adw-gtk3;
    };
  };
  dconf.settings = {
    # Locale
    "system/locale" = {
      region = "sv_SE.UTF-8";
    };
    # Wallpaper
    "org/gnome/desktop/background" = {
      picture-uri      = "/run/current-system/sw/share/backgrounds/gnome/design-is-rounded-rectangles-l.webp";
      picture-uri-dark = "/run/current-system/sw/share/backgrounds/gnome/design-is-rounded-rectangles-d.webp";
    };
    # Custom Shortcuts
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = ["/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"];
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Super>Return";
      command = "kgx";
      name = "Terminal";
    };
    # Keybinds
    "org/gnome/desktop/wm/keybindings" = {
      switch-to-workspace-left  = ["<Control><Super>h"];
      switch-to-workspace-right = ["<Control><Super>l"];
      close =                     ["<Super>q"];
      move-to-workspace-left =    ["<Shift><Control><Super>h"];
      move-to-workspace-right =   ["<Shift><Control><Super>l"];
      toggle-maximized =          ["<Super>m"];
    };
    # Number of workspaces
    "org/gnome/desktop/wm/preferences" = {
      num-workspaces = 6;
    };
    # Only workspaces on primary monitor
    "org/gnome/mutter" = {
      workspaces-only-on-primary = true;
    };
    # Caps-Lock as Escape
    "org/gnome/desktop/input-sources" = {
      xkb-options = ["terminate:ctrl_alt_bksp" "caps:escape"];
    };
    # Touchpad Tap-to-Click
    "org/gnome/desktop/peripherals/touchpad" = {
      tap-to-click = true;
    };
    # Don't suspend when plugged in
    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-type = "nothing";
    };
    # Extentions
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = ["appindicatorsupport@rgcjonas.gmail.com"];
    };
  };
}
