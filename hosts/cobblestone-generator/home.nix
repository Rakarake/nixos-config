{ pkgs, inputs, system, ... }: {
  imports = [ ../../home/rakarake/global.nix ../../home/rakarake ../../home/rakarake/theme.nix ];

  # Wallpaper
  stylix.enable = true;
  stylix.image = ../../home/rakarake/wallpaper.png;

  home-desktop.enable = true;
  home-gnome.enable = true;
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
      bind=SUPER,T,exec,grim -o ${mainMonitor} - | wl-copy
      bind=SUPERSHIFT,T,exec,grim -o ${mainMonitor}

      # Screen recording
      bind=SUPERALT,R,exec,${pkgs.wl-screenrec}/bin/wl-screenrec -g "$(slurp)" -f ~/Videos/vebeo.mp4 --audio --audio-device alsa_output.pci-0000_14_00.4.analog-stereo.monitor
      bind=SUPERALT,T,exec,pkill --signal SIGINT wf-recorder
    '';
  };
  home.packages = [
    inputs.yuzu.packages.${system}.default
  ];
}
