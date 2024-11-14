{ pkgs, inputs, ... }:
{
  home.packages = with pkgs; [
    # Needed for vscode-clangd
    clang-tools
  ];
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium; #// { pname = "vscode"; };
    enableUpdateCheck = false;
    extensions = with inputs.nix-vscode-extensions.extensions.${pkgs.system}.vscode-marketplace; [
      # Vim
      vscodevim.vim

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
      myriad-dreamin.tinymist

      haskell.haskell

      # Haskell
      justusadam.language-haskell
      ndmitchell.haskell-ghcid

      # Spell checking
      streetsidesoftware.code-spell-checker

      # Live Share
      ms-vsliveshare.vsliveshare

      # C/C++
      llvm-vs-code-extensions.vscode-clangd

      # CMAKE
      twxs.cmake

      # Rust parser generator
      tamasfe.even-better-toml

      # Catppuccin
      catppuccin.catppuccin-vsc

      # C#
      ms-dotnettools.csharp
      ms-dotnettools.vscode-dotnet-runtime

      # Risc-V
      zhwu95.riscv
    ];
    keybindings = [
      {
        "command" = "workbench.action.terminal.focusNext";
        "key" = "ctrl+shift+a";
        "when" = "terminalFocus";
      }
      {
        "command" = "workbench.action.terminal.focusPrevious";
        "key" = "ctrl+shift+b";
        "when" = "terminalFocus";
      }
      {
        "command" = "workbench.action.togglePanel";
        "key" = "ctrl+p";
      }
      {
        "command" = "workbench.action.terminal.new";
        "key" = "ctrl+shift+n";
        "when" = "terminalFocus";
      }
      {
        "command" = "workbench.action.terminal.kill";
        "key" = "ctrl+shift+w";
        "when" = "terminalFocus";
      }
      # File tree
      # Toggle sidebar
      {
        "command" = "workbench.action.toggleSidebarVisibility";
        "key" = "ctrl+alt+e";
      }
      # Hide activity bar
      {
        "command" = "workbench.action.toggleActivityBarVisibility";
        "key" = "ctrl+alt+s";
      }
      {
        "command" = "workbench.files.action.focusFilesExplorer";
        "key" = "ctrl+shift+e";
        "when" = "editorTextFocus";
      }
      {
        "command" = "explorer.newFile";
        "key" = "n";
        "when" = "filesExplorerFocus && !inputFocus";
      }
      {
        "command" = "renameFile";
        "key" = "r";
        "when" = "filesExplorerFocus && !inputFocus";
      }
      {
        "command" = "explorer.newFolder";
        "key" = "shift+n";
        "when" = "explorerViewletFocus";
      }
      {
        "command" = "workbench.action.newWindow";
        "key" = "shift+n";
        "when" = "!explorerViewletFocus";
      }
      {
        "command" = "deleteFile";
        "key" = "d";
        "when" = "filesExplorerFocus && !inputFocus";
      }
      # Open project
      {
        "command" = "workbench.action.files.openFolder";
        "key" = "ctrl+shift+k";
        "when" = "openFolderWorkspaceSupport";
      }
    ];
    userSettings = {
      # Theme
      #"workbench.colorTheme" = "Catppuccin Macchiato";
      "workbench.iconTheme" = "catppuccin-macchiato";

      # Caps-Lock is escape fix
      "keyboard.dispatch" = "keyCode";

      # Disable X clipboard
      "editor.selectionClipboard" = false;

      # Debloat
      # Side bar on the right to not fuck with the code while searching etc
      "workbench.sideBar.location" = "right";
      "editor.minimap.autohide" = true;
      "editor.scrollbar.vertical" = "hidden";
      "window.menuBarVisibility" = "toggle";
      "workbench.startupEditor" = "none";
      "zenMode.centerLayout" = false;

      # Vim
      "vim.useSystemClipboard" = true;
      "editor.lineNumbers" = "relative";
      "vim.leader" = "<Space>";
      "vim.hlsearch" = true;
      "vim.normalModeKeyBindingsNonRecursive" = [
        # Clear search hilighting
        { "before" = [ "leader" "p" ]; "commands" = [ ":noh" ]; }

        # NAVIGATION
        # switch b/w buffers
        { "before" = [ "<S-h>" ]; "commands" = [ ":bprevious" ]; }
        { "before" = [ "<S-l>" ]; "commands" = [ ":bnext" ]; }

        # splits
        { "before" = [ "leader" "v" ]; "commands" = [ ":vsplit" ]; }
        { "before" = [ "leader" "s" ]; "commands" = [ ":split" ]; }

        # panes
        {
          "before" = [ "leader" "h" ];
          "commands" = [ "workbench.action.focusLeftGroup" ];
        }
        {
          "before" = [ "leader" "j" ];
          "commands" = [ "workbench.action.focusBelowGroup" ];
        }
        {
          "before" = [ "leader" "k" ];
          "commands" = [ "workbench.action.focusAboveGroup" ];
        }
        {
          "before" = [ "leader" "l" ];
          "commands" = [ "workbench.action.focusRightGroup" ];
        }

        # Debug hints etc
        {
          "before" = [ "[" "d" ];
          "commands" = [ "editor.action.marker.prev" ];
        }
        {
          "before" = [ "]" "d" ];
          "commands" = [ "editor.action.marker.next" ];
        }
        {
          "before" = [ "<leader>" "c" "a" ];
          "commands" = [ "editor.action.quickFix" ];
        }
        { "before" = [ "leader" "f" "f" ]; "commands" = [ "workbench.action.quickOpen" ]; }
        { "before" = [ "leader" "d" "f" ]; "commands" = [ "editor.action.formatDocument" ]; }
        {
          "before" = [ "leader" "e" ];
          "commands" = [ "editor.action.showDefinitionPreviewHover" ];
        }
      ];
      "vim.visualModeKeyBindings" = [
        # Stay in visual mode while indenting
        { "before" = [ "<" ]; "commands" = [ "editor.action.outdentLines" ]; }
        { "before" = [ ">" ]; "commands" = [ "editor.action.indentLines" ]; }
        # Move selected lines while staying in visual mode
        { "before" = [ "J" ]; "commands" = [ "editor.action.moveLinesDownAction" ]; }
        { "before" = [ "K" ]; "commands" = [ "editor.action.moveLinesUpAction" ]; }
        # toggle comment selection
        { "before" = [ "leader" "c" ]; "commands" = [ "editor.action.commentLine" ]; }
      ];

      # Nix
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "${pkgs.nil}/bin/nil";
      "nix.serverSettings" = {
        "nil" = {
          #"diagnostics" = {
          #  "ignored" = ["unused_binding" "unused_with"];
          #};
          "formatting" = {
            "command" = [ "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt" ];
          };
        };
      };

      "files.autoSave" = "off";
      "[nix]"."editor.tabSize" = 2;
      #"window.zoomLevel" = 1;
    };
  };
}
