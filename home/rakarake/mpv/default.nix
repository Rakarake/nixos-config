{ pkgs, ... }: {
  # Mpv
  programs.mpv = {
    enable = true;
    config = {
      hr-seek = "yes";
      osd-on-seek = "no";
    };
    scripts = with pkgs.mpvScripts; [
      mpris
      thumbfast
      modernx
    ];
  };
}
