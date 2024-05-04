# My cozy home UwU
# Some config must be anbled manually, such as the gnome-config.
# This is done so that e.g. gnome and kde settings don't clash.
{ lib, config, pkgs, inputs, outputs, self, ... }:
let
  cfg = config.home-desktop;
  # Custom packages defined in the toplevel flake
  cpkgs = outputs.packages.${pkgs.system};
in {
  imports = [
    ./xdg.nix
    ./bash.nix
    ./vscode.nix
  ];

  options.home-desktop = {
    enable = lib.mkEnableOption "Cozy home desktop (or laptop (or anything else)) config";
  };

  config = lib.mkIf cfg.enable {
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

    # Shell aliases
    home.shellAliases = {
      g = "git";
      e = "nvim";
      open = "xdg-open";
      "\":q\"" = "exit";
      "\"..\"" = "cd ..";
      cp = "cp -v";
      mv = "mv -v";
      rm = "rm -v";
      ncmpcpp = "echo 'trying mpd: ' ; mpd ; ncmpcpp";
      bat = "bat --theme=base16";
      die = "sudo shutdown now";

      # Swag
      uwu = "${pkgs.fastfetch}/bin/fastfetch --logo-width 40 --logo-height 20 --kitty-direct ${self}/logo.png";
      
      # Projects
      p = "cd ~/Projects";
      
      # Open new terminal in directory
      gg = "gnome-terminal . &";
      xx = "kgx & disown";
      aa = "alacritty & disown";
      kk = "kitty & disown";
      
      # Networking
      iplist = "nmap -sP 192.168.1.1/24";
      
      # VSCode/Codium
      codew = "NIXOS_OZONE_WL=1 code";
      codiw = "NIXOS_OZONE_WL=1 codium";
      
      # Nix Fast
      n = "cd ~/Projects/nixos-config";
      flake = "nix flake";
      nd = "nix develop";
      rebuild = "nh os switch .";
      hmrebuild = "nh home switch .";
      rebuildboot = "nh os boot .";
    };

    # Session variables
    systemd.user.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      BROWSER = "firefox";
      MANPAGER= "nvim +Man!";
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
      aliases = {
        a = "add";
        co = "checkout";
        b = "branch";
        c = "commit";
        s = "status";
        r = "remote";
        l = "log";
        cl = "clone";
        p = "pull";
        pu = "push";
        f = "fetch";
        sh = "show";
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
      # General applications
      steam-run
      steamtinkerlaunch
      mangohud
      obs-studio
      protonup-qt
      baobab
      vesktop
      helvum
      nicotine-plus
      ardour
      r2modman
      unityhub
      openttd
      pkgs.osu-lazer
      superTuxKart
      gamescope
      audacity
      mullvad-vpn
      fragments
      blender
      logseq
      inkscape

      # Minecraft time
      prismlauncher
      jdk21

      # HTML / CSS / JSON / ESLint language server
      vscode-langservers-extracted

      # C / C++
      ccls          # A C/C++ language server

      # Haskell
      haskell-language-server

      # Nix??? 😲
      nil  # Nix language server

      # Godot
      godot_4

      # Rust
      rustfmt
      rust-analyzer # Rust language server

      # Lua
      lua-language-server

      # Go
      gopls

      # Agda
      (agda.withPackages [ agdaPackages.standard-library ])

      # Typst
      typst-lsp

      # WGSL
      inputs.wgsl_analyzer.packages.${system}.default

      # C#
      omnisharp-roslyn

      cpkgs.yuzu
      cpkgs.simple-shell-utils
    ];

    xdg.desktopEntries =
    let
      # A desktop entry that launches an electron app with ozone turned on
      electronWaylandApp = name : {
        name = "${name} wayland";
        exec = "${name} --ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-webrtc-pipewire-capturer";
        icon = name;
      };
      # Takes a list of executable names and makes wayland desktop entries for them
      makeElectronWaylandApps = appNames : (lib.listToAttrs (map (name : { name = "${name}Wayland"; value = electronWaylandApp name; }) appNames));
    in {
      godotSingleWindow = {
        name = "Godot 4 Single Window";
        genericName = "Godot 4 Single Window";
        exec = "godot4 --single-window";
      };
      steamGamescope = {
        name = "Steam Gamescope";
        genericName = "Steam";
        # -e enables steam integration, -f fullscreens the window by default
        exec = "gamescope -W 1920 -H 1080 --adaptive-sync -f -r 600 -e -- steam";
      };
    } // (makeElectronWaylandApps [
      "logseq"
      "code"
      "codium"
      "vesktop"
    ]);
  };
}
