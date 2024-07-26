{ pkgs, inputs, ... }:
{
  #home.packages = [ vscodePackage ];
  #home.file.".config/Code/User/settings.json".text = ''
  #'';
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
    keybindings = [
      {
        "key" = "ctrl+shift+a";
        "command" = "workbench.action.terminal.focusNext";
        "when" = "terminalFocus";
      }
      {
        "key" = "ctrl+shift+b";
        "command" = "workbench.action.terminal.focusPrevious";
        "when" = "terminalFocus";
      }
      {
        "key" = "ctrl+p";
        "command" = "workbench.action.togglePanel";
      }
      {
        "key" = "ctrl+shift+n";
        "command" = "workbench.action.terminal.new";
        "when" = "terminalFocus";
      }
      {
        "key" = "ctrl+shift+w";
        "command" = "workbench.action.terminal.kill";
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
        "key" = "n";
        "command" = "explorer.newFile";
        "when" = "filesExplorerFocus && !inputFocus";
      }
      {
        "command" = "renameFile";
        "key" = "r";
        "when" = "filesExplorerFocus && !inputFocus";
      }
      {
        "key" = "shift+n";
        "command" = "explorer.newFolder";
        "when" = "explorerViewletFocus";
      }
      {
        "key" = "shift+n";
        "command" = "workbench.action.newWindow";
        "when" = "!explorerViewletFocus";
      }
      {
        "command" = "deleteFile";
        "key" = "d";
        "when" = "filesExplorerFocus && !inputFocus";
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

      # Tmux in terminal
      "terminal.integrated.profiles.linux" = {
        "bash" = null;
        "tmux" = {
          "path" = "bash";
          "args" = ["-c" "tmux new -ADs \${PWD##*/}"];
          "icon" = "terminal-tmux";
        };
      };
      "terminal.integrated.defaultProfile.linux" = "tmux";

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
          "before" = [ "g" "h" ];
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
      "window.menuBarVisibility" = "toggle";
      "workbench.startupEditor" = "none";
      "zenMode.centerLayout" = false;
    };
  };
}
