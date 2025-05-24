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
      #systemd = {
      #  enable = false;
      #  target = "graphical-session.target";
      #};
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
          "river/language"
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
        "pulseaudio" = {
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
      #style = ''
      #  * {
      #    font-family: "JetBrainsMono Nerd Font";
      #    font-size: 12pt;
      #    font-weight: bold;
      #    transition-property: background-color;
      #    transition-duration: 0.5s;
      #  }
      #  button {
      #    border-radius: 8px;
      #  }
      #  @keyframes blink_red {
      #    to {
      #      background-color: rgb(242, 143, 173);
      #      color: rgb(26, 24, 38);
      #    }
      #  }
      #  .warning, .critical, .urgent {
      #    animation-name: blink_red;
      #    animation-duration: 1s;
      #    animation-timing-function: linear;
      #    animation-iteration-count: infinite;
      #    animation-direction: alternate;
      #    border-radius: 8px;
      #  }
      #  window#waybar {
      #    background-color: transparent;
      #  }
      #  window > box {
      #    background-color: #1e1e2a;
      #    padding: 3px;
      #    padding-left:8px;
      #    border: 0px none #33ccff;
      #  }

      #  #workspaces {
      #          padding-left: 4px;
      #          padding-right: 4px;
      #        }
      #  #workspaces button {
      #          padding-top:    0px;
      #          padding-bottom: 0px;
      #          padding-left:   2px;
      #          padding-right:  2px;
      #          margin-left:    2px;
      #          margin-right:   2px;

      #          color: rgb(181, 232, 224);
      #        }
      #  #workspaces button.active {
      #          background-color: rgb(181, 232, 224);
      #          color: rgb(26, 24, 38);
      #        }
      #  #workspaces button.urgent {
      #          color: rgb(26, 24, 38);
      #        }
      #  #workspaces button:hover {
      #          background-color: rgb(248, 189, 150);
      #          color: rgb(26, 24, 38);
      #        }
      #        tooltip {
      #          background: rgb(48, 45, 65);
      #        }
      #        tooltip label {
      #          color: rgb(217, 224, 238);
      #        }
      #  #custom-launcher {
      #          font-size: 20px;
      #          padding-left: 8px;
      #          padding-right: 6px;
      #          color: #7ebae4;
      #        }
      #  #language {
      #    color: #b7bdf8;
      #  }
      #  #mode, #clock, #memory,#cpu,#mpd, #custom-wall, #temperature, #backlight, #pulseaudio, #network, #battery, #idle_inhibitor, #custom-powermenu, #custom-workspace-left, #custom-workspace-right, #language {
      #          padding-left: 7px;
      #          padding-right: 7px;
      #        }
      #        /* #mode { */
      #        /* 	margin-left: 10px; */
      #        /* 	background-color: rgb(248, 189, 150); */
      #        /*     color: rgb(26, 24, 38); */
      #        /* } */
      #  #battery {
      #          color: rgb(181, 232, 224);
      #         }
      #  #memory {
      #          color: rgb(181, 232, 224);
      #        }
      #  #cpu {
      #          color: rgb(245, 194, 231);
      #        }
      #  #clock {
      #          color: rgb(217, 224, 238);
      #        }
      #  #idle_inhibitor {
      #          color: rgb(221, 182, 242);
      #        }
      #  #custom-wall {
      #          color: #33ccff;
      #     }
      #  #temperature {
      #          color: rgb(150, 205, 251);
      #        }
      #  #backlight {
      #          color: rgb(248, 189, 150);
      #        }
      #  #pulseaudio {
      #          color: rgb(245, 224, 220);
      #        }
      #  #network {
      #          color: #ABE9B3;
      #        }
      #  #network.disconnected {
      #          color: rgb(255, 255, 255);
      #        }
      #  #custom-powermenu {
      #          color: rgb(242, 143, 173);
      #          padding-right: 8px;
      #        }
      #  #custom-workspace-left {
      #          color: rgb(181, 232, 224);
      #        }
      #  #custom-workspace-right {
      #          color: rgb(181, 232, 224);
      #        }
      #  #tray {
      #          padding-right: 8px;
      #          padding-left: 10px;
      #        }
      #  #mpd.paused {
      #          color: #414868;
      #          font-style: italic;
      #        }
      #  #mpd.stopped {
      #          background: transparent;
      #        }
      #  #mpd {
      #          color: #c0caf5;
      #        }
      #'';
    };
  };
}
