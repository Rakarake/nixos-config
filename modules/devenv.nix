# Development environment.
{ inputs, self, ... }: {
  flake.homeModules.devenv = { pkgs, lib, ... }: let
    pkgs-unstable = import inputs.nixpkgs-unstable { system = pkgs.stdenv.hostPlatform.system; config.allowUnfree = true; };
  in {
    imports = [
      self.homeModules.neovim
      self.homeModules.emacs
    ];
    home.packages = with pkgs; [
      vscode-langservers-extracted
      nil
      lua-language-server
      tinymist
      pyright
      glsl_analyzer
      cargo-mommy
      gdb
      okteta
      (pkgs.rustPlatform.buildRustPackage {
        name = "gdshader-lsp";
        version = "git";
        src = pkgs.fetchFromGitHub {
          owner = "GodOfAvacyn";
          repo = "gdshader-lsp";
          rev = "f3847df8a17cd66674b2ec058c020d80ff7d4f8f";
          hash = "sha256-kzZhHIRXW3m3n5TlNRDQO9XsDoSi59N7+4NeFKtauEM=";
        };
        cargoHash = "sha256-FP3SMcafLbz3jqKTunCi4Z1CeZADLmmsIyWHQICmi8o=";
        nativeBuildInputs = [
        ];
        buildInputs = [
        ];
      })
    ];
  };
}
