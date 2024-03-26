{ pkgs, nix-vscode-extensions, ... }:
{
  #home.packages = [ vscodePackage ];
  #home.file.".config/Code/User/settings.json".text = ''
  #'';
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium; #// { pname = "vscode"; };
    enableUpdateCheck = false;
    extensions = with nix-vscode-extensions.extensions.${pkgs.system}.vscode-marketplace; [
      # Go
      golang.go

      # Rust
      rust-lang.rust-analyzer
      serayuzgur.crates

      # Nix language server
      jnoortheen.nix-ide

      # Latex
      james-yu.latex-workshop

      # Typst
      nvarner.typst-lsp
      haskell.haskell

      # Haskell
      justusadam.language-haskell
      ndmitchell.haskell-ghcid

      # Spell checking
      streetsidesoftware.code-spell-checker

      # Live Share
      ms-vsliveshare.vsliveshare

      # C++
      ms-vscode.cpptools

      # CMAKE
      twxs.cmake

      # Rust parser generator
      tamasfe.even-better-toml

      # Catppuccin
      catppuccin.catppuccin-vsc

      # C#
      ms-dotnettools.csharp
      ms-dotnettools.vscode-dotnet-runtime
    ];
    userSettings = {
      # Theme
      "workbench.colorTheme" = "Catppuccin Macchiato";
      "workbench.iconTheme" = "catppuccin-macchiato";

      # Caps-Lock is escape fix
      "keyboard.dispatch" = "keyCode";

      # Vim
      "vim.useSystemClipboard" = true;

      # Nix
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "${pkgs.nil}/bin/nil";
      "nix.serverSettings" = {
        "nil" = {
          #"diagnostics" = {
          #  "ignored" = ["unused_binding" "unused_with"];
          #};
          "formatting" = {
            "command" = ["${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt"];
          };
        };
      };
      
      "files.autoSave" = "off";
      "[nix]"."editor.tabSize" = 2;
      "window.zoomLevel" = 1;
      "window.menuBarVisibility" = "toggle";
      "workbench.startupEditor" = "none";
      "zenMode.centerLayout" = false;
    };
  };
}
