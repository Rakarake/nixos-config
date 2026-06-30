{ inputs, ... }: {
  flake.nixosModules.kde = { lib, system, config, pkgs, ... }: {
    services = {
      desktopManager.plasma6.enable = true;
      displayManager.plasma-login-manager.enable = true;
      blueman.enable = true;
    };   
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = false;
    };

    environment.systemPackages = with pkgs; [
      kdePackages.oxygen
      kdePackages.oxygen-icons
      tesseract
      scrcpy
    ];
  };
  flake.homeModules.kde = { pkgs, ... }: let
    #collect-garbage = pkgs.writeShellScriptBin "collect-garbage" ''
    #  pkexec nh clean all -K 7d \
    #  && nix-store --optimize \
    #  && notify-send "Done collecting garbage."
    #'';
    chooseCameraCommand = pkgs.writeShellScriptBin "choose-camera" ''
     d=$(rofi -dmenu -p "Choose Camera Device")
     scrcpy --no-window --video-source=camera --camera-size=1920x1080 --camera-facing=back --v4l2-sink=/dev/video$d --no-playback
    '';
    projectChooserCommand = pkgs.writeShellScriptBin "project-chooser" ''
      dir=$(ls ~/Projects/ | rofi -dmenu -p "Choose project: ") && konsole -e sh -c "cd ~/Projects/$dir && tmux attach -t $dir || tmux new -s $dir"
    '';
    openNotesCommand = pkgs.writeShellScriptBin "open-notes" ''
      konsole -e sh -c "cd ~/Notes/ && tmux attach -t notes || tmux new -s notes $EDITOR"
    '';
    collectGarbageCommand = pkgs.writeShellScriptBin "collect-garbage" ''
      pkexec nh clean all -K 7d \
      && nix-store --optimize \
      && notify-send "Done collecting garbage."
    '';
  in {
    imports = [
      inputs.plasma-manager.homeModules.plasma-manager
    ];
    home.packages = with pkgs; [
      rofi
      vlc
      chooseCameraCommand
      projectChooserCommand
      openNotesCommand
      collectGarbageCommand
    ];
    programs.plasma = {
      enable = true;
      hotkeys.commands."power-off" = {
        name = "Power Off";
        key = "Meta+Alt+Shift+S";
        command = "systemctl poweroff";
      };
      hotkeys.commands."reboot" = {
        name = "Reboot";
        key = "Meta+Alt+Shift+R";
        command = "systemctl reboot";
      };
      hotkeys.commands."suspend" = {
        name = "Reboot";
        key = "Meta+Alt+Shift+N";
        command = "systemctl suspend";
      };
      hotkeys.commands."collect-garbage" = {
        name = "Reboot";
        key = "Meta+Alt+Shift+G";
        command = "collect-garbage";
      };
      hotkeys.commands."program-picker" = {
        name = "Program Picker";
        key = "Meta+P";
        command = "project-chooser";
      };
      hotkeys.commands."open-notes" = {
        name = "Program Picker";
        key = "Shift+Meta+P";
        command = "open-notes";
      };
      hotkeys.commands."choose-camera" = {
        name = "Program Picker";
        key = "Meta+Control+Shift+C";
        command = "choose-camera";
      };
    };
  };
}

