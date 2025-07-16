{ config, pkgs, lib, ssh-keys, ... }:

let 
  # Open TCP/UDP ports
  ports = {
    ssh              =  8022;
    ssh1             =    22;
    wireguard        = 51820;
    minecraft        =  8069;
    goblainkraft     = 25565;
    openttd          =  3979;
    federation       =  8448;
    synapse          =  8008;
    http             =    80;
    https            =   443;
    coturn           =  3478;
    coturn2          =  5349;
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
    (minecraftServerTemplate "minecraftserver-kreate" "A not so kreative minekraft server" pkgs.jdk21)
    (minecraftServerTemplate "minecraftserver-goblainkraft" "Sin Bucket in Minecraft" pkgs.jdk21)
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
    settings = with config.services.coturn; {
      server_name = "chat.mdf.farm";
      serve_server_wellknown = true;
      registration_shared_secret_path = config.age.secrets.hotfreddy.path;

      turn_uris = ["turn:${realm}:3478?transport=udp" "turn:${realm}:3478?transport=tcp"];
      turn_shared_secret_path = config.age.secrets.freakyfoxy.path;
      turn_user_lifetime = "1h";

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

  services.coturn = rec {
    enable = true;
    no-cli = true;
    no-tcp-relay = true;
    min-port = 49000;
    max-port = 50000;
    use-auth-secret = true;
    static-auth-secret-file = config.age.secrets.freakyfoxy.path;
    realm = "voip.mdf.farm";
    cert = "${config.security.acme.certs.${realm}.directory}/full.pem";
    pkey = "${config.security.acme.certs.${realm}.directory}/key.pem";
    extraConfig = ''
      # for debugging
      verbose
      # ban private IP ranges
      no-multicast-peers
      denied-peer-ip=0.0.0.0-0.255.255.255
      denied-peer-ip=10.0.0.0-10.255.255.255
      denied-peer-ip=100.64.0.0-100.127.255.255
      denied-peer-ip=127.0.0.0-127.255.255.255
      denied-peer-ip=169.254.0.0-169.254.255.255
      denied-peer-ip=172.16.0.0-172.31.255.255
      denied-peer-ip=192.0.0.0-192.0.0.255
      denied-peer-ip=192.0.2.0-192.0.2.255
      denied-peer-ip=192.88.99.0-192.88.99.255
      denied-peer-ip=192.168.0.0-192.168.255.255
      denied-peer-ip=198.18.0.0-198.19.255.255
      denied-peer-ip=198.51.100.0-198.51.100.255
      denied-peer-ip=203.0.113.0-203.0.113.255
      denied-peer-ip=240.0.0.0-255.255.255.255
      denied-peer-ip=::1
      denied-peer-ip=64:ff9b::-64:ff9b::ffff:ffff
      denied-peer-ip=::ffff:0.0.0.0-::ffff:255.255.255.255
      denied-peer-ip=100::-100::ffff:ffff:ffff:ffff
      denied-peer-ip=2001::-2001:1ff:ffff:ffff:ffff:ffff:ffff:ffff
      denied-peer-ip=2002::-2002:ffff:ffff:ffff:ffff:ffff:ffff:ffff
      denied-peer-ip=fc00::-fdff:ffff:ffff:ffff:ffff:ffff:ffff:ffff
      denied-peer-ip=fe80::-febf:ffff:ffff:ffff:ffff:ffff:ffff:ffff
    '';
  };
  # open the firewall TODO merge with other firewall settings
  networking.firewall = {
    interfaces.enp4s0 = let
      range = with config.services.coturn; lib.singleton {
        from = min-port;
        to = max-port;
      };
    in
    {
      allowedUDPPortRanges = range;
      allowedUDPPorts = lib.attrsets.attrValues ports;
      allowedTCPPortRanges = [ ];
      allowedTCPPorts = lib.attrsets.attrValues ports;
    };
  };

  security.acme.certs = {
    "voip.mdf.farm" = {
      group = "turnserver";
      postRun = "systemctl reload nginx.service; systemctl restart coturn.service";
    };
  };

  # not synapse lol
  age.identityPaths = [ "/home/rakarake/.ssh/id_ed25519" "/home/magarnicle/.ssh/id_ed25519" ]; 
  age.secrets.hotfreddy = {
    file = ../../secrets/hotfreddy.age;
    owner = "matrix-synapse";
    group = "matrix-synapse";
  };
  age.secrets.freakyfoxy = {
    file = ../../secrets/freakyfoxy.age;
    mode = "770";
    owner = "turnserver";
    group = "turnserver";
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
      # Coturn
      "voip.mdf.farm" = {
        forceSSL = true;
        enableACME = true;  # Let's encrypt TLS automated, not certbot
        #locations."/".root = "/var/www/test";
        #locations."/" = {
        #  proxyWebsockets = true;
        #  proxyPass = "http://localhost";
        #};
      };
      # Matrix
      "chat.mdf.farm" = {
        forceSSL = true;
        enableACME = true;  # Let's encrypt TLS automated, not certbot
        locations."/" = {
          proxyWebsockets = true;
          proxyPass = "http://localhost:${toString ports.synapse}";
        };
      };
      # Element, matrix frontend
      "element.mdf.farm" = {
        forceSSL = true;
        enableACME = true;  # Let's encrypt TLS automated, not certbot
        locations."/" = {
          root = pkgs.element-web;
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

