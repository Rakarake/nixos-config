# Laptop
{ inputs, self, ... }: {
  flake.nixosConfigurations.thinky = inputs.nixpkgs-unstable.lib.nixosSystem {
    modules = [
      self.nixosModules.global
      self.nixosModules.desktop
      self.nixosModules.thinky
      self.nixosModules.thinky-hardware
      #self.nixosModules.kde
      #self.nixosModules.cosmic
      self.nixosModules.hyprland
    ];
  };
  flake.homeConfigurations."rakarake@thinky" = let
    pkgs = import inputs.nixpkgs-unstable { system = "x86_64-linux"; config.allowUnfree = true; };
   in inputs.home-manager-unstable.lib.homeManagerConfiguration {
     modules = [
       self.homeModules.global
       self.homeModules.desktop
       self.homeModules.styling
       self.homeModules.hyprland
       #self.homeModules.cosmic
       #self.homeModules.kde
       ({ lib, ... }: {
         home.stateVersion = "23.05";
         home.username = "rakarake";
         home.homeDirectory = "/home/rakarake";
         wayland.windowManager.hyprland.extraConfig = lib.mkAfter ''
           for i = 1, 10 do
             local key = i % 10 -- 10 maps to key 0
             hl.workspace_rule({ workspace = tostring(i), default_name = tostring(i), monitor = "eDP-1", persistent = true })
           end
         '';
       })
     ];
     inherit pkgs;
  };
  flake.nixosModules.thinky = { pkgs, ... }: {
    networking.hostName = "thinky";

    # Droidcam
    programs.droidcam.enable = true;

    # Enable SSD trimming
    services.fstrim = {
      enable = true;
      interval = "weekly"; # the default
    };

    # Needed for network discovery
    services.avahi.enable = true;
    services.avahi.publish.enable = true;
    services.avahi.publish.userServices = true;

    # Bootloader
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
  };

  flake.nixosModules.thinky-hardware = { config, lib, pkgs, modulesPath, ... }: {
		imports =
  	  [ (modulesPath + "/installer/scan/not-detected.nix")
  	  ];

  	boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  	boot.initrd.kernelModules = [ ];
  	boot.kernelModules = [ "kvm-intel" ];
  	boot.extraModulePackages = [ ];

  	fileSystems."/" =
  	  { device = "/dev/disk/by-uuid/87c54921-74ff-4cc0-b6bf-5d3d54ee019a";
  	    fsType = "ext4";
  	  };

  	boot.initrd.luks.devices."luks-e5548f74-4408-47a3-a3a7-eb251eb44ebe" = {
  	  device = "/dev/disk/by-uuid/e5548f74-4408-47a3-a3a7-eb251eb44ebe";
  	  allowDiscards = true;
  	};

  	fileSystems."/boot" =
  	  { device = "/dev/disk/by-uuid/3E9C-BFD7";
  	    fsType = "vfat";
  	  };

  	swapDevices =
  	  [ { device = "/dev/sda3"; }
  	  ];

  	# Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  	# (the default) this is the recommended approach. When using systemd-networkd it's
  	# still possible to use this option, but it's recommended to use it in conjunction
  	# with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  	networking.useDHCP = lib.mkDefault true;
  	# networking.interfaces.enp0s31f6.useDHCP = lib.mkDefault true;
  	# networking.interfaces.wlp4s0.useDHCP = lib.mkDefault true;

  	nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  	powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  	hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
	};
}
