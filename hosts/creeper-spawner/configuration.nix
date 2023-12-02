{ pkgs, lib, ... }:

let 
  # Open TCP/UDP ports
  ports = {
    ssh        = 222;
    minecraft  = 25565;
    http       = 80;
    https      = 443;
    onlyoffice = 8000;
  };

  # Hostnames
  hostnames = {
    website = "rakarake.xyz";
    nextcloud = "nextcloud.rakarake.xyz";
    onlyoffice = "onlyoffice.rakarake.xyz";
  };
in

{
  imports = [ ./hardware-configuration.nix ];

  # Hostname
  networking.hostName = "creeper-spawner";

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
    ports = [ 222 ];
  };
  users.users."rakarake".openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDswNWTldzMxDmGVMmftP1veTWsWqYehiSglmUktQa4JRkWbzHh20nF90l69T7gYgq551KYsgB83Kdexe+j5GARzeaJB3700mUKHHoBW80RwVQKZuj5HEqy2cvaEGywx84WS9uJDs09wmFABM0FBRjeEHfvHQsE6elB0zVDsCogSBl4T+bW9sxzrMZpXsjmdJ//9QE1mLaZlYLBLwc79iAZFL4ZeWqGFl/gHyA+lLOvgmrtJMBeIMw3CZI8LNLtbTK0PILzSzTOnfFtx3L72wgqUm49P1taFC9WncPy0TN9fJoXV9WjRlrwvJNWycRnMJNmVg4f4gSCYEI1lcspN04ahZH+nOTFhl2dQrw5x2QWCMfATNQPzBYvuFr/UyaaNFpUFp4QD9lccokB8rq99ls97EtZ1w4RitGvc8GGcZ8qy8iIcijT4JRZxxYAH8ebSwykXZCdTSD21uMebyRnScZf/xHaGV6MH7NIeRH7YlaWI+kpWbd7SqHtDbtecPHqAeE= Williams GPG Key"
  ];

  # Nginx Config
  services.nginx.virtualHosts = {
    # Nextcloud
    ${hostnames.nextcloud} = {
      forceSSL = true;
      enableACME = true;  # Let's encrypt TLS automated, not certbot
    };

    # Onlyoffice
    ${hostnames.onlyoffice} = {
      forceSSL = true;
      enableACME = true;
    };

    # Homepage
    ${hostnames.website} = {
      forceSSL = true;
      enableACME = true;
      root = "/var/www/${hostnames.website}/public";
    };
  };

  # Let's Encrypt
  security.acme = {
    acceptTerms = true;
    defaults.email = "rak@rakarake.xyz";
  };

  # Nextcloud
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud27;
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
  };

  # Onlyoffice
  services.onlyoffice = {
    enable = true;
    hostname = hostnames.onlyoffice;
    port = 8000;
  };

  ## Minecraft server 1
  #systemd.services.minecraft-server1 = {
  #  enable = true;
  #  path = [ pkgs.coreutils pkgs.jdk17 ];
  #  wantedBy = [ "multi-user.target" ]; 
  #  after = [ "network.target" ];
  #  description = "Cool minecraft server";
  #  serviceConfig = {
  #    ExecStart = "${pkgs.tmux}/bin/tmux -S /var/minecraft-server1/tmux.socket new-session -s minecraft-server1-session -d /var/minecraft-server1/startserver.sh";
  #    ExecStop = "${pkgs.tmux}/bin/tmux -S /var/minecraft-server1/tmux.socket kill-session -t minecraft-server1-session";
  #    Type = "forking";
  #    WorkingDirectory=/var/minecraft-server1;
  #  };
  #};

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

  # TODO lookie here
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.rakarake = {
    isNormalUser = true;
    description = "Rakarake";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "23.05";
}

