# Desktop PC
{ pkgs, ... }: {
  imports = [ ../../modules/global.nix ../../modules ./hardware-configuration.nix ];

  # Cool simple Hyprland config
  cfg-desktop.enable = true;
  cfg-hyprland.enable = true;

  # Hostname
  networking.hostName = "cobblestone-generator";  # Define your hostname.

  # Wake on LAN, ty Breadly
  networking.interfaces.enp4s0.wakeOnLan = {
    enable = true;
    policy = [ "magic" ];
  };
  systemd.services.wakeonlan = {
    description = "Reenable wake on lan every boot";
    after = [ "network.target" ];
    serviceConfig = {
      Type = "simple";
      RemainAfterExit = "true";
      ExecStart = "${pkgs.ethtool}/sbin/ethtool -s enp4s0 wol g";
    };
    wantedBy = [ "default.target" ];
  };

  # Sunshine, remote gaming
  services.udev.packages = [ pkgs.sunshine ]; # allow access to create virtual input interfaces.
  #networking.firewall = {
  #  enable = true;
  #  allowedTCPPorts = [ 47984 47989 47990 48010 ];
  #  allowedUDPPortRanges = [
  #    { from = 47998; to = 48000; }
  #    { from = 8000; to = 8010; }
  #  ];
  #};
  # Prevents this error:
  # Fatal: You must run [sudo setcap cap_sys_admin+p $(readlink -f sunshine)] for KMS display capture to work!
  security.wrappers.sunshine = {
    owner = "root";
    group = "root";
    capabilities = "cap_sys_admin+p";
    source = "${pkgs.sunshine}/bin/sunshine";
  };
  # Needed for network discovery
  services.avahi.enable = true;
  services.avahi.publish.enable = true;
  services.avahi.publish.userServices = true;

  # ssh into desktop
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    ports = [ 22 ];
  };
  users.users.rakarake.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDswNWTldzMxDmGVMmftP1veTWsWqYehiSglmUktQa4JRkWbzHh20nF90l69T7gYgq551KYsgB83Kdexe+j5GARzeaJB3700mUKHHoBW80RwVQKZuj5HEqy2cvaEGywx84WS9uJDs09wmFABM0FBRjeEHfvHQsE6elB0zVDsCogSBl4T+bW9sxzrMZpXsjmdJ//9QE1mLaZlYLBLwc79iAZFL4ZeWqGFl/gHyA+lLOvgmrtJMBeIMw3CZI8LNLtbTK0PILzSzTOnfFtx3L72wgqUm49P1taFC9WncPy0TN9fJoXV9WjRlrwvJNWycRnMJNmVg4f4gSCYEI1lcspN04ahZH+nOTFhl2dQrw5x2QWCMfATNQPzBYvuFr/UyaaNFpUFp4QD9lccokB8rq99ls97EtZ1w4RitGvc8GGcZ8qy8iIcijT4JRZxxYAH8ebSwykXZCdTSD21uMebyRnScZf/xHaGV6MH7NIeRH7YlaWI+kpWbd7SqHtDbtecPHqAeE= Williams GPG Key"
"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILgq+RAMpi4DsptmWOQXq+y/z1Ejt+63JL4vjY3Nmipi rakarake@creeper-spawner"
  ];

  # Desktop specific packages
  environment.systemPackages = with pkgs; [
    corectrl  # We like big graphics
    sunshine
  ];

  # Enable Plymouth
  boot.plymouth = {
    enable = true;
    logo = ./kirb.png;
  };
  boot.initrd.systemd.enable = true;

  # Enable hardware acceleration, VA-API
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      libva  # Main package for VA-API
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  # Guest User
  users.users.guest = {
    isNormalUser = true;
    description = "Guest";
    extraGroups = [ "networkmanager" ];
  };

  # Mount music
  fileSystems = {
    "/home/rakarake/MORB" = {
      label = "MORB";
      fsType = "btrfs";
    };
  };
}

