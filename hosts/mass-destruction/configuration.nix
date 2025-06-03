{ config, pkgs, lib, ssh-keys, ... }:

let 
  # Open TCP/UDP ports
  ports = {
    ssh              =  8022;
    ssh1             =    22;
    wireguard        = 51820;
    minecraft        =  8069;
    openttd          =  3979;
    federation       =  8448;
    synapse          =  8008;
    http             =    80;
    https            =   443;
  };

  # Minecraft server module template
  # Takes name, figures everything out itself, users, location (/var/<name>)
  minecraftServerTemplate = name : description : java-package : {
    systemd.services.${name} = {
      enable = true;
      path = [ pkgs.coreutils pkgs.tmux pkgs.bash pkgs.ncurses java-package ];
      wantedBy = [ "multi-user.target" ]; 
      after = [ "network.target" ];
      description = description;
      serviceConfig = {
        User = name;
        ExecStart = "${pkgs.tmux}/bin/tmux -S tmux.socket new-session -d -s ${name} /bin/sh start.sh";
        ExecStop = "${pkgs.tmux}/bin/tmux -S tmux.socket kill-session -t ${name}";
        Type = "forking";
        Restart = "on-failure";
        WorkingDirectory=/data/MCservers/${name};
      };
    };
    users = {
      groups.${name} = {};
      users.${name} = {
        isSystemUser = true;
        description = "Minekraft server ${name}";
        group = name;
      };
    };
  };

  # OpenTTD server module template
  # Takes name, figures everything out itself, users, location (/var/<name>)
  openttdServerTemplate = name : description : {
    systemd.services.${name} = {
      enable = true;
      path = [ pkgs.coreutils pkgs.tmux pkgs.bash pkgs.ncurses pkgs.openttd];
      wantedBy = [ "multi-user.target" ]; 
      after = [ "network.target" ];
      description = description;
      serviceConfig = {
        User = name;
        ExecStart = "${pkgs.tmux}/bin/tmux -S tmux.socket new-session -d -s ${name} openttd -D";
        ExecStop = "${pkgs.tmux}/bin/tmux -S tmux.socket kill-session -t ${name}";
        Type = "forking";
        WorkingDirectory=/data/OpenTTDservers/${name};
      };
    };
    users = {
      groups.${name} = {};
      users.${name} = {
        isSystemUser = true;
        description = "OpenTTD server ${name}";
        group = name;
      };
    };
  };

in
{
  imports = [
    ./hardware-configuration.nix
    (minecraftServerTemplate "minecraftserver-kreate" "A not so kreative minekraft server" pkgs.jdk17)
    (openttdServerTemplate "openTTDserver-massdestruction" "transporting destruction since 2024")
  ];

  cfg-global.enable = true;

  # Linux kernel version
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Engage the msr crypto moment
  boot.kernelModules = [ "msr" ];

  # Hostname
  networking.hostName = "mass-destruction";

  # Disk mounting wow
  fileSystems."/data" =
    { device = "/dev/sda";
      fsType = "bcachefs";
    };

  # Open ports
  networking.firewall.allowedTCPPorts = lib.attrsets.attrValues ports;
  networking.firewall.allowedUDPPorts = lib.attrsets.attrValues ports;

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
    jdk17
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
    ports = [ ports.ssh ports.ssh1];
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

  # Conduit
  #services.matrix-conduit = {
  #  enable = true;
   # settings.global = {
     # server_name = "127.0.0.1";
    #  databse_backend = "sqlite";
   #   port = 8448;
  #    address = "0.0.0.0";
 #     registation_token = "gabagool";
#      allow_registration = true;
#    };
#  };

  # Synapse
  services.postgresql.enable = true;
  services.postgresql.initialScript = pkgs.writeText "synapse-init.sql" ''
    CREATE ROLE "matrix-synapse" WITH LOGIN PASSWORD 'synapse';
    CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse"
      TEMPLATE template0
      LC_COLLATE = "C"
      LC_CTYPE = "C";
  '';

  services.matrix-synapse = {
    enable = true;
    settings = {
      server_name = "chat.mdf.farm";
      registration_shared_secret_path = config.age.secrets.monero-rpc-login.path;
      listeners = [
        {
          port = ports.synapse;
          bind_addresses = [ "::1" ];
          type = "http";
          tls = false;
          x_forwarded = true;
          resources = [
            {
              names = [ "client" "federation" ];
              compress = false;
            }
          ];
        }
      ];
    };
  };

  # not synapse lol
  age.secrets.matrix-synapse-secret-config = {
    file = ../../secrets/hotfreddy.age;
    owner = "matrix-synapse";
    group = "matrix-synapse";
  };

  # Let's Encrypt
  security.acme = {
    acceptTerms = true;
    defaults.email = "scolipede2@hotmail.com";
  };

  # Proxy, enable https etc
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts = {
      # Nextcloud
      "chat.mdf.farm" = {
        forceSSL = true;
        enableACME = true;  # Let's encrypt TLS automated, not certbot
        locations."/" = {
          proxyWebsockets = true;
          proxyPass = "http://localhost:${toString ports.synapse}";
        };
      };
    };
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
      extraGroups = [ "networkmanager" "wheel" "nextcloud" ];
      openssh.authorizedKeys.keys = ssh-keys.magarnicle;
    };
    users.rakarake = {
      isNormalUser = true;
      description = "Rakarake";
      extraGroups = [ "networkmanager" "wheel" "nextcloud" ];
      openssh.authorizedKeys.keys = ssh-keys.rakarake;
    };
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

