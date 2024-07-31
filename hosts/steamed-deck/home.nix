{ pkgs, ... }: {
  imports = [ ../../home/rakarake ../../home/rakarake/theme.nix ];

  # Wallpaper
  stylix.enable = true;
  stylix.image = ./wallpaper.jpg;
  stylix.polarity = "dark";
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-macchiato.yaml";

  home-desktop.enable = true;
  home-hyprland = {
    enable = true;
    useSwayidle = false;
    additionalConfig =
    let
      deckMonitor = "eDP-1";
      leftMonitor = "DP-4";
      rightMonitor = "DP-3";
    in
    ''
      # Monitors
      monitor=${leftMonitor},1920x1080@60,-1920x0,1
      monitor=${rightMonitor},1920x1080@120,0x0,1
      monitor=${deckMonitor},preferred,1920x0,1,transform,3

      # Workspaces
      workspace = 1,  monitor:${leftMonitor}, default:true
      workspace = 2,  monitor:${leftMonitor}, default:true
      workspace = 3,  monitor:${leftMonitor}
      workspace = 4,  monitor:${leftMonitor}
      workspace = 5,  monitor:${leftMonitor}
      workspace = 6,  monitor:${rightMonitor}
      workspace = 7,  monitor:${rightMonitor}
      workspace = 8,  monitor:${rightMonitor}
      workspace = 9,  monitor:${rightMonitor}
      workspace = 10, monitor:${rightMonitor}
      workspace = 11, monitor:${deckMonitor}
      bind = SUPER,O,workspace,11
      bind = SUPERSHIFT,O,movetoworkspace,11

      # Monitor screenshots
      bind=SUPER,R,exec,grim -o ${leftMonitor} - | wl-copy
      bind=SUPERSHIFT,R,exec,grim -o ${leftMonitor}
      bind=SUPER,T,exec,grim -o ${rightMonitor} - | wl-copt
      bind=SUPERSHIFT,T,exec,grim -o ${rightMonitor}
    '';
  };
}
