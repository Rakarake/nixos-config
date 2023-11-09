{
  imports = [ ../../home ];
  
  home-desktop.enable = true;
  home-hyprland = {
    enable = true;
    monitorAndWorkspaceConfig = ''
      # Monitors
      monitor=HDMI-A-1,highrr,-1920x0,1
      monitor=DP-3,highrr,0x0,1

      # Workspaces
      workspace=HDMI-A-1,1
      workspace=DP-1,2,default:true
      workspace=DP-1,3
      workspace=DP-1,4
      workspace=DP-1,5
      workspace=DP-1,6
      workspace=DP-1,7
      workspace=DP-1,8
      workspace=DP-1,9
    '';
  };
}
