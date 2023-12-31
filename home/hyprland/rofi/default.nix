{ lib, config, pkgs, ... }:
with lib;                      
let
  cfg = config.home-rofi;
in {
  options.home-rofi = {
    enable = mkEnableOption "Custom gnome system configuration";
  };
  config = mkIf cfg.enable {
    programs.rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
      terminal = "${pkgs.kitty}/bin/kitty";
      theme = ./theme.rasi;
      plugins = [
        pkgs.rofi-emoji
        pkgs.wtype  # Used to output the emoji
      ];
    };
    #home.packages = [
    #  pkgs.rofi-wayland
    #];
    #home.file.".config/rofi/theme.rasi".text = ''
    #  * {
    #      bg0:    #3C3836;
    #      bg1:    #282828;
    #      bg2:    #3D3D3D80;
    #      bg3:    #B8BB26;
    #      fg0:    #E2D3AB;
    #      fg1:    #FFFFFF;
    #      fg2:    #928374;
    #      fg3:    #3D3D3D;
    #  }
    #  
    #  * {
    #      font:   "Roboto 12";
    #  
    #      background-color:   transparent;
    #      text-color:         @fg0;
    #  
    #      margin:     0px;
    #      padding:    0px;
    #      spacing:    0px;
    #  }
    #  
    #  window {
    #      location:       center;
    #      width:          480;
    #      border-radius:  24px;
    #      
    #      background-color:   @bg0;
    #  }
    #  
    #  mainbox {
    #      padding:    12px;
    #  }
    #  
    #  inputbar {
    #      background-color:   @bg1;
    #      border-color:       @bg3;
    #  
    #      border:         2px;
    #      border-radius:  16px;
    #  
    #      padding:    8px 16px;
    #      spacing:    8px;
    #      children:   [ prompt, entry ];
    #  }
    #  
    #  prompt {
    #      text-color: @fg2;
    #  }
    #  
    #  entry {
    #      placeholder:        "Search";
    #      placeholder-color:  @fg3;
    #  }
    #  
    #  message {
    #      margin:             12px 0 0;
    #      border-radius:      16px;
    #      border-color:       @bg2;
    #      background-color:   @bg2;
    #  }
    #  
    #  textbox {
    #      padding:    8px 24px;
    #  }
    #  
    #  listview {
    #      background-color:   transparent;
    #  
    #      margin:     12px 0 0;
    #      lines:      8;
    #      columns:    1;
    #  
    #      fixed-height: false;
    #  }
    #  
    #  element {
    #      padding:        8px 16px;
    #      spacing:        8px;
    #      border-radius:  16px;
    #  }
    #  
    #  element normal active {
    #      text-color: @bg3;
    #  }
    #  
    #  element selected normal, element selected active {
    #      background-color:   @bg3;
    #  }
    #  
    #  element-icon {
    #      size:           1em;
    #      vertical-align: 0.5;
    #  }
    #  
    #  element-text {
    #      text-color: inherit;
    #  }
    #'';
  };
}


