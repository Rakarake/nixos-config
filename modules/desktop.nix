# Main "system config", common desktop settings go here
{ lib, config, pkgs, ... }@attrs:
with lib;                      
let
  cfg = config.cfg-desktop;
in {
  options.cfg-desktop = {
    enable = mkEnableOption "Common desktop configuration";
  };

  config = mkIf cfg.enable {
    # System Packages/Programs
    # To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
      vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
      neovim
      ripgrep
      wget
      gnumake
      zsh
      git
      openssh
      neofetch
      onefetch
      bat
      htop
      neo-cowsay
      attrs.nix-software-center.packages.${system}.nix-software-center
      attrs.nixos-conf-editor.packages.${system}.nixos-conf-editor
      powertop  # Power usage inspector
      kitty
      sl
      wl-clipboard
      tree
      unzip
      zip
      timidity    # MIDI CLI player
      freepats    # MIDI soundfont
      btrfs-progs
      steam-run
      steamtinkerlaunch
      distrobox
      fceux
      mangohud
      obs-studio
      pandoc
      protonup-qt
      baobab
      pavucontrol
      gparted
      popsicle
      discord
      linuxPackages_latest.perf
      texlive.combined.scheme-medium
      gamemode
      tmux
      nextcloud-client
      iotas
      gnome.gnome-software
      logseq
      soundux
      helvum
      mesa-demos  # Has programs such as glxgears
      gnome.adwaita-icon-theme  # Just to be safe

      # Wine
      wineWowPackages.staging

      # HTML / CSS / JSON / ESLint language server
      vscode-langservers-extracted
      # C / C++
      clang
      pkg-config
      ccls          # A C/C++ language server
      mpi           # C message passing
      # Haskell
      ghc
      haskell-language-server
      # Nix??? 😲
      nil  # Nix language server
      # Godot
      godot_4
      # Rust
      rustc
      cargo
      rustfmt
      rust-analyzer # Rust language server
      # Python
      python3
      # Java
      jdk17

      # Go
      go
      gopls

      # Other
      openttd
      osu-lazer
      superTuxKart
      prismlauncher
      gamescope

      vlc
      audacity
      libreoffice
      onlyoffice-bin
      hunspell                 # Libreoffice spelling
      hunspellDicts.sv_SE      # Swedish
      hunspellDicts.en_US      # American
      hunspellDicts.en_GB-ise  # English
      krita
      firefox
      ungoogled-chromium
      thunderbird
      blender
      qpwgraph
      tauon
      easyeffects
      mullvad-vpn
      fragments
      gnome.gnome-mines
      mission-center
      celluloid
    ];

    # System76 scheduler
    services.system76-scheduler = {
      enable = true;
      useStockConfig = true;
      #settings.processScheduler.pipewireBoost.enable = true;
      #settings.processScheduler.foregroundBoost.enable = true;
    };

    # This makes these fonts available for applications
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
    ];

    # GPG / GnuPG
    programs.gnupg.agent = {
      enable = true;
      # Enable the 'pinentryFlavor' in the DE specific config
      #enableSSHSupport = true;
    };

    # Podman
    virtualisation = {
      podman = {
        enable = true;

        # Create a `docker` alias for podman, to use it as a drop-in replacement
        dockerCompat = true;

        # Required for containers under podman-compose to be able to talk to each other.
        defaultNetwork.settings.dns_enabled = true;
      };
    };

    # Steam
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    };
    hardware.steam-hardware.enable = true;  # To enable steam controller etc.
    nixpkgs.config.packageOverrides = pkgs: {
      steam = pkgs.steam.override {
        extraPkgs = pkgs: with pkgs; [
          xorg.libXcursor
          xorg.libXi
          xorg.libXinerama
          xorg.libXScrnSaver
          libpng
          libpulseaudio
          libvorbis
          stdenv.cc.cc.lib
          libkrb5
          keyutils
        ];
      };
    };
    environment.sessionVariables = {
      # Needed for gamescope to run in steam
      ENABLE_VKBASALT = "1";
    };

    # Enable Android stuff
    programs.adb.enable = true;

    # Bootloader
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # Use zen kernel
    boot.kernelPackages = pkgs.linuxPackages_zen;

    # Enable Plymouth
    boot.plymouth.enable = true;
    boot.initrd.systemd.enable = true;

    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

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

    # Enable the X11 windowing system.
    services.xserver.enable = true;

    # Configure keymap in X11
    services.xserver = {
      layout = "us,se";
      xkbVariant = "";
    };

    # Enable CUPS to print documents.
    services.printing.enable = true;

    # Enable sound with pipewire.
    sound.enable = true;
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      jack.enable = true;

      #media-session.enable = true;
      wireplumber.enable = true;
    };

    # Enable touchpad support (enabled default in most desktopManager).
    # services.xserver.libinput.enable = true;

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.rakarake = {
      isNormalUser = true;
      description = "Rakarake";
      extraGroups = [ "networkmanager" "wheel" "adbusers" ];
    };

    # Mullvad Service
    services.mullvad-vpn.enable = true;

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # Enable the flatpak service
    services.flatpak.enable = true;

    # Enable OpenGL, probably not needed
    hardware.opengl.enable = true;
    # Enable OpenGL 32Bit support, prolly not needed, maybe
    hardware.opengl.driSupport32Bit = true;

    # Collect all the garbage automatically!
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    # Creates a file which lists all system packages
    environment.etc."current-system-packages".text =
    let
       packages = builtins.map (p: "${p.name}") config.environment.systemPackages;
       sortedUnique = builtins.sort builtins.lessThan (lib.unique packages);
       formatted = builtins.concatStringsSep "\n" sortedUnique;
    in formatted; 

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # programs.mtr.enable = true;

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "23.05"; # Did you read the comment?
  };
}
