{ lib, pkgs, ... }: {
  # Wallpaper
  stylix.image = lib.mkForce ./wallpaper.png;

  home-desktop.enable = true;
  home-hyprland = {
    enable = true;
    additionalConfig = ''
      # Screen recording
      bind=SUPERALT,R,exec,${pkgs.wl-screenrec}/bin/wl-screenrec -g "$(slurp)" -f ~/Videos/vebeo.mp4 --audio --audio-device alsa_output.pci-0000_00_1f.3.analog-stereo.monitor
      bind=SUPERALT,T,exec,pkill --signal SIGINT wl-screenrec
    '';
  };
}
