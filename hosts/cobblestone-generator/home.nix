{ pkgs, outputs, ... }:
let
  cpkgs = outputs.packages.${pkgs.system};
in
{
  imports = [ ../../home/rakarake ../../home/rakarake/theme.nix ];

  # Wallpaper
  stylix.enable = true;
  stylix.image = ../../home/rakarake/wallpaper.png;

  home-desktop.enable = true;
  home-hyprland = {
    enable = true;
    useSwayidle = false;
    additionalConfig =
    let
      mainMonitor = "DP-1";
      leftMonitor = "DP-2";
    in
    ''
      # Monitors
      monitor=${mainMonitor},highrr,0x0,1
      monitor=${leftMonitor},highrr,-1920x0,1

      # Workspaces
      workspace = 1,  monitor:${leftMonitor}, default:true
      workspace = 2,  monitor:${leftMonitor}, default:true
      workspace = 3,  monitor:${leftMonitor}
      workspace = 4,  monitor:${leftMonitor}
      workspace = 5,  monitor:${leftMonitor}
      workspace = 6,  monitor:${mainMonitor}
      workspace = 7,  monitor:${mainMonitor}
      workspace = 8,  monitor:${mainMonitor}
      workspace = 9,  monitor:${mainMonitor}
      workspace = 10, monitor:${mainMonitor}

      # Monitor screenshots
      bind=SUPER,R,exec,grim -o ${leftMonitor} - | wl-copy
      bind=SUPERSHIFT,R,exec,grim -o ${leftMonitor}
      bind=SUPER,T,exec,grim -o ${mainMonitor} - | wl-copt
      bind=SUPERSHIFT,T,exec,grim -o ${mainMonitor}
    '';
  };
  home.packages = [
    cpkgs.yuzu
  ];
}
