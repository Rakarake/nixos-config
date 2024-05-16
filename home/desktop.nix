# My cozy home UwU
# Some config must be anbled manually, such as the gnome-config.
# This is done so that e.g. gnome and kde settings don't clash.
{ lib, config, pkgs, outputs, ... }:
let
  cfg = config.home-desktop;
  # Custom packages defined in the toplevel flake
  cpkgs = outputs.packages.${pkgs.system};
in {
  imports = [
    ./xdg.nix
    ./vscode.nix
    ./common.nix
  ];

  options.home-desktop = {
    enable = lib.mkEnableOption "Cozy home desktop (or laptop (or anything else)) config";
  };

  config = lib.mkIf cfg.enable {
    home-common.enable = true;
    # XDG base directories
    home-xdg.enable = true;

    # Neovim config
    dev-stuff.enable = true;

    # Kitty config
    home.file.".config/kitty/kitty.conf".source = ./kitty/kitty.conf;
    home.file.".config/kitty/Catppuccin-Macchiato.conf".source = ./kitty/Catppuccin-Macchiato.conf;

    # Ghci prompt
    home.file.".ghci".source = ./.ghci;

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

    # User specific packages
    home.packages = with pkgs; [
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
      cpkgs.yuzu
      cpkgs.simple-shell-utils

      # Minecraft time
      prismlauncher
      jdk21

      # Godot
      godot_4
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
