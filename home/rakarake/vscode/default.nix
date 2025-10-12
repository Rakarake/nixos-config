{ pkgs, inputs, outputs, self, user, ... }:
let
  # Using mutable dotfiles.
  dotfiles = outputs.extra.mutableDotfiles {
    inherit pkgs user;
    location = "vscode";
  };
  pkgs-ext = import inputs.nixpkgs {
    inherit (pkgs) system;
    config.allowUnfree = true;
    overlays = [ inputs.nix-vscode-extensions.overlays.default ];
  };
  logoPath = "${self}/logo.svg";
  code-pkg = (pkgs.vscode-with-extensions.override {
    vscode = pkgs.vscodium.overrideAttrs (old: {
      installPhase = old.installPhase + ''
        # yo
        mkdir -p "$out/lib/vscode/resources/app/out/vs/workbench/"
        mkdir -p "$out/lib/vscode/resources/app/out/media/"
        cat "${
          ./custom.css
        }" >> $out/lib/vscode/resources/app/out/vs/workbench/workbench.desktop.main.css
        cat "${
          logoPath
        }"    > $out/lib/vscode/resources/app/out/media/letterpress-dark.svg
        cat "${
          logoPath
        }"    > $out/lib/vscode/resources/app/out/media/letterpress-hcDark.svg
        cat "${
          logoPath
        }"    > $out/lib/vscode/resources/app/out/media/letterpress-hcLark.svg
        cat "${
          logoPath
        }"    > $out/lib/vscode/resources/app/out/media/letterpress-light.svg
      '';
    });
    vscodeExtensions = with pkgs-ext.vscode-marketplace; [
      vscodevim.vim
      editorconfig.editorconfig
      geequlim.godot-tools
      golang.go
      rust-lang.rust-analyzer
      serayuzgur.crates
      jnoortheen.nix-ide
      james-yu.latex-workshop
      myriad-dreamin.tinymist
      haskell.haskell
      justusadam.language-haskell
      ndmitchell.haskell-ghcid
      banacorn.agda-mode
      streetsidesoftware.code-spell-checker
      ms-vsliveshare.vsliveshare
      llvm-vs-code-extensions.vscode-clangd
      twxs.cmake
      tamasfe.even-better-toml
      zhwu95.riscv

      # Themes
      catppuccin.catppuccin-vsc
      jdinhlife.gruvbox
      golf1052.base16-generator
    ];
  });

in
{
  xdg.configFile."Code/User/settings.json".source = "${dotfiles}/settings.json";
  xdg.configFile."Code/User/keybindings.json".source =
    "${dotfiles}/keybindings.json";
  xdg.configFile."VSCodium/User/settings.json".source =
    "${dotfiles}/settings.json";
  xdg.configFile."VSCodium/User/keybindings.json".source =
    "${dotfiles}/keybindings.json";

  home.packages = [
    pkgs.clang-tools
    (pkgs.writeShellScriptBin "code" "exec -a $0 ${code-pkg}/bin/codium $@")
    code-pkg
    pkgs.harper
  ];
}

