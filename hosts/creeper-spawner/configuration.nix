# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }@attrs: {
  # Hostname
  networking.hostName = "creeper-spawner";

  # Open ports
  networking.firewall.allowedTCPPorts = [ 25565 80 443 ];
  #networking.firewall.allowedUDPPorts = [ 80 443 ];

  # System Packages/Programs
  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    gnumake
    zsh
    git
    openssh
    neofetch
    bat
    powertop  # Power usage inspector
    tree
    btrfs-progs
    tmux

    # Rust
    rustc
    cargo
    rustfmt
    rust-analyzer # Rust language server
    # Python
    python3
    # Java
    jdk17
  ];

  # SSH daemon
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    ports = [ 22 222 ];
  };
  users.users."rakarake".openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDswNWTldzMxDmGVMmftP1veTWsWqYehiSglmUktQa4JRkWbzHh20nF90l69T7gYgq551KYsgB83Kdexe+j5GARzeaJB3700mUKHHoBW80RwVQKZuj5HEqy2cvaEGywx84WS9uJDs09wmFABM0FBRjeEHfvHQsE6elB0zVDsCogSBl4T+bW9sxzrMZpXsjmdJ//9QE1mLaZlYLBLwc79iAZFL4ZeWqGFl/gHyA+lLOvgmrtJMBeIMw3CZI8LNLtbTK0PILzSzTOnfFtx3L72wgqUm49P1taFC9WncPy0TN9fJoXV9WjRlrwvJNWycRnMJNmVg4f4gSCYEI1lcspN04ahZH+nOTFhl2dQrw5x2QWCMfATNQPzBYvuFr/UyaaNFpUFp4QD9lccokB8rq99ls97EtZ1w4RitGvc8GGcZ8qy8iIcijT4JRZxxYAH8ebSwykXZCdTSD21uMebyRnScZf/xHaGV6MH7NIeRH7YlaWI+kpWbd7SqHtDbtecPHqAeE= Williams GPG Key"
  ];

  # Nextcloud
  services.nextcloud = {
    enable = true;
    hostName = "rakarake.xyz";
    database.createLocally = true;
    autoUpdateApps.enable = true;
    config = {
      dbtype = "pgsql";
      adminpassFile = "/var/lib/nextcloud/adminpassword";
    };
  };

  # Enable Flakes
  nix.settings.experimental-features = [ "flakes" "nix-command" ];

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

  # TODO lookie here
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.rakarake = {
    isNormalUser = true;
    description = "Rakarake";
    extraGroups = [ "networkmanager" "wheel" "adbusers" ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;

  system.stateVersion = "23.05";

  # Include the results of the hardware scan.
  imports = [ ./hardware-configuration.nix ];
}
