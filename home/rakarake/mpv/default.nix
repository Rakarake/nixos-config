{ pkgs, ... }: {
  # Mpv
  programs.mpv = {
    enable = true;
    config = {
      hr-seek = "yes";
    };
    scripts = with pkgs.mpvScripts; [
      mpris
      thumbfast
      modernx
    ];
  };
}
