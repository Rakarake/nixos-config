{ pkgs, inputs, self, ... }:
let
  path = pkgs.lib.escapeShellArg "/home/rakarake/Projects/nixos-config/home/rakarake/vscode";
  dotfiles =
    pkgs.runCommandLocal "nixos-mutable-file-${builtins.baseNameOf path}" { }
    "ln -s ${path} $out";

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
      #golang.go
      #rust-lang.rust-analyzer
      #teabyii.ayu
      ## barboss-hack.crates-io
      ## icrawl.discord-vscode
      #pkief.material-icon-theme
      #jnoortheen.nix-ide
      #thenuprojectcontributors.vscode-nushell-lang
      #james-yu.latex-workshop
      #myriad-dreamin.tinymist
      #haskell.haskell
      #justusadam.language-haskell
      #streetsidesoftware.code-spell-checker
      #ms-vsliveshare.vsliveshare
      #eww-yuck.yuck
      #kaysonwu.cpptask
      #qwtel.sqlite-viewer
      ## asvetliakov.vscode-neovim
      ## ms-vscode.cmake-tools
      #twxs.cmake
      #wakatime.vscode-wakatime
      #ndmitchell.haskell-ghcid
      ## kevin-kwong.vscode-autohide-keyboard
      #kvoon.command-task
      ## guidotapia2.unicode-math-vscode
      #marp-team.marp-vscode
      #ms-vscode.hexeditor
      #ms-azuretools.vscode-docker
      #rreverser.llvm
      ## diku.futhark-vscode
      #pgourlain.erlang
      #ms-vscode-remote.remote-ssh
      #mkhl.direnv
      #streetsidesoftware.code-spell-checker-swedish
      #dart-code.flutter
      #dart-code.dart-code
      #svelte.svelte-vscode

      #banacorn.agda-mode
      #llvm-vs-code-extensions.vscode-clangd
      #ms-python.python
      #benjaminjurk.gas-highlight
      #llvm-vs-code-extensions.lldb-dap
      #swiftlang.swift-vscode

      #ms-dotnettools.csharp
      #geequlim.godot-tools
      #ms-dotnettools.vscode-dotnet-runtime

      #ms-vscode-remote.remote-containers
      #elijah-potter.harper
      #editorconfig.editorconfig
      #tamasfe.even-better-toml

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

        # Agda
        banacorn.agda-mode

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
        #ms-dotnettools.csharp
        #ms-dotnettools.vscode-dotnet-runtime

        # Risc-V
        zhwu95.riscv
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

  #programs.vscode = {
  #  enable = true;
  #  package = pkgs.vscodium; #// { pname = "vscode"; };
  #  profiles.default = {
  #    enableUpdateCheck = false;
  #    extensions = with inputs.nix-vscode-extensions.extensions.${pkgs.system}.vscode-marketplace; [
  #      # Vim
  #      vscodevim.vim

  #      # Go
  #      golang.go

  #      # Rust
  #      rust-lang.rust-analyzer
  #      serayuzgur.crates

  #      # Nix language server
  #      jnoortheen.nix-ide

  #      # Latex
  #      james-yu.latex-workshop

  #      # Typst
  #      myriad-dreamin.tinymist

  #      haskell.haskell

  #      # Haskell
  #      justusadam.language-haskell
  #      ndmitchell.haskell-ghcid

  #      # Agda
  #      banacorn.agda-mode

  #      # Spell checking
  #      streetsidesoftware.code-spell-checker

  #      # Live Share
  #      ms-vsliveshare.vsliveshare

  #      # C/C++
  #      llvm-vs-code-extensions.vscode-clangd

  #      # CMAKE
  #      twxs.cmake

  #      # Rust parser generator
  #      tamasfe.even-better-toml

  #      # Catppuccin
  #      catppuccin.catppuccin-vsc

  #      # C#
  #      #ms-dotnettools.csharp
  #      #ms-dotnettools.vscode-dotnet-runtime

  #      # Risc-V
  #      zhwu95.riscv
  #    ];
  #    #keybindings = [
  #    #  {
  #    #    "command" = "workbench.action.terminal.focusNext";
  #    #    "key" = "ctrl+shift+a";
  #    #    "when" = "terminalFocus";
  #    #  }
  #    #  {
  #    #    "command" = "workbench.action.terminal.focusPrevious";
  #    #    "key" = "ctrl+shift+b";
  #    #    "when" = "terminalFocus";
  #    #  }
  #    #  {
  #    #    "command" = "workbench.action.togglePanel";
  #    #    "key" = "ctrl+p";
  #    #  }
  #    #  {
  #    #    "command" = "workbench.action.terminal.new";
  #    #    "key" = "ctrl+shift+n";
  #    #    "when" = "terminalFocus";
  #    #  }
  #    #  {
  #    #    "command" = "workbench.action.terminal.kill";
  #    #    "key" = "ctrl+shift+w";
  #    #    "when" = "terminalFocus";
  #    #  }
  #    #  # File tree
  #    #  # Toggle sidebar
  #    #  {
  #    #    "command" = "workbench.action.toggleSidebarVisibility";
  #    #    "key" = "ctrl+alt+e";
  #    #  }
  #    #  # Hide activity bar
  #    #  {
  #    #    "command" = "workbench.action.toggleActivityBarVisibility";
  #    #    "key" = "ctrl+alt+s";
  #    #  }
  #    #  {
  #    #    "command" = "workbench.files.action.focusFilesExplorer";
  #    #    "key" = "ctrl+shift+e";
  #    #    "when" = "editorTextFocus";
  #    #  }
  #    #  {
  #    #    "command" = "explorer.newFile";
  #    #    "key" = "n";
  #    #    "when" = "filesExplorerFocus && !inputFocus";
  #    #  }
  #    #  {
  #    #    "command" = "renameFile";
  #    #    "key" = "r";
  #    #    "when" = "filesExplorerFocus && !inputFocus";
  #    #  }
  #    #  {
  #    #    "command" = "explorer.newFolder";
  #    #    "key" = "shift+n";
  #    #    "when" = "explorerViewletFocus";
  #    #  }
  #    #  {
  #    #    "command" = "workbench.action.newWindow";
  #    #    "key" = "shift+n";
  #    #    "when" = "!explorerViewletFocus";
  #    #  }
  #    #  {
  #    #    "command" = "deleteFile";
  #    #    "key" = "d";
  #    #    "when" = "filesExplorerFocus && !inputFocus";
  #    #  }
  #    #  # Open project
  #    #  {
  #    #    "command" = "workbench.action.files.openFolder";
  #    #    "key" = "ctrl+shift+k";
  #    #    "when" = "openFolderWorkspaceSupport";
  #    #  }
  #    #];
  #    #userSettings = {
  #    #  # Theme
  #    #  #"workbench.colorTheme" = "Catppuccin Macchiato";
  #    #  "workbench.iconTheme" = "catppuccin-macchiato";

  #    #  # Caps-Lock is escape fix
  #    #  "keyboard.dispatch" = "keyCode";

  #    #  # Disable X clipboard
  #    #  "editor.selectionClipboard" = false;

  #    #  # Debloat
  #    #  # Side bar on the right to not fuck with the code while searching etc
  #    #  "workbench.sideBar.location" = "right";
  #    #  "editor.minimap.autohide" = true;
  #    #  "editor.scrollbar.vertical" = "hidden";
  #    #  "window.menuBarVisibility" = "toggle";
  #    #  "workbench.startupEditor" = "none";
  #    #  "zenMode.centerLayout" = false;

  #    #  # Vim
  #    #  "vim.useSystemClipboard" = true;
  #    #  "editor.lineNumbers" = "relative";
  #    #  "vim.leader" = "<Space>";
  #    #  "vim.hlsearch" = true;
  #    #  "vim.normalModeKeyBindingsNonRecursive" = [
  #    #    # Clear search hilighting
  #    #    { "before" = [ "leader" "p" ]; "commands" = [ ":noh" ]; }

  #    #    # NAVIGATION
  #    #    # switch b/w buffers
  #    #    { "before" = [ "<S-h>" ]; "commands" = [ ":bprevious" ]; }
  #    #    { "before" = [ "<S-l>" ]; "commands" = [ ":bnext" ]; }

  #    #    # splits
  #    #    { "before" = [ "leader" "v" ]; "commands" = [ ":vsplit" ]; }
  #    #    { "before" = [ "leader" "s" ]; "commands" = [ ":split" ]; }

  #    #    # panes
  #    #    {
  #    #      "before" = [ "leader" "h" ];
  #    #      "commands" = [ "workbench.action.focusLeftGroup" ];
  #    #    }
  #    #    {
  #    #      "before" = [ "leader" "j" ];
  #    #      "commands" = [ "workbench.action.focusBelowGroup" ];
  #    #    }
  #    #    {
  #    #      "before" = [ "leader" "k" ];
  #    #      "commands" = [ "workbench.action.focusAboveGroup" ];
  #    #    }
  #    #    {
  #    #      "before" = [ "leader" "l" ];
  #    #      "commands" = [ "workbench.action.focusRightGroup" ];
  #    #    }

  #    #    # Debug hints etc
  #    #    {
  #    #      "before" = [ "[" "d" ];
  #    #      "commands" = [ "editor.action.marker.prev" ];
  #    #    }
  #    #    {
  #    #      "before" = [ "]" "d" ];
  #    #      "commands" = [ "editor.action.marker.next" ];
  #    #    }
  #    #    {
  #    #      "before" = [ "<leader>" "c" "a" ];
  #    #      "commands" = [ "editor.action.quickFix" ];
  #    #    }
  #    #    { "before" = [ "leader" "f" "f" ]; "commands" = [ "workbench.action.quickOpen" ]; }
  #    #    { "before" = [ "leader" "d" "f" ]; "commands" = [ "editor.action.formatDocument" ]; }
  #    #    {
  #    #      "before" = [ "leader" "e" ];
  #    #      "commands" = [ "editor.action.showDefinitionPreviewHover" ];
  #    #    }
  #    #  ];
  #    #  "vim.visualModeKeyBindings" = [
  #    #    # Stay in visual mode while indenting
  #    #    { "before" = [ "<" ]; "commands" = [ "editor.action.outdentLines" ]; }
  #    #    { "before" = [ ">" ]; "commands" = [ "editor.action.indentLines" ]; }
  #    #    # Move selected lines while staying in visual mode
  #    #    { "before" = [ "J" ]; "commands" = [ "editor.action.moveLinesDownAction" ]; }
  #    #    { "before" = [ "K" ]; "commands" = [ "editor.action.moveLinesUpAction" ]; }
  #    #    # toggle comment selection
  #    #    { "before" = [ "leader" "c" ]; "commands" = [ "editor.action.commentLine" ]; }
  #    #  ];

  #    #  # Nix
  #    #  "nix.enableLanguageServer" = true;
  #    #  "nix.serverPath" = "${pkgs.nil}/bin/nil";
  #    #  "nix.serverSettings" = {
  #    #    "nil" = {
  #    #      #"diagnostics" = {
  #    #      #  "ignored" = ["unused_binding" "unused_with"];
  #    #      #};
  #    #      "formatting" = {
  #    #        "command" = [ "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt" ];
  #    #      };
  #    #    };
  #    #  };

  #    #  "files.autoSave" = "off";
  #    #  "[nix]"."editor.tabSize" = 2;
  #    #  #"window.zoomLevel" = 1;

  #    #  # Agda
  #    #  "agdaMode.connection.agdaLanguageServer" = false;
  #    #  "agdaMode.connection.commandLineOptions" = "-l standard-library -i .";
  #    #};
  #  };
  #};
}
