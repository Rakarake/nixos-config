{
  imports = [ ../../home ];
  
  home-desktop.enable = true;
  home-hyprland = {
    enable = true;
    useSwayidle = false;
    monitorAndWorkspaceConfig =
    let
      mainMonitor = "HDMI-A-1";
      leftMonitor = "DP-3";
    in
    ''
      # Monitors
      monitor=${mainMonitor},highrr,0x0,1
      monitor=${leftMonitor},highrr,-1920x0,1

      # Workspaces
      workspace = 1, monitor:${leftMonitor}, default:true
      workspace = 2, monitor:${mainMonitor}, default:true
      workspace = 3, monitor:${mainMonitor}
      workspace = 4, monitor:${mainMonitor}
      workspace = 5, monitor:${mainMonitor}
      workspace = 6, monitor:${mainMonitor}
      workspace = 7, monitor:${mainMonitor}
      workspace = 8, monitor:${mainMonitor}
      workspace = 9, monitor:${mainMonitor}
      workspace = 10, monitor:${mainMonitor}
    '';
  };
}
