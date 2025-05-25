{ lib, pkgs, ... }: {
  # Wallpaper
  home-xdg.wallpaper = lib.mkForce ./wallpaper.png;

  home-desktop.enable = true;
  home-river = {
    enable = true;
    extraConfig = ''
      # Screenrecording
      # To file in Videos + clipboard
      # TODO check the right audo input device
      riverctl map normal Super+Alt V spawn\
        '${pkgs.wl-screenrec}/bin/wl-screenrec -g "$(slurp)" -f ~/Videos/vibeo.mp4\
        --audio --audio-device alsa_output.pci-0000_14_00.4.analog-stereo.monitor\
        ; wl-copy --type "text/uri-list" <<< file://$(realpath ~/Videos/vibeo.mp4)'

      # To file in Videos
      riverctl map normal Super+Alt+Shift V spawn\
        '${pkgs.wl-screenrec}/bin/wl-screenrec -g "$(slurp)" -f ~/Videos/vibeo.mp4\
        --audio --audio-device alsa_output.pci-0000_14_00.4.analog-stereo.monitor'
    '';
  };
  #home-gnome.enable = true;
  #home-hyprland = {
  #  enable = true;
  #  additionalConfig = ''
  #    # Screen recording
  #    bind=SUPERALT,R,exec,${pkgs.wl-screenrec}/bin/wl-screenrec -g "$(slurp)" -f ~/Videos/vebeo.mp4 --audio --audio-device alsa_output.pci-0000_00_1f.3.analog-stereo.monitor
  #    bind=SUPERALT,T,exec,pkill --signal SIGINT wl-screenrec
  #  '';
  #};
}
