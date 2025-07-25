{
  home-desktop.enable = true;
  home-river = let
    mainMonitor = "DP-1";
    leftMonitor = "DP-2";
  in {
    enable = true;
    useSwayidle = false;
    extraConfigTop = ''
      # Monitor setup
      wlr-randr --output ${mainMonitor} --mode 1920x1080@144.001007 --pos 1920,0
      wlr-randr --output ${leftMonitor} --mode 1920x1080@143.854996 --pos 0,0
    '';
    extraConfig = ''
      # Monitor screenshots
      riverctl map normal Super R       spawn "grim -o ${leftMonitor} - | wl-copy"
      riverctl map normal Super+Shift R spawn "grim -o ${leftMonitor}"
      riverctl map normal Super T       spawn "grim -o ${mainMonitor} - | wl-copy"
      riverctl map normal Super+Shift T spawn "grim -o ${mainMonitor}"

      # Screen recording
      # To file in Videos + clipboard
      riverctl map normal Super+Alt V spawn\
        'wl-screenrec -g "$(slurp)" -f ~/Videos/vibeo.mp4\
        --audio --audio-device alsa_output.pci-0000_14_00.4.analog-stereo.monitor\
        ; wl-copy --type "text/uri-list" <<< file://$(realpath ~/Videos/vibeo.mp4)'
    '';
  };
  #home-gnome.enable = true;
  #home-hyprland = {
  #  enable = true;
  #  useSwayidle = false;
  #  additionalConfig =
  #  let
  #    mainMonitor = "DP-1";
  #    leftMonitor = "DP-2";
  #  in
  #  ''
  #    # Monitors
  #    monitor=${mainMonitor},highrr,0x0,1
  #    monitor=${leftMonitor},highrr,-1920x0,1

  #    # Workspaces
  #    workspace = 1,  monitor:${leftMonitor}, default:true
  #    workspace = 2,  monitor:${leftMonitor}, default:true
  #    workspace = 3,  monitor:${leftMonitor}
  #    workspace = 4,  monitor:${leftMonitor}
  #    workspace = 5,  monitor:${leftMonitor}
  #    workspace = 6,  monitor:${mainMonitor}
  #    workspace = 7,  monitor:${mainMonitor}
  #    workspace = 8,  monitor:${mainMonitor}
  #    workspace = 9,  monitor:${mainMonitor}
  #    workspace = 10, monitor:${mainMonitor}

  #    # Monitor screenshots
  #    bind=SUPER,R,exec,grim -o ${leftMonitor} - | wl-copy
  #    bind=SUPERSHIFT,R,exec,grim -o ${leftMonitor}
  #    bind=SUPER,T,exec,grim -o ${mainMonitor} - | wl-copy
  #    bind=SUPERSHIFT,T,exec,grim -o ${mainMonitor}

  #    # Screen recording
  #    bind=SUPERALT,R,exec,${pkgs.wl-screenrec}/bin/wl-screenrec -g "$(slurp)" -f ~/Videos/vebeo.mp4 --audio --audio-device alsa_output.pci-0000_14_00.4.analog-stereo.monitor
  #    bind=SUPERALT,T,exec,pkill --signal SIGINT wl-screenrec
  #  '';
  #};
  ## Waybar CPU temperature sensor
  #programs.waybar.settings.mainBar.temperature.hwmon-path = "/sys/devices/platform/PNP0C14:02/wmi_bus/wmi_bus-PNP0C14:02/466747A0-70EC-11DE-8A39-0800200C9A66/hwmon/hwmon3/temp1_input";
}
