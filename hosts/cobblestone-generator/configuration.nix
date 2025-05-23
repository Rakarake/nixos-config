# Desktop PC
{ pkgs, ssh-keys, ... }: {
  imports = [ ./hardware-configuration.nix ];

  cfg-global.enable = true;
  cfg-desktop.enable = true;
  #cfg-hyprland.enable = true;
  #cfg-gnome.enable = true;
  #services.xserver.displayManager.gdm.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    #theme = "catppuccin-sddm-corners";
  };
  #services.greetd = {
  #  enable = true;
  #  settings = {
  #    default_session = {
  #      command = "${pkgs.greetd.tuigreet}/bin/tuigreet";
  #    };
  #  };
  #};
  cfg-wlroots.enable = true;
  cfg-river.enable = true;
  #xdg.portal.wlr.settings.screencast = {
  #  output_name = "DP-1";
  #  max_fps = 30;
  #  chooser_type = "simple";
  #  chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
  #};

  # Linux kernel package
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Enable SSD trimming
  services.fstrim = {
    enable = true;
    interval = "weekly"; # the default
  };

  # Monero mining
  boot.kernelModules = [ "msr" ];

  ## OpenCL
  #hardware.graphics.extraPackages = with pkgs; [
  #  rocmPackages.clr.icd
  #];

  # Hostname
  networking.hostName = "cobblestone-generator";  # Define your hostname.

  ## Wake on LAN, ty Breadly
  #networking.interfaces.enp4s0.wakeOnLan = {
  #  enable = true;
  #  policy = [ "magic" ];
  #};
  #systemd.services.wakeonlan = {
  #  description = "Reenable wake on lan every boot";
  #  after = [ "network.target" ];
  #  serviceConfig = {
  #    Type = "simple";
  #    RemainAfterExit = "true";
  #    ExecStart = "${pkgs.ethtool}/sbin/ethtool -s enp4s0 wol g";
  #  };
  #  wantedBy = [ "default.target" ];
  #};

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

  # Sunshine, remote gaming
  #services.udev.packages = [ pkgs.sunshine ]; # allow access to create virtual input interfaces.
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
  #security.wrappers.sunshine = {
  #  owner = "root";
  #  group = "root";
  #  capabilities = "cap_sys_admin+p";
  #  source = "${pkgs.sunshine}/bin/sunshine";
  #};
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
  users.users.rakarake.openssh.authorizedKeys.keys = ssh-keys.rakarake;

  # Desktop specific packages
  environment.systemPackages = with pkgs; [
    corectrl  # We like big graphics

    # SDDM theme
    #catppuccin-sddm-corners

    #sunshine

    # Monero mining
    p2pool
    xmrig
  ];

  # Enable Plymouth
  boot.plymouth = {
    enable = true;
    logo = ./kirb.png;
  };
  boot.initrd.systemd.enable = true;

  # Guest User
  users.users.guest = {
    isNormalUser = true;
    description = "Guest";
    extraGroups = [ "networkmanager" ];
  };
}

