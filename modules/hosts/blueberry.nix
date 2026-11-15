{ inputs, self, ... }: let
  pkgs = import inputs.nixpkgs-unstable { system = "aarch64-linux"; config.allowUnfree = true; };
in {
  flake.nixosConfigurations.blueberry = inputs.nixos-raspberrypi.lib.nixosSystem {
    modules = [
      ({ config, lib, ... }: {
         imports = [
           inputs.nixos-raspberrypi.nixosModules.raspberry-pi-4.base
         ];
         networking.hostName = "blueberry";
         nixpkgs.hostPlatform = "aarch64-linux";

         # Bootloader tag?
         system.nixos.tags = let
           cfg = config.boot.loader.raspberry-pi;
         in [
           "raspberry-pi-${cfg.variant}"
           cfg.bootloader
           config.boot.kernelPackages.kernel.version
         ];


         fileSystems."/" =
           { device = "/dev/disk/by-label/NIXOS_SD";
             fsType = "ext4";
           };

         fileSystems."/boot/firmware" =
           { device = "/dev/disk/by-label/FIRMWARE";
             fsType = "vfat";
             options = [
               "noatime" "noauto" "x-systemd.automount" "x-systemd.idle-timeout=1min"
             ];
           };

         #system.stateVersion = "23.05"; # Did you read the comment?

         #fileSystems."/" =
         #  { device = "/dev/mmcblk1p2";
         #    fsType = "ext4";
         #  };
         environment.systemPackages = with pkgs; [ #with inputs.nixos-raspberrypi.packages.aarch64-linux; [
           vim
           git
           fastfetch
           nh
           openssh
         ];
         networking.firewall.allowedTCPPorts = [ 22 ];
         services.openssh = {
           enable = true;
           settings.PasswordAuthentication = false;
           settings.KbdInteractiveAuthentication = false;
           ports = [ 22 ];
         };
         users.users.root = {
           openssh.authorizedKeys.keys = ssh-keys.rakarake;
           openssh.authorizedKeys.keys = let ssh-keys = (import ../../ssh-keys.nix); in
             ssh-keys.rakarake ++
             ssh-keys.magarnicle;
         };
      })
    ];
  };
}

