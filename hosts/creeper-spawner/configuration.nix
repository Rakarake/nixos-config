{ pkgs, lib, ... }:

let 
  # Open TCP/UDP ports
  ports = {
    ssh              = 22;
    minecraft        = 25565;
    http             = 80;
    https            = 443;
    #onlyoffice       = 8000;
    wireguard        = 51820;
    misc             = 1337;

    minecraft-spruce = 8001;
    prt2             = 8002;
    prt3             = 8003;
    prt4             = 8004;
    prt5             = 8005;
  };

  # Hostnames
  hostnames = {
    website = "rakarake.xyz";
    nextcloud = "nextcloud.rakarake.xyz";
    #onlyoffice = "onlyoffice.rakarake.xyz";
    git = "git.rakarake.xyz";
  };

  # Minecraft server module template
  # Takes name, figures everything out itself, users, location (/var/<name>)
  minecraftServerTemplate = name : description : {
    systemd.services.${name} = {
      enable = true;
      path = [ pkgs.coreutils pkgs.tmux pkgs.jdk17 ];
      wantedBy = [ "multi-user.target" ]; 
      after = [ "network.target" ];
      description = description;
      serviceConfig = {
        User = name;
        ExecStart = "${pkgs.tmux}/bin/tmux -S tmux.socket new-session -d -s ${name} /bin/sh start.sh";
        ExecStop = "${pkgs.tmux}/bin/tmux -S tmux.socket kill-session -t ${name}";
        Type = "forking";
        WorkingDirectory=/var/${name};
      };
    };
    users = {
      groups.${name} = {};
      users.${name} = {
        isSystemUser = true;
        description = "Minecraft server ${name}";
        group = name;
      };
    };
  };
in
{
  imports = [
    ../../modules/global.nix
    ./hardware-configuration.nix
    (minecraftServerTemplate "minecraftserver1" "A stylish minecraft server")
    (minecraftServerTemplate "minecraftserverspruce" "A wooden minecraft server")
  ];

  # Wireguard
  networking.wg-quick.interfaces = {
    wg0 = {
      address = [ "10.0.1.2" ];
      listenPort = ports.wireguard;
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

  # We love IPV4
  services.cloudflared = {
    enable = true;
    tunnels = {
      "creeper-spawner" = {
        default = "http_status:404";
        credentialsFile = "/var/cloudflare-tunnel.json";
        ingress = {
          "rakarake.xyz".service = "http://localhost:80";
          #"nextcloud.rakarake.xyz".service = "http://localhost:80";
          "git.rakarake.xyz".service = "http://localhost:80";
          "ssh.rakarake.xyz".service = "ssh://localhost:22";
        };
      };
    };
  };

  # Linux kernel version
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Hostname
  networking.hostName = "creeper-spawner";

  ## The data cluster
  #fileSystems."/data" = {
  #  device = "/dev/sda4:/dev/nvme0n1";
  #  fsType = "bcachefs";
  #};
  systemd.services.mount-data = {
    description = "Bcachefs data mount";
    script = "/run/current-system/sw/bin/mount -t bcachefs /dev/sda4:/dev/nvme0n1 /data";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
    };
    #serviceConfig = {
    #  ExecStart = "/run/current-system/sw/bin/mount -t bcachefs /dev/sda4:/dev/nvme0n1 /data";
    #  ExecStop = "/run/current-system/sw/bin/umount /var/lib/nextcloud";
    #};
  };
  systemd.services.mount-nextcloud = {
    description = "Nextcloud data mount";
    script = "/run/current-system/sw/bin/mount --bind /data/nextcloud /var/lib/nextcloud";
    after = [ "mount-data.service" ];
    wantedBy = [ "nextcloud-setup.service" ];
    serviceConfig = {
      Type = "oneshot";
    };
    #serviceConfig = {
    #  ExecStart = "/run/current-system/sw/bin/mount --bind /data/nextcloud /var/lib/nextcloud";
    #  ExecStop = "/run/current-system/sw/bin/umount /var/lib/nextcloud";
    #};
  };

  ## Nextcloud mount point
  #fileSystems."/var/lib/nextcloud" = {
  #  device = "/data/nextcloud";
  #  options = [ "bind" ];
  #};
  ## Gitlab mount point
  #fileSystems."/var/gitlab" = {
  #  device = "/data/gitlab";
  #  options = [ "bind" ];
  #};

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
    htop
    btop
    tmux
    jdk17
    bcachefs-tools
    neofetch
    cloudflared
    ffmpeg
  ];

  # Fonts
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
    nerdfonts
    corefonts  # Microsoft fonts
  ];

  # SSH daemon
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    ports = [ ports.ssh ];
  };

  # Nginx Config
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts = {
      # Nextcloud
      ${hostnames.nextcloud} = {
        forceSSL = true;
        enableACME = true;  # Let's encrypt TLS automated, not certbot
      };

      ## Onlyoffice
      #${hostnames.onlyoffice} = {
      #  #forceSSL = true;
      #  #enableACME = true;
      #};
      
      ## Gitlab
      #${hostnames.git} = {
      #  #forceSSL = true;
      #  #enableACME = true;
      #  locations."/".proxyPass = "http://unix:/run/gitlab/gitlab-workhorse.socket";
      #};

      # Homepage
      ${hostnames.website} = {
        #forceSSL = true;
        #enableACME = true;
        root = "/var/www/${hostnames.website}/public";
      };
    };
  };

  # Let's Encrypt
  security.acme = {
    acceptTerms = true;
    defaults.email = "rak@rakarake.xyz";
  };

  # Nextcloud at "/var/lib/nextcloud"
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud28;
    hostName = hostnames.nextcloud;
    database.createLocally = true;
    autoUpdateApps.enable = true;
    config = {
      dbtype = "pgsql";
      adminpassFile = "/etc/nextcloud-admin-pass";
    };
    # HTTPS only
    https = true;
    # Extra caching
    configureRedis = true;
    # Mail server for atuomatic "registration emails"
    extraOptions = {
      mail_smtpmode = "sendmail";
      mail_sendmailmode = "pipe";
    };
    # Bigger cache, nextcloud admin page complains without this
    phpOptions."opcache.interned_strings_buffer" = "23";
  };

  ## Onlyoffice
  #services.onlyoffice = {
  #  enable = true;
  #  hostname = hostnames.onlyoffice;
  #  port = 8000;
  #};

  ## Gitlab
  #services.gitlab = {
  #  enable = true;
  #  https = true;
  #  # Https port when copying link for repo
  #  port = 443;
  #  host = hostnames.git;
  #  initialRootPasswordFile = /data/secrets/rootPassword;
  #  secrets = {
  #    secretFile = /data/secrets/secret;
  #    otpFile = /data/secrets/optsecret;
  #    dbFile = /data/secrets/dbsecret;
  #    jwsFile = pkgs.runCommand "oidcKeyBase" {} "${pkgs.openssl}/bin/openssl genrsa 2048 > $out";
  #  };
  #};
  #systemd.services.gitlab-backup.environment.BACKUP = "dump";

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable networking
  networking.networkmanager.enable = true;

  ## Set your time zone
  #time.timeZone = "Europe/Stockholm";
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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    motd = "Welcome, beware of hungry hippos 🦛";
    users.rakarake = {
      isNormalUser = true;
      description = "Rakarake";
      extraGroups = [ "networkmanager" "wheel" "nextcloud" ];
      openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDswNWTldzMxDmGVMmftP1veTWsWqYehiSglmUktQa4JRkWbzHh20nF90l69T7gYgq551KYsgB83Kdexe+j5GARzeaJB3700mUKHHoBW80RwVQKZuj5HEqy2cvaEGywx84WS9uJDs09wmFABM0FBRjeEHfvHQsE6elB0zVDsCogSBl4T+bW9sxzrMZpXsjmdJ//9QE1mLaZlYLBLwc79iAZFL4ZeWqGFl/gHyA+lLOvgmrtJMBeIMw3CZI8LNLtbTK0PILzSzTOnfFtx3L72wgqUm49P1taFC9WncPy0TN9fJoXV9WjRlrwvJNWycRnMJNmVg4f4gSCYEI1lcspN04ahZH+nOTFhl2dQrw5x2QWCMfATNQPzBYvuFr/UyaaNFpUFp4QD9lccokB8rq99ls97EtZ1w4RitGvc8GGcZ8qy8iIcijT4JRZxxYAH8ebSwykXZCdTSD21uMebyRnScZf/xHaGV6MH7NIeRH7YlaWI+kpWbd7SqHtDbtecPHqAeE= Williams GPG Key"

"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDZYtvc+W667rSI3JidOFL96UgEyqcGXHtg1B84ovKaAJVRDgT5M0VJFEQ2L2a2PeEirBYktlHiQxqevMWvQvvJh+WAB9RiIQlAez65i0hMuJcLwo/JpEGRX0QT4gaej+DjUEO/0Z8+Q6sYN/Bwgs/IaJKD2oHCKe95qQC7nhfpGbpqsLPRAmlOaqms4sqUFhVeQlirltcv2hzJ2cMHwIpI40j+n/MbKQ3iJUOicjHqiZMgTXzHoq1RuG3RtYQ2O7RSmJbthca2PD7XlmPq07dXc49yPomeXxvTt2JUsvgry4X8OvKwXcGU2E1XJ0MCDphQaAJuCKqeygAuXGowpfTKjmw3neHn124iGozGmKgbR8uU3TrEpa3P0HLfDkWKdSGv50GApIVa2fhnqwt4nvVpEm/MqCD35y22b/j+KwypPKDq1BZPuIQGmPYuQwuoH9UaHH13uJxtv8JoKm2l359Qrs8v+fjeBh9kNoKSVG0CJBShIW2odRZDpXS2Ds1zUX8= rakarake@rakarake-pc"
      ];
    };
  };

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "23.05";
}

