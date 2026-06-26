# Desktop PC
{ inputs, self, ... }: {
  flake.nixosConfigurations.cobblestone-generator = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.global
      self.nixosModules.desktop
      self.nixosModules.cobblestone-generator
      self.nixosModules.cobblestone-generator-hardware
      #self.nixosModules.wlroots
      self.nixosModules.kde
      inputs.eden.nixosModules.default
    ];
  };
  flake.homeConfigurations."rakarake@cobblestone-generator" =
  let
    mainMonitor = "DP-1";
    leftMonitor = "DP-2";
    monitorSetup = ''
      # Monitor setup
      wlr-randr --output ${mainMonitor} --mode 1920x1080@144.001007 --pos 3840,0
      wlr-randr --output ${leftMonitor} --mode 1920x1080@143.854996 --pos 0,0
    '';
    monitor-setup = pkgs.writeShellScriptBin "monitor-setup" monitorSetup;
    extraConfig = ''
      ${monitor-setup}/bin/monitor-setup &

      # Monitor screenshots
      riverctl map normal Super R       spawn "grim -o ${leftMonitor} - | wl-copy"
      riverctl map normal Super+Shift R spawn "grim -o ${leftMonitor}"
      riverctl map normal Super T       spawn "grim -o ${mainMonitor} - | wl-copy"
      riverctl map normal Super+Shift T spawn "grim -o ${mainMonitor}"

      # Default app locations
      riverctl rule-add -app-id com.github.wwmm.easyeffects output ${leftMonitor}
      riverctl rule-add -app-id discord output ${leftMonitor}
      #riverctl rule-add -app-id librewolf output ${mainMonitor}
      #riverctl rule-add -app-id firefox output ${mainMonitor}
      riverctl focus-output ${mainMonitor}

      # Local AI slopbot
      #OLLAMA_KEEP_ALIVE=5m ollama serve &
    '';
    pkgs = import inputs.nixpkgs { system = "x86_64-linux"; config.allowUnfree = true; };
   in
    inputs.home-manager.lib.homeManagerConfiguration {
     modules = [
       self.homeModules.global
       self.homeModules.desktop
       self.homeModules.styling
       #self.homeModules.river
       ({ lib, ... }: {
         home.stateVersion = "23.05";
         home.username = "rakarake";
         home.homeDirectory = "/home/rakarake";
         #wayland.windowManager.river.extraConfig = lib.mkAfter extraConfig;
       })
     ];
     inherit pkgs;
  };
  flake.nixosModules.cobblestone-generator = { pkgs, ... }: let
    #pkgs-unstable = import inputs.nixpkgs-unstable { system = pkgs.stdenv.hostPlatform.system; config.allowUnfree = true; };
  in {
    networking.hostName = "cobblestone-generator";

    programs.eden = {
      enable = true;
    };

    # Linux kernel package
    boot.kernelPackages = pkgs.linuxPackages_latest;

    # Droidcam
    programs.droidcam.enable = true;

    # Lact GPU
    services.lact.enable = true;

    # Enable SSD trimming
    services.fstrim = {
      enable = true;
      interval = "weekly"; # the default
    };

    # Monero mining
    boot.kernelModules = [ "msr" ];

    # Wireguard
    networking.firewall.allowedTCPPorts = [ 51820 ];
    networking.firewall.allowedUDPPorts = [ 51820 ];
    networking.wg-quick.interfaces = {
      wg0 = {
        address = [ "10.0.1.4" ];
        listenPort = 51820;
        privateKeyFile = "/var/wireguard/private";
        peers = [
          {
            publicKey = "51IbR93F5mYmGz+GKG1GNgXtOsbMqkDbUkTArDTxOQo=";
            allowedIPs = [ "10.0.1.1" ];
            endpoint = "172.232.146.169:51820";
            persistentKeepalive = 25;
          }
        ];
      };
    };

    # Needed for network discovery
    services.avahi.enable = true;
    services.avahi.publish.enable = true;
    services.avahi.publish.userServices = true;

    # ssh into desktop
    #services.openssh = {
    #  enable = true;
    #  settings.PasswordAuthentication = false;
    #  settings.KbdInteractiveAuthentication = false;
    #  ports = [ 22 ];
    #};
    #users.users.rakarake.openssh.authorizedKeys.keys = ssh-keys.rakarake;

    # Desktop specific packages
    environment.systemPackages = with pkgs; [
      lact  # GPU monitor/overclocking
      gpu-screen-recorder-gtk
      #pkgs-unstable.ollama-rocm
    ];
    programs.gpu-screen-recorder.enable = true;

    # Guest User
    users.users.guest = {
      isNormalUser = true;
      description = "Guest";
      extraGroups = [ "networkmanager" ];
    };

    # Bootloader
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
  };

  flake.nixosModules.cobblestone-generator-hardware = { config, lib, pkgs, modulesPath, ... }: {
    imports =
      [ (modulesPath + "/installer/scan/not-detected.nix")
      ];

    boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "sd_mod" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-amd" ];
    boot.extraModulePackages = [ ];

    fileSystems."/" =
      { device = "/dev/disk/by-uuid/711bb22c-5061-4810-bb69-4827a49e3729";
        fsType = "ext4";
      };

    fileSystems."/boot" =
      { device = "/dev/disk/by-uuid/82AF-2BF1";
        fsType = "vfat";
        options = [ "fmask=0022" "dmask=0022" ];
      };

    swapDevices =
      [ { device = "/dev/disk/by-uuid/a270be17-3c61-4f76-8880-b79c1bffcff1"; }
      ];

    # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
    # (the default) this is the recommended approach. When using systemd-networkd it's
    # still possible to use this option, but it's recommended to use it in conjunction
    # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
    networking.useDHCP = lib.mkDefault true;
    # networking.interfaces.enp3s0.useDHCP = lib.mkDefault true;
    # networking.interfaces.vboxnet0.useDHCP = lib.mkDefault true;
    # networking.interfaces.wg0.useDHCP = lib.mkDefault true;
    # networking.interfaces.wlp7s0.useDHCP = lib.mkDefault true;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
