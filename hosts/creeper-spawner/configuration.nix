{ system, inputs, pkgs, lib, ssh-keys, config, ... }:

let 
  # Open TCP/UDP ports
  publicPorts = {
    ssh                = 22;
    http               = 80;
    https              = 443;

    wireguard          = 51820;
    monero             = 18080;
    moneroRpc          = 18081;
    moneroZMQ          = 18083;
    moeroP2Pool        = 37889;
    moeroP2PoolMini    = 37888;

    minecraft          = 25565;
    minecraft-spruce   = 1337;

    prt2               = 8002;
    prt3               = 8003;
    prt4               = 8004;
    prt5               = 8005;
  };

  localPorts = {
    graphana           = 2344;
    prometheus         = 9001;
    prometheusNodePort = 9002;
    jellyfin           = 8096;
    bingbingo          = 8097;
    forgejo            = 8098;
  };


  # Hostnames
  hostnames = {
    website = "rakarake.xyz";
    nextcloud = "nextcloud.rakarake.xyz";
    forgejo = "git.rakarake.xyz";
    grafana = "grafana.rakarake.xyz";
    jellyfin = "jellyfin.rakarake.xyz";
    akkoma = "akk.rakarake.xyz";
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
        RestartOnFailure = "on-failure";
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
    inputs.bingbingo.nixosModules.${system}.default
    (minecraftServerTemplate "minecraftserver1" "A stylish minecraft server" pkgs.jdk21)
    (minecraftServerTemplate "minecraftserverspruce" "A wooden minecraft server" pkgs.jdk17)
  ];

  # Wireguard
  networking.wg-quick.interfaces = {
    wg0 = {
      address = [ "10.0.1.2" ];
      listenPort = publicPorts.wireguard;
      privateKeyFile = "/var/wireguard/private";
      peers = [
        {
          publicKey = "51IbR93F5mYmGz+GKG1GNgXtOsbMqkDbUkTArDTxOQo=";
          allowedIPs = [ "10.0.1.1" ];
          endpoint = "172.232.146.169:51820";
          persistentKeepalive = 25;
        }
        {
          publicKey = "xKZgJ3UiCVnMwiQzbUce00Zn8Dvza31RNce5WngYrF8=";
          allowedIPs = [ "10.0.1.69" ];
          persistentKeepalive = 25;
        }
      ];
    };
  };

  # Linux kernel version
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Hostname
  networking.hostName = "creeper-spawner";

  systemd.services.mount-data = {
    description = "Bcachefs data mount";
    script = "/run/current-system/sw/bin/mount -t bcachefs /dev/sda4:/dev/nvme0n1 /data";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
    };
  };
  systemd.services.mount-nextcloud = {
    description = "Nextcloud data mount";
    script = "/run/current-system/sw/bin/mount --bind /data/nextcloud /var/lib/nextcloud";
    after = [ "mount-data.service" ];
    wantedBy = [ "nextcloud-setup.service" ];
    serviceConfig = {
      Type = "oneshot";
    };
  };
  systemd.services.mount-movies = {
    description = "Mount raka's movies to be accessible by Jellyfin";
    script = "/run/current-system/sw/bin/mount --bind /var/lib/nextcloud/data/Rakarake/files/Movies /var/Movies";
    after = [ "mount-data.service" ];
    wantedBy = [ "nextcloud-setup.service" ];
    serviceConfig = {
      Type = "oneshot";
    };
  };

  # Open ports
  networking.firewall.allowedTCPPorts = lib.attrsets.attrValues publicPorts;
  networking.firewall.allowedUDPPorts = lib.attrsets.attrValues publicPorts;

  # Utility programs
  environment.systemPackages = with pkgs; [
    vim
    neovim
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
    fastfetch
    #cloudflared
    ffmpeg
    waypipe
    rsync
    p2pool
    xmrig
    monero-cli
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
    ubuntu_font_family
  ];

  fonts.fontconfig = {
    defaultFonts = {
      serif = [  "Liberation Serif" ];
      sansSerif = [ "Ubuntu" ];
      monospace = [ "Ubuntu Mono" ];
    };
  };

  # SSH daemon
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    ports = [ publicPorts.ssh ];
  };

  # Graphana
  services.grafana = {
    enable = true;
    #domain = "grafana.rakarake.xyz";
    settings.server = {
      http_port = localPorts.graphana;
      http_addr = "127.0.0.1";
      root_url = "https://rakarake.xyz/grafana";
      serve_from_sub_path = true;
    };
  };

  # Prometheus
  services.prometheus = {
    enable = true;
    port = localPorts.prometheus;
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        port = localPorts.prometheusNodePort;
      };
    };
    scrapeConfigs = [
      {
        job_name = "creeper-gaming";
        static_configs = [{
          targets = [ "127.0.0.1:${toString localPorts.prometheusNodePort}" ];
        }];
      }
    ];
  };

  # Jellyfin
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };
  services.jellyfin = {
    enable = true;
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

      ${hostnames.jellyfin} = {
        forceSSL = true;
        enableACME = true;  # Let's encrypt TLS automated, not certbot
        locations."/" = {
          proxyPass = "http://localhost:${toString localPorts.jellyfin}";
          proxyWebsockets = true;
          recommendedProxySettings = true;
        };
      };

      ${hostnames.forgejo} = {
        forceSSL = true;
        enableACME = true;
        extraConfig = ''
          client_max_body_size 512M;
        '';
        locations."/".proxyPass = "http://localhost:${toString localPorts.forgejo}";
      };

      ${hostnames.akkoma} = {
        forceSSL = true;
        enableACME = true;
        locations."/".proxyPass = "http://unix:/run/akkoma/socket";
      };

      ${hostnames.website} = {
        # When not using cloudflare tunnel
        forceSSL = true;
        enableACME = true;

        # Homepage
        locations."/".root = "/var/www/${hostnames.website}/public";
        # Grafana stats visualizer
        locations."/grafana" = {
          proxyPass = "http://localhost:${toString localPorts.graphana}";
          proxyWebsockets = true;
          recommendedProxySettings = true;
        };
        locations."/bingbingo" = {
          proxyPass = "http://localhost:${toString localPorts.bingbingo}";
          proxyWebsockets = true;
          recommendedProxySettings = true;
        };
      };
    };
  };

  # Let's Encrypt
  security.acme = {
    acceptTerms = true;
    defaults.email = "raka@rakarake.xyz";
  };

  # Nextcloud at "/var/lib/nextcloud"
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud29;
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
    #extraApps = {
    #  inherit (config.services.nextcloud.package.packages.apps) richdocuments;
    #};
  };
  environment.etc.ffmpeg = { source = "${pkgs.ffmpeg}/bin/ffmpeg"; mode = "0555"; };
  environment.etc.ffprobe = { source = "${pkgs.ffmpeg}/bin/ffprobe"; mode = "0555"; };

  # Bingbingo
  services.bingbingo = {
    enable = true;
    port = localPorts.bingbingo;
    subPath = "bingbingo";
  };

  # Forgeo
  services.forgejo = {
    enable = true;
    database.type = "postgres";
    lfs.enable = true;
    stateDir = "/data/forgejo";
    settings = {
      server = {
        DOMAIN = hostnames.forgejo;
        ROOT_URL = "https://${hostnames.forgejo}/"; 
        HTTP_PORT = localPorts.forgejo;
      };
      service.DISABLE_REGISTRATION = true; 
      actions = {
        ENABLED = true;
        DEFAULT_ACTIONS_URL = "github";
      };
    };
  };

  # Monero, p2pool can be run using this node
#monerod --rpc-bind-ip 0.0.0.0 --rpc-bind-port 18081 --confirm-external-bind --rpc-login monero:jxtTUdA4mHUOttW6Dqe7 --data-dir=/data/monero --zmq-pub tcp://0.0.0.0:18083 --out-peers 8 --in-peers 16 --add-priority-node=p2pmd.xmrvsbeast.com:18080 --add-priority-node=nodes.hashvault.pro:18080 --disable-dns-checkpoints --enable-dns-blocklist
  age.identityPaths = [ "/home/rakarake/.ssh/id_ed25519" ]; 
  age.secrets.monero-rpc-login = {
    file = ../../secrets/monero-rpc-login.age;
    owner = "monero";
    group = "monero";
  };

  systemd.services.monero-node = {
    enable = true;
    description = "Monero node 🐖";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      User = "monero";
      ExecStart = "${pkgs.monero-cli}/bin/monerod --non-interactive --config-file ${config.age.secrets.monero-rpc-login.path} --rpc-bind-ip 0.0.0.0 --rpc-bind-port 18081 --confirm-external-bind --data-dir=/data/monero --zmq-pub tcp://0.0.0.0:18083 --out-peers 8 --in-peers 16 --add-priority-node=p2pmd.xmrvsbeast.com:18080 --add-priority-node=nodes.hashvault.pro:18080 --disable-dns-checkpoints --enable-dns-blocklist";
      Restart = "always";
      SuccessExitStatus = [ 0 1 ];
    };
  };
  users.groups.monero = {};
  users.users.monero = {
    isSystemUser = true;
    description = "Monero user";
    group = "monero";
  };

  # Akkoma
  services.akkoma.enable = true;
  services.akkoma.config = {
    ":pleroma" = {
      ":instance" = {
        name = "Freddyverse Central";
        description = "Personal fedi server 🍓";
        email = "raka@rakarake.xyz";
        registration_open = false;
      };
      "Pleroma.Web.Endpoint" = {
        url.host = hostnames.akkoma;
      };
      ":configurable_from_database" = true;
    };
  };

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone
  time.timeZone = "Europe/Stockholm";
  services.automatic-timezoned.enable = true;

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
  users.motd = "Welcome, beware of hungry hippos 🦛";
  users.users.rakarake = {
    isNormalUser = true;
    description = "Rakarake";
    extraGroups = [ "networkmanager" "wheel" "nextcloud" ];
    openssh.authorizedKeys.keys = ssh-keys.rakarake;
  };

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "23.05";
}

