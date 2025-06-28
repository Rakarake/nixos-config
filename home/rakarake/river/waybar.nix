{ pkgs, lib, config, ... }:
with lib;                      
let
  cfg = config.home-waybar;
in {
  options.home-waybar = {
    enable = mkEnableOption "Waybar configuration";
  };
  config = mkIf cfg.enable {
    programs.waybar = {
      enable = true;
      systemd = {
        enable = false;
      };
      settings.mainBar = {
        layer = "bottom";
        position = "top";
        modules-left = [
          "temperature"
          "cpu"
          "memory"
        ];
        modules-center = [
          "clock"
        ];
        modules-right = [
          "pulseaudio"
          "backlight"
          "network"
          "battery"
          "idle_inhibitor"
          "tray"
          "custom/powermenu"
        ];

        "temperature" = {
          "critical-threshold" = 90;
          "format" = " {temperatureC}°C";
        };
        "river/language" = {
          "format" = "󰌌 {}";
        };
        "wireplumber" = {
          "scroll-step" = 2;
          "format" = "󰕾 {volume}%";
          "format-muted" = "󰖁 Muted";
          "on-click" = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          "max-volume" = 150;
        };
        "clock" = {
          "interval" = 60;
          "tooltip" = true;
          "format" = "{:%H:%M}";
          "tooltip-format" = "{:%Y-%m-%d}";
        };
        "memory" = {
          "interval" = 1;
          "format" = "󰻠 {percentage}%";
        };
        "cpu" = {
          "interval" = 1;
          "format" = "󰍛 {usage}%";
        };
        "battery" = {
          "format" = "{icon}  {capacity}%";
          "interval" = 60;
          "states" = {
            "warning" = 20;
            "critical" = 10;
          };
          "format-icons" = [ "" "" "" "" "" ];
          "max-length" = 25;
        };
        "backlight" = {
          "format" = "{icon} {percent}%";
          "format-icons" = [ "" "" ];
        };
        "network" = {
          "format-disconnected" = "󰯡 Disconnected";
          "format-ethernet" = "󰒢 Connected!";
          "format-linked" = "󰖪 {essid} (No IP)";
          "format-wifi" = "󰖩 {essid}";
          "interval" = 1;
          "tooltip" = false;
        };
        "tray" = {
          "icon-size" = 15;
          "spacing" = 5;
        };
        "idle_inhibitor" = {
          "format" = "{icon}";
          "format-icons" = {
            "activated" = "󰅶 ";
            "deactivated" = "󰾪 ";
          };
        };
      };
    };
  };
}
