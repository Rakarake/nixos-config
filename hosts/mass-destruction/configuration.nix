{ pkgs, lib, ... }:

let 
  # Open TCP/UDP ports
  ports = {
    ssh              = 22;
  };
in
{
  imports = [
    ../../modules/global.nix
    ./hardware-configuration.nix
  ];

  # Linux kernel version
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Hostname
  networking.hostName = "mass-destruction";

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

"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCtNpdgfbXtZurgN8GpLwAH3tIcMNi4hz1eZtvuBm+bTCV154EwBz+DO4eeja3GmWzOSrObjbuinxjdf+vqNFdKnqfI4eISaV54BJnJv4A5xWDqv5+iJNPD2AjIp2RswM43QcdM9MqbPnAjMcKo5TdUwFlrzR2Czv6M5//XJekrDP9dzCbhd8tT/ECEzdPrk3ItEpVPC7so+zmY9USu9duPOKSTfLDRmfK8sRnePAdkNn99yawJVh7tr2FypI9zd/N0AuhkmseQ+hP0L8vVIITB3yHXOnN33xaoXX19Lz6gVa0GQJs5YliKGB0WgHVml+b+NSGFAKsWnxB+HktW6l+KL3j/D7dZt8rbvS/t+4ecLOprTSuAbwY+Hj8iDcBF9Enpi4zo1TF0Rct2YMwOJwm/lCrYNkpxqP3SsHSrVXChmfRZgWWYmNTK1FQbMd+0KiMmy75jJq4PvshSadpPz23AqgivPG1a9G79y01mD+/gLtqpLYqaGtQtV/MD7Q4qK50= magarnicle@Microwave"
      ];
    };
  };

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "23.05";
}

