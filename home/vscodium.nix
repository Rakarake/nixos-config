{ pkgs ,... }: {
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    enableUpdateCheck = false;
    extensions = with pkgs.vscode-extensions; [
      catppuccin.catppuccin-vsc
      vadimcn.vscode-lldb
      vscodevim.vim
      jnoortheen.nix-ide
      rust-lang.rust-analyzer
      haskell.haskell
      tamasfe.even-better-toml
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
