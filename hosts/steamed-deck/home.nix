{ lib, pkgs, ... }: {
  # Wallpaper
  home-xdg.wallpaper = lib.mkForce ./wallpaper.png;

  home-desktop.enable = true;
  home-gnome.enable = true;
  home-river = {
    enable = true;
    extraConfigTop = let
      deckMonitor = "eDP-1";
    in ''
      wlr-randr --output ${deckMonitor} --transform 270 --pos 1280,0
      # For some reason, all outputs are DP-x
      wlr-randr --output DP-1 --right-of ${deckMonitor}
      wlr-randr --output DP-2 --left-of ${deckMonitor}

      riverctl map normal Super+Alt V spawn\
        'wl-screenrec -g "$(slurp)" -f ~/Videos/vibeo.mp4\
        --audio --audio-device\
        "alsa_loopback_device.alsa_output.pci-0000_04_00.5-platform-acp5x_mach.0.HiFi__Speaker__sink.monitor"\
        ; wl-copy --type "text/uri-list" <<< file://$(realpath ~/Videos/vibeo.mp4)'
    '';
  };
  #home-hyprland = {
  #  enable = true;
  #  useSwayidle = false;
  #  additionalConfig =
  #  let
  #    deckMonitor = "eDP-1";
  #    leftMonitor = "DP-4";
  #    rightMonitor = "DP-3";
  #  in
  #  ''
  #    # Monitors
  #    monitor=${leftMonitor},1920x1080@60,-1920x0,1
  #    monitor=${rightMonitor},1920x1080@120,0x0,1
  #    monitor=${deckMonitor},preferred,1920x0,1,transform,3

  #    # Workspaces
  #    workspace = 1,  monitor:${leftMonitor}, default:true
  #    workspace = 2,  monitor:${leftMonitor}, default:true
  #    workspace = 3,  monitor:${leftMonitor}
  #    workspace = 4,  monitor:${leftMonitor}
  #    workspace = 5,  monitor:${leftMonitor}
  #    workspace = 6,  monitor:${rightMonitor}
  #    workspace = 7,  monitor:${rightMonitor}
  #    workspace = 8,  monitor:${rightMonitor}
  #    workspace = 9,  monitor:${rightMonitor}
  #    workspace = 10, monitor:${rightMonitor}
  #    workspace = 11, monitor:${deckMonitor}
  #    bind = SUPER,O,workspace,11
  #    bind = SUPERSHIFT,O,movetoworkspace,11

  #    # Monitor screenshots
  #    bind=SUPER,R,exec,grim -o ${leftMonitor} - | wl-copy
  #    bind=SUPERSHIFT,R,exec,grim -o ${leftMonitor}
  #    bind=SUPER,T,exec,grim -o ${rightMonitor} - | wl-copt
  #    bind=SUPERSHIFT,T,exec,grim -o ${rightMonitor}
  #  '';
  #};
}
