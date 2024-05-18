{ pkgs, lib, ... }:

let 
  # Open TCP/UDP ports
  ports = {
    ssh              = 8022;
    wireguard        = 51820;
    minecraft        =  8069;
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

in
{
  imports = [
    ../../modules/global.nix
    ./hardware-configuration.nix
    (minecraftServerTemplate "minecraftserver-kreate" "A not so kreative minekraft server" pkgs.jdk17)
  ];

  # Linux kernel version
  boot.kernelPackages = pkgs.linuxPackages_latest;

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
    neofetch
    cloudflared
    ffmpeg
    waypipe
  ];

  # SSH daemon
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    ports = [ ports.ssh ];
  };

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
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCtNpdgfbXtZurgN8GpLwAH3tIcMNi4hz1eZtvuBm+bTCV154EwBz+DO4eeja3GmWzOSrObjbuinxjdf+vqNFdKnqfI4eISaV54BJnJv4A5xWDqv5+iJNPD2AjIp2RswM43QcdM9MqbPnAjMcKo5TdUwFlrzR2Czv6M5//XJekrDP9dzCbhd8tT/ECEzdPrk3ItEpVPC7so+zmY9USu9duPOKSTfLDRmfK8sRnePAdkNn99yawJVh7tr2FypI9zd/N0AuhkmseQ+hP0L8vVIITB3yHXOnN33xaoXX19Lz6gVa0GQJs5YliKGB0WgHVml+b+NSGFAKsWnxB+HktW6l+KL3j/D7dZt8rbvS/t+4ecLOprTSuAbwY+Hj8iDcBF9Enpi4zo1TF0Rct2YMwOJwm/lCrYNkpxqP3SsHSrVXChmfRZgWWYmNTK1FQbMd+0KiMmy75jJq4PvshSadpPz23AqgivPG1a9G79y01mD+/gLtqpLYqaGtQtV/MD7Q4qK50= magarnicle@Microwave"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDddPLXUtA5KRLJcgTYAOVmaJ4Rncz2JznX3yew44J7RbZgzKb16BxfentZDCruDNWSwmc3AvyzK/+NqpndQrROIMJ/CYDj4w59P+l+LgOZQSxOYPEH65glcJFdrdiINj5kYfkeazHHM5lHEgb9kUFbYhekpuU81LDqSHdjfQclopwlmZ4vUs8uhqaKza+6hTpgWP+t5uN4mc0Wwu1zNV7FVXarUMkSknaQ4Fz7HAbzUxIQXMH3PCmP6FP53XnGlaphVUfvv1W/kyczCuBObcVWxaasVb95SbTYG90NxYj27Co4wwPclM9NKu2oLdDt+lI47b7SahvqF6XWr2ACvEwcyLGE/jYaeGMpLT0Nrjn1XdJtHUuDWubbEq8lBJ0hRPqbp5K/qYwu1s9bLGXCXskgdP7++o/M9SQAv6XkdSgn6ghfPYGb8a0bR+nDLbgvty9WlaXhaGQsfMrHPLo1FS39IGnXkXT3QuzKxnmc7UpPqjqRDHiRXNKUwruyD0MTo5M= magarnicle@drakonServ"
      ];
    };
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

