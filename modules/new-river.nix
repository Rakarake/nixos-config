{ inputs, self, ... }: {
  flake.homeModules.new-river = { lib, config, pkgs, ... }: {
    home.packages = with pkgs; [
      river
    ];
    xdg.configFile."river/init" = {
      executable = true;
      text = ''
        systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
        dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=river
        systemctl --user restart xdg-desktop-portal
        ~/Projects/test/zrwm/zrwm &
        foot &
      '';
    };
  };
}
