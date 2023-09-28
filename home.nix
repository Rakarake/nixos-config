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

  # Generic shell options
  home.file.".alias".source = ./.alias;
  # Bash config
  home.file.".bashrc".source = ./.bashrc;
  # ZSH config
  home.file.".zshrc".source = ./.zshrc;

  #home.packages = with pkgs; [

  #];

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

  # Logseq Wayland
  xdg.desktopEntries.logseqWayland = {
    name = "Logseq Wayland";
    genericName = "Logseq Wayland";
    exec = "logseq --ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-webrtc-pipewire-capturer";
  };

  # Git config
  home.file.".gitconfig".source = ./.gitconfig;
  # Kitty config
  home.file.".config/kitty/kitty.conf".source = ./kitty/kitty.conf;
  home.file.".config/kitty/Catppuccin-Macchiato.conf".source = ./kitty/Catppuccin-Macchiato.conf;
  # Ghci prompt
  home.file.".ghci".source = ./.ghci;

  # Templates
  home.file."Templates/shell.nix".source = ./Templates/shell.nix;

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
}
