{
  config,
  inputs,
  system,
  pkgs,
  lib,
  ssh-keys,
  outputs,
  ...
}:

let

  localPorts = {
    synapse = 8008;
    llama-cpp = 4785;
  };
  # Open TCP/UDP ports
  ports = {
    ssh = 8022;
    ssh1 = 22;
    wireguard = 51820;
    minecraft = 8069;
    hardkraft = 8070;
    openttd = 3979;
    vintagecraft = 42420;
    federation = 8448;
    http = 80;
    https = 443;
    coturn = 3478;
    coturn2 = 5349;
    xmage = 17171;
    xmage2 = 17172;
    ollama = 11434;
  };

in
{
  imports = [
    ./hardware-configuration.nix
    ./matrix.nix
    #(inputs.mdf-bouncer.nixosModules.${system}.default)

    (outputs.extra.statefulServerTemplate rec {
      name = "minecraftserver-kreate";
      description = "A not so kreative minekraft server";
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
      packages = [ pkgs.jdk8 ];
      path = /data/XMageServers/${name};
    })
  ];

  # open the firewall TODO merge with other firewall settings

  #networking.firewall.allowedTCPPorts = lib.attrsets.attrValues (publicPorts // publicPrivatePorts);
  #networking.firewall.allowedUDPPorts = lib.attrsets.attrValues (publicPorts // publicPrivatePorts);

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

  nixpkgs.config.permittedInsecurePackages = [
    #"dotnet-runtime-7.0.20"
  ];

  # Linux kernel version
  # boot.kernelPackages = pkgs.linuxPackages_latest;

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
    jdk25
    jdk8
    bcachefs-tools
    fastfetch
    ffmpeg
    waypipe
    openttd
    matrix-synapse
    (llama-cpp.override { cudaSupport = true; })
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

  # Nvidia driver stuff
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = true;  # see the note above


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

  services.open-webui.enable = true;

  # Sloppy
  age.secrets.sloppychika = {
    file = ../../secrets/sloppychika.age;
    owner = "llama-cpp";
    group = "llama-cpp";
  };
  systemd.services.llama-cpp = {
    environment = {
      XDG_CACHE_HOME = "/var/cache/llama-cpp";
      MESA_SHADER_CACHE_DIR = "/var/cache/llama-cpp";
    };
    serviceConfig = {
      EnvironmentFile = config.age.secrets.sloppychika.path;
    };
  };
  # For some reason the user/groups are not created by services.llama-cpp.
  users.users.llama-cpp = {
    isSystemUser = true;
    group = "llama-cpp";
  };
  users.groups.llama-cpp = {};
  services.llama-cpp = {
    enable = true;
    package = pkgs.llama-cpp.override { cudaSupport = true; };
    port = localPorts.llama-cpp;
    modelsPreset = {
      "*" = {
        sleep-idle-seconds = 240;
      };
      "Qwen3.8-27B-UD-Q4_K_M" = {
        model = "/var/cache/llama-cpp/Qwen3.8-27B-UD-Q4_K_M.gguf";
        temp = "1.0";
        top-p = "0.95";
        top-k = "20";
        min-p = "0.0";
      };
      #"Qwen3.8-27B-UD-Q4_K_XL" = {
      #  ctx-size = "78000";
      #  # Do we wanna set the context to something perticular? 180000 gives
      #  # really bad performance.
      #  #ctx-size = "180000";
      #  #alias = "Qwen3.8-27B-UD-Q4_K_XL";  # display name
      #  #hf-repo = "unsloth/Qwen3.8-27B-GGUF";
      #  #hf-file = "Qwen3.8-27B-UD-Q4_K_XL.gguf";
      #  model = "/var/cache/llama-cpp/Qwen3.8-27B-UD-Q4_K_XL.gguf";
      #  mmproj = "/var/cache/llama-cpp/Qwen3.8-27B-mmproj-BF16.gguf";
      #  # These values reccomended for "thinking mode"
      #  temp = "1.0";
      #  top-p = "0.95";
      #  top-k = "20";
      #  min-p = "0.0";
      #};
      "gemma-4-E4B-it-Q4_K_M" = {
        model = "/var/cache/llama-cpp/gemma-4-E4B-it-Q4_K_M.gguf";
        mmproj = "/var/cache/llama-cpp/gemma-4-E4B-mmproj-BF16.gguf";
      };
      #"Qwen3.8-27B-UD-Q4_K_M" = {
      #  ctx-size = "12000";
      #  sleep-idle-seconds = 240;
      #  # Do we wanna set the context to something perticular? 180000 gives
      #  # really bad performance.
      #  #ctx-size = "180000";
      #  #alias = "Qwen3.8-27B-UD-Q4_K_XL";  # display name
      #  hf-repo = "unsloth/Qwen3.8-27B-GGUF";
      #  hf-file = "Qwen3.8-27B-UD-Q4_K_M.gguf";
      #  # These values reccomended for "thinking mode"
      #  temp = "1.0";
      #  top-p = "0.95";
      #  top-k = "20";
      #  min-p = "0.0";
      #};
      #"gemma-4-26B-A4B-it-UD-Q4_K_XL" = {
      #  #ctx-size = "78000";
      #  sleep-idle-seconds = 240;
      #  hf-repo = "unsloth/gemma-4-26B-A4B-it-GGUF";
      #  hf-file = "gemma-4-26B-A4B-it-UD-Q4_K_XL.gguf";
      #  temp = "1.0";
      #  top-p = "0.95";
      #  top-k = "64";
      #  ctx-size = "32768";
      #  parallel = "1";
      #  cache-type-k = "q8_0";
      #  cache-type-v = "q8_0";
      #};
    };
    #modelsPreset = {
    #  "qwen3.8" = {
    #    hf-repo = "ggml-org/Qwen3.8-27B-GGUF";
    #    hf-file = "Qwen3.8-27B-UD-Q6_K_M.gguf";
    #    alias = "qwen3.8";  # display name
    #    # These values reccomended for "thinking mode"
    #    #temp = "1.0";
    #    #top-p = "0.95";
    #    #top-k = "20";
    #  };
    #};

    # Next nix version: use this style instead.
    #settings = {
    #  port = localPorts.llama-cpp;
    #  models-preset = (pkgs.formats.ini { }).generate "models-preset.ini" {
    #    "qwen3.8" = {
    #      hf-repo = "ggml-org/Qwen3.8-27B-GGUF";
    #      hf-file = "Qwen3.8-27B-UD-Q6_K_M.gguf";
    #      alias = "qwen3.8";  # display name
    #      # These values reccomended for "thinking mode"
    #      #temp = "1.0";
    #      #top-p = "0.95";
    #      #top-k = "20";
    #    };
    #  };
    #};
  };

  # XMage networking stuff
  networking.extraHosts =
    ''
      0.0.0.0 wizard.mdf.farm
    '';
  
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

  age.secrets.mdf-login = {
    file = ../../secrets/mdf-login.age;
    owner = "nginx";
    group = "nginx";
  };
  #services.mdf-bouncer = {
  #  enable = true;
  #  dstPath = "/data/website";
  #  srcPath = "/data/website-source";
  #  subPath = "api/";
  #};
  services.nginx.virtualHosts."mdf.farm" = {
    forceSSL = true;
    enableACME = true; # Let's encrypt TLS automated, not certbot
    locations = {
      # Website + Blog
      "/" = {
        root = "/data/website";
      };
      "/api" = {
        proxyPass = "http://localhost:3236";
        # NOTE the secret is stored in the text file hashed with a salt,
        # generated using htpasswd - appache tool
        # `htpasswd -v temp MDF_Nation`, then copied
        # into agenix manually. Clients are supposed to send the unhashed
        # password.
        extraConfig = ''
          auth_basic "Restricted";

          auth_basic_user_file ${config.age.secrets.mdf-login.path};
        '';
      };
    };
  };
  # Let's get sloppy!
  services.nginx.virtualHosts."slop.mdf.farm" = {
    forceSSL = true;
    enableACME = true;
    locations = {
      "/" = {
        proxyPass = "http://localhost:${toString localPorts.llama-cpp}";
      };
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

    # Special group for the website.
    groups.website = {};

    users.nginx.extraGroups = [ "turnserver" ];
    users.matrix-synapse.extraGroups = [ "turnserver" ];
    # Backup user
    users.backup = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        ''command="${pkgs.rrsync}/bin/rrsync --delete /data/backup/",restrict ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILgq+RAMpi4DsptmWOQXq+y/z1Ejt+63JL4vjY3Nmipi rakarake@creeper-spawner''
      ];
    };
  };

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "23.05";
}
