{ lib, config, ... }:
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
        target = "graphical-session.target";
      };
      style = ''
               * {
                 font-family: "JetBrainsMono Nerd Font";
                 font-size: 12pt;
                 font-weight: bold;
                 transition-property: background-color;
                 transition-duration: 0.5s;
               }
               button {
                 border-radius: 8px;
               }
               @keyframes blink_red {
                 to {
                   background-color: rgb(242, 143, 173);
                   color: rgb(26, 24, 38);
                 }
               }
               .warning, .critical, .urgent {
                 animation-name: blink_red;
                 animation-duration: 1s;
                 animation-timing-function: linear;
                 animation-iteration-count: infinite;
                 animation-direction: alternate;
               }
               window#waybar {
                 background-color: transparent;
               }
               window > box {
                 background-color: #1e1e2a;
                 padding: 3px;
                 padding-left:8px;
                 border: 0px none #33ccff;
               }
         #workspaces {
                 padding-left: 4px;
                 padding-right: 4px;
               }
         #workspaces button {
                 padding-top:    0px;
                 padding-bottom: 0px;
                 padding-left:   2px;
                 padding-right:  2px;
                 margin-left:    2px;
                 margin-right:   2px;
               }
         #workspaces button.active {
                 background-color: rgb(181, 232, 224);
                 color: rgb(26, 24, 38);
               }
         #workspaces button.urgent {
                 color: rgb(26, 24, 38);
               }
         #workspaces button:hover {
                 background-color: rgb(248, 189, 150);
                 color: rgb(26, 24, 38);
               }
               tooltip {
                 background: rgb(48, 45, 65);
               }
               tooltip label {
                 color: rgb(217, 224, 238);
               }
         #custom-launcher {
                 font-size: 20px;
                 padding-left: 8px;
                 padding-right: 6px;
                 color: #7ebae4;
               }
         #mode, #clock, #memory, #temperature,#cpu,#mpd, #custom-wall, #temperature, #backlight, #wireplumber, #network, #battery, #custom-powermenu, #custom-cava-internal, #custom-workspace-left, #custom-workspace-right {
                 padding-left: 10px;
                 padding-right: 10px;
               }
               /* #mode { */
               /* 	margin-left: 10px; */
               /* 	background-color: rgb(248, 189, 150); */
               /*     color: rgb(26, 24, 38); */
               /* } */
         #battery {
                 color: rgb(181, 232, 224);
                }
         #memory {
                 color: rgb(181, 232, 224);
               }
         #cpu {
                 color: rgb(245, 194, 231);
               }
         #clock {
                 color: rgb(217, 224, 238);
               }
         #idle_inhibitor {
                 color: rgb(221, 182, 242);
               }
         #custom-wall {
                 color: #33ccff;
            }
         #temperature {
                 color: rgb(150, 205, 251);
               }
         #backlight {
                 color: rgb(248, 189, 150);
               }
         #wireplumber {
                 color: rgb(245, 224, 220);
               }
         #network {
                 color: #ABE9B3;
               }
         #network.disconnected {
                 color: rgb(255, 255, 255);
               }
         #custom-powermenu {
                 color: rgb(242, 143, 173);
                 padding-right: 8px;
               }
         #custom-workspace-left {
                 color: rgb(181, 232, 224);
               }
         #custom-workspace-right {
                 color: rgb(181, 232, 224);
               }
         #tray {
                 padding-right: 8px;
                 padding-left: 10px;
               }
         #mpd.paused {
                 color: #414868;
                 font-style: italic;
               }
         #mpd.stopped {
                 background: transparent;
               }
         #mpd {
                 color: #c0caf5;
               }
         #custom-cava-internal{
                 font-family: "Hack Nerd Font" ;
                 color: #33ccff;
               }
      '';
      settings = [{
        "layer" = "top";
        "position" = "top";
        modules-left = [
          "custom/launcher"
          "custom/workspace-left"
          "hyprland/workspaces"
          "custom/workspace-right"
          "temperature"
          "cpu"
          "memory"
          #"custom/cava-internal"
        ];
        modules-center = [
          "clock"
        ];
        modules-right = [
          "wireplumber"
          "backlight"
          "network"
          "battery"
          "idle_inhibitor"
          "tray"
          "custom/powermenu"
        ];
        "custom/launcher" = {
          "format" = " ";
          "on-click" = "pkill rofi || rofi -show combi -modes combi -combi-modes \"window,drun,run\" -icon-theme \"Papirus\" -show-icons";
          "on-click-middle" = "exec default_wall";
          "on-click-right" = "exec wallpaper_random";
          "tooltip" = false;
        };
        "custom/cava-internal" = {
          "exec" = "#sleep 1s && cava-internal";
          "tooltip" = false;
        };
        "wireplumber" = {
          "scroll-step" = 1;
          "format" = "{icon} {volume}%";
          "format-muted" = "󰖁 Muted";
          "format-icons" = {
            "default" = [ "" "" "" ];
          };
          "on-click" = "pamixer -t";
          "tooltip" = false;
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
          "states" = {
            "warning" = 85;
          };
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
        "mpd" = {
          "max-length" = 25;
          "format" = "<span foreground='#bb9af7'></span> {title}";
          "format-paused" = " {title}";
          "format-stopped" = "<span foreground='#bb9af7'></span>";
          "format-disconnected" = "";
          "on-click" = "mpc --quiet toggle";
          "on-click-right" = "mpc update; mpc ls | mpc add";
          "on-click-middle" = "kitty --class='ncmpcpp' ncmpcpp ";
          "on-scroll-up" = "mpc --quiet prev";
          "on-scroll-down" = "mpc --quiet next";
          "smooth-scrolling-threshold" = 5;
          "tooltip-format" = "{title} - {artist} ({elapsedTime:%M:%S}/{totalTime:%H:%M:%S})";
        };
        "network" = {
          "format-disconnected" = "󰯡 Disconnected";
          "format-ethernet" = "󰒢 Connected!";
          "format-linked" = "󰖪 {essid} (No IP)";
          "format-wifi" = "󰖩 {essid}";
          "interval" = 1;
          "tooltip" = false;
        };
        "custom/powermenu" = {
          "format" = " ";
          "on-click" = "systemctl suspend";
          "tooltip" = false;
        };
        "custom/workspace-left" = {
          "format" = "";
          "on-click" = "hyprctl dispatch workspace -1";
        };
        "custom/workspace-right" = {
          "format" = "";
          "on-click" = "hyprctl dispatch workspace +1";
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
      }];
    };
  };
}
