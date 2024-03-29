# My cozy home UwU
# Some config must be anbled manually, such as the gnome-config.
# This is done so that e.g. gnome and kde settings don't clash.
{ lib, config, pkgs, wgsl_analyzer, ... }:
with lib;
let
  cfg = config.home-desktop;
in {
  imports = [
    ./xdg.nix
    ./bash.nix
    ./vscode.nix
  ];

  options.home-desktop = {
    enable = mkEnableOption "Cozy home desktop (or laptop (or anything else)) config";
  };

  config = mkIf cfg.enable {
    home.username = "rakarake";
    home.homeDirectory = "/home/rakarake";
    home.stateVersion = "23.05";
    programs.home-manager.enable = true;

    # Enable default applications
    home-xdg.enable = true;

    # Neovim config
    dev-stuff.enable = true;

    # Bash config
    home-bash.enable = true;

    # Generic shell options
    home.file.".alias".source = ./.alias;

    # Direnv
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    # Kitty config
    home.file.".config/kitty/kitty.conf".source = ./kitty/kitty.conf;
    home.file.".config/kitty/Catppuccin-Macchiato.conf".source = ./kitty/Catppuccin-Macchiato.conf;
    # Ghci prompt
    home.file.".ghci".source = ./.ghci;

    # Git config
    programs.git = {
      enable = true;
      lfs.enable = true;
      userName  = "Rakarake";
      userEmail = "rak@rakarake.xyz";
      extraConfig = {
        core = {
          editor = "nvim";
        };
        color = {
          ui = "auto";
        };
        user = {
          signingKey = "98CF6C24F40B3531!";
        };
      };
    };

    # SSH
    programs.ssh = {
      enable = true;
      matchBlocks."ssh.rakarake.xyz".proxyCommand = "${pkgs.cloudflared}/bin/cloudflared access ssh --hostname ssh.rakarake.xyz";
    };

    # Virt-manager error free
    dconf.settings = {
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = ["qemu:///system"];
        uris = ["qemu:///system"];
      };
    };

    # Programming packages
    home.packages = with pkgs; [
      # HTML / CSS / JSON / ESLint language server
      vscode-langservers-extracted

      # C / C++
      ccls          # A C/C++ language server
      mpi           # C message passing

      # Haskell
      haskell-language-server

      # Nix??? 😲
      nil  # Nix language server

      # Godot
      godot_4

      # Rust
      rustfmt
      rust-analyzer # Rust language server

      # Python
      python3

      # Lua
      lua
      lua-language-server

      # Go
      gopls

      # Agda
      (agda.withPackages [ agdaPackages.standard-library ])

      # Typst
      typst
      typst-lsp

      # WGSL
      wgsl_analyzer.packages.${system}.default

      # C#
      omnisharp-roslyn
    ];

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

    # Discord Wayland
    xdg.desktopEntries.discordWayland = {
      name = "Discord Wayland";
      genericName = "Discord Wayland";
      exec = "discord --ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-webrtc-pipewire-capturer";
    };

    # Webcord Wayland
    xdg.desktopEntries.webcordWayland = {
      name = "Webcord Wayland";
      genericName = "Webcord Wayland";
      exec = "webcord --ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-webrtc-pipewire-capturer";
    };
    
    # Steam Gamescope
    xdg.desktopEntries.steamGamescope = {
      name = "Steam Gamescope";
      genericName = "Steam";
      # -e enables steam integration, -f fullscreens the window by default
      exec = "gamescope -W 1920 -H 1080 --adaptive-sync -f -r 600 -e -- steam";
    };

    # VSCode Wayland
    xdg.desktopEntries.vscodeWayland = {
      name = "VSCode Wayland";
      genericName = "VSCode Wayland";
      exec = "code --ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-webrtc-pipewire-capturer";
    };

    # VSCode Wayland
    xdg.desktopEntries.vscodiumWayland = {
      name = "VSCodium Wayland";
      genericName = "VSCode Wayland";
      exec = "codium --ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-webrtc-pipewire-capturer";
    };
  };
}
