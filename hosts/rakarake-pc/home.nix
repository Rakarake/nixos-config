{
  imports = [ ../../home ];
  
  home-desktop.enable = true;
  home-hyprland = {
    enable = true;
    useSwayidle = false;
    monitorAndWorkspaceConfig = ''
      # Monitors
      monitor=HDMI-A-1,highrr,-1920x0,1
      monitor=DP-3,highrr,0x0,1

      # Workspaces
      workspace=DP-1,1
      workspace=HDMI-A-1,2,default:true
      workspace=HDMI-A-1,3
      workspace=HDMI-A-1,4
      workspace=HDMI-A-1,5
      workspace=HDMI-A-1,6
      workspace=HDMI-A-1,7
      workspace=HDMI-A-1,8
      workspace=HDMI-A-1,9
    '';
  };
}
