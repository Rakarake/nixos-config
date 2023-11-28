self: {
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dev-stuff;
in
{
  # Option to enable dev-stuff
  options.dev-stuff = {
    # Option to enable Hyprland config
    enable = lib.mkEnableOption "Programming environment";
  };

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [

      # HTML / CSS / JSON / ESLint language server
      vscode-langservers-extracted

      # C / C++
      clang
      #gcc
      pkg-config
      ccls          # A C/C++ language server
      mpi           # C message passing

      # Haskell
      ghc
      haskell-language-server

      # Nix??? 😲
      nil  # Nix language server

      # Godot
      godot_4

      # Rust
      rustc
      cargo
      rustfmt
      rust-analyzer # Rust language server

      # Python
      python3

      # Java
      jdk17

      # Lua
      lua
      lua-language-server

      # Go
      go
      gopls

      # Agda
      (agda.withPackages [ agdaPackages.standard-library ])

      # Vscode
      vscode
    ]);
  };
}
