{
  config,
  pkgs,
  lib,
  ssh-keys,
  outputs,
  ...
}:

let

  localPorts = {
    synapse = 8008;
  };
  # Open TCP/UDP ports
  ports = {
    ssh = 8022;
    ssh1 = 22;
    wireguard = 51820;
    minecraft = 8069;
    goblainkraft = 42068;
    hardkraft = 8070;
    openttd = 3979;
    vintagecraft = 42420;
    federation = 8448;
    http = 80;
    https = 443;
    coturn = 3478;
    coturn2 = 5349;
    xmage = 17171;
  };

in
{
  imports = [
    ./hardware-configuration.nix
    ./matrix.nix

    (outputs.extra.statefulServerTemplate rec {
      name = "minecraftserver-kreate";
      description = "A not so kreative minekraft server";
      packages = [ pkgs.jdk21 ];
      path = /data/MCservers/${name};
    })
    (outputs.extra.statefulServerTemplate rec {
      name = "minecraftserver-goblainkraft";
      description = "Sin Bucket in Minecraft";
      packages = [ pkgs.jdk21 ];
      path = /data/MCservers/${name};
    })
    (outputs.extra.statefulServerTemplate rec {
      name = "minecraftserver-hardkraft";
      description = "Hard ASF certified gamer mode";
      packages = [ pkgs.jdk21 ];
      path = /data/MCservers/${name};
    })
    (outputs.extra.statefulServerTemplate rec {
      name = "openTTDserver-massdestruction";
      description = "transporting destruction since 2024";
      packages = [ ];
      path = /data/OpenTTDservers/${name};
    })
    (outputs.extra.statefulServerTemplate rec {
      name = "vintagestoryserver";
      description = "amazingular";
      packages = [ pkgs.dotnet-runtime_8 ];
      path = /data/VintageStoryServers/${name};
    })
    (outputs.extra.statefulServerTemplate rec {
      name = "MDFMTG-server";
      description = "Shadow Wizard Monke Gang";
      packages = [ pkgs.jdk21 ];
      path = /data/XMageServers/${name};
    })
  ];

  # open the firewall TODO merge with other firewall settings

  #networking.firewall.allowedTCPPorts = lib.attrsets.attrValues (publicPorts // publicPrivatePorts);
  #networking.firewall.allowedUDPPorts = lib.attrsets.attrValues (publicPorts // publicPrivatePorts);

  networking.firewall =
      let
        range =
          with config.services.coturn;
          lib.singleton {
            from = min-port;
            to = max-port;
          };
      in
      {
        allowedUDPPortRanges = range;
        allowedUDPPorts = lib.attrsets.attrValues ports;
        #allowedTCPPortRanges = [ ];
        allowedTCPPorts = lib.attrsets.attrValues ports;
      };

  nixpkgs.config.permittedInsecurePackages = [
    #"dotnet-runtime-7.0.20"
  ];

  # Linux kernel version
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Engage the msr crypto moment
  boot.kernelModules = [ "msr" ];

  # Disk mounting wow
    fileSystems."/data" = {
    device = "/dev/disk/by-uuid/c7af4442-bf3a-4e97-bca8-b4da01271da8";
    fsType = "btrfs";
    options = ["nofail"];
  };

  # Utility programs
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    unzip
    zip
    tree
    btop
    tmux
    jdk21
    jdk8
    bcachefs-tools
    fastfetch
    ffmpeg
    waypipe
    openttd
    matrix-synapse
  ];

  # SSH daemon
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    ports = [
      ports.ssh
      ports.ssh1
    ];
  };

  # Needed for network discovery
  services.avahi.enable = true;
  services.avahi.publish.enable = true;
  services.avahi.publish.userServices = true;

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable networking
  networking.networkmanager.enable = true;

  ## Set your time zone
  time.timeZone = "Europe/Stockholm";
  #services.automatic-timezoned.enable = true;

  # Select internationalisation properties
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "sv_SE.UTF-8";
    LC_IDENTIFICATION = "sv_SE.UTF-8";
    LC_MEASUREMENT = "sv_SE.UTF-8";
    LC_MONETARY = "sv_SE.UTF-8";
    LC_NAME = "sv_SE.UTF-8";
    LC_NUMERIC = "sv_SE.UTF-8";
    LC_PAPER = "sv_SE.UTF-8";
    LC_TELEPHONE = "sv_SE.UTF-8";
    LC_TIME = "sv_SE.UTF-8";
  };

  # Let's Encrypt
  security.acme = {
    acceptTerms = true;
    defaults.email = "scolipede2@hotmail.com";
  };

  # Wireguard
  networking.wg-quick.interfaces = {
    wg0 = {
      address = [ "10.0.1.69" ];
      listenPort = ports.wireguard;
      privateKeyFile = "/var/wireguard/privatekey";
      peers = [
        {
          publicKey = "51IbR93F5mYmGz+GKG1GNgXtOsbMqkDbUkTArDTxOQo=";
          allowedIPs = [ "10.0.1.1" ];
          endpoint = "172.232.146.169:51820";
          persistentKeepalive = 25;
        }
        {
          publicKey = "ziMRmRNAmounHYy+EcO5iy6+CidEJMEW8dswJM1V5g0=";
          allowedIPs = [ "10.0.1.2" ];
          persistentKeepalive = 25;
        }
      ];
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    motd = "The battleground is right here.";
    users.magarnicle = {
      isNormalUser = true;
      description = "Magarnicle";
      extraGroups = [
        "networkmanager"
        "wheel"
        "nextcloud"
        "vintagestoryserver"
      ];
      openssh.authorizedKeys.keys = ssh-keys.magarnicle;
    };
    users.rakarake = {
      isNormalUser = true;
      description = "Rakarake";
      extraGroups = [
        "networkmanager"
        "wheel"
        "nextcloud"
        "vintagestoryserver"
      ];
      openssh.authorizedKeys.keys = ssh-keys.rakarake;
    };
    users.nginx.extraGroups = [ "turnserver" ];
    users.matrix-synapse.extraGroups = [ "turnserver" ];
    # Backup user
    users.backup = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        ''command="${pkgs.rrsync}/bin/rrsync /data/backup/",restrict ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILgq+RAMpi4DsptmWOQXq+y/z1Ejt+63JL4vjY3Nmipi rakarake@creeper-spawner''
      ];
    };
  };

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "23.05";
}
