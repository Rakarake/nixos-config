# Main "system config", common desktop settings go here
{ lib, config, pkgs, outputs, inputs, ... }:
with lib;                      
let
  cfg = config.cfg-desktop;
  # For fun ports to play with
  # React uses 3000 by default
  #openPorts = [ 1337 1338 1339 3000 ];
in {
  options.cfg-desktop = {
    enable = mkEnableOption "Common desktop configuration";
  };

  config = mkIf cfg.enable { # System Packages/Programs To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
      vim
      ripgrep
      wget
      gnumake
      git
      git-lfs
      openssh
      fastfetch
      onefetch
      bat
      htop
      btop
      neo-cowsay
      inputs.queercat.defaultPackage.${system}
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
      distrobox
      pandoc
      pavucontrol
      gparted
      gamemode
      tmux
      nextcloud-client
      gnome.gnome-software
      mesa-demos  # Has programs such as glxgears
      gnome.adwaita-icon-theme  # Just to be safe
      mpv
      vlc
      imv
      linuxPackages_latest.perf # Performance metrics
      impression    # Boot drive creator
      nix-index     # For working with /nix/store
      appimage-run
      libnotify
      wireshark
      libresprite
      qemu
      comma
      smile # Emoji picker
      nix-tree
      outputs.packages.${system}.amogus
      man-pages
      man-pages-posix
      wineWowPackages.staging
      libreoffice-qt
      onlyoffice-bin
      hunspell                 # Libreoffice spelling
      hunspellDicts.sv_SE      # Swedish
      hunspellDicts.en_US      # American
      hunspellDicts.en_GB-ise  # English
      krita
      firefox
      ungoogled-chromium
      thunderbird
      qpwgraph
      strawberry
      easyeffects
      gnome.gnome-mines
      gnome.gnome-sound-recorder
      ffmpeg
      waypipe
      okular
    ];

    # Nh
    programs.nh = {
      enable = true;
    };

    # Development man-pages for packages
    documentation.dev.enable = true;

    # Fwupd, firmware updater
    # fwupdmgr get-devices - to get devices
    # fwupdmgr refresh - to download metadata
    # fwupdmgr get-updates - to see which devices can be updated
    # fwupdmgr update - to update devices (now or at boot)
    services.fwupd.enable = true;

    # Linux kernel package
    #boot.kernelPackages = pkgs.linuxPackages_latest;

    # Input engines
    i18n.inputMethod.ibus.engines = [
      pkgs.ibus-engines.mozc
    ];

    # Emulation 😈
    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = true;

    # Open ports, for fun purposes
    networking.firewall.enable = false;

    # Fix Logseq bad old electron problem
    nixpkgs.config.permittedInsecurePackages = [
      "electron-20.3.12"
      "electron-24.8.6"
      "electron-25.9.0"
      "freeimage-unstable-2021-11-01"
    ];
    #nixpkgs.overlays = [
    #  (
    #    final: prev: {
    #      logseq = prev.logseq.overrideAttrs (oldAttrs: {
    #        postFixup = ''
    #          makeWrapper ${prev.electron_20}/bin/electron $out/bin/${oldAttrs.pname} \
    #            --set "LOCAL_GIT_DIRECTORY" ${prev.git} \
    #            --add-flags $out/share/${oldAttrs.pname}/resources/app \
    #            --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}" \
    #            --prefix LD_LIBRARY_PATH : "${prev.lib.makeLibraryPath [ prev.stdenv.cc.cc.lib ]}"
    #        '';
    #      });
    #    }
    #  )
    #];

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
      corefonts  # Microsoft fonts
    ];

    # GPG / GnuPG
    programs.gnupg.agent = {
      enable = true;
      # Enable the 'pinentryFlavor' in the DE specific config
      #enableSSHSupport = true;
    };

    # Docker or podman is needed for distrobox, it seems that podman works better

    # Docker
    #virtualisation.docker = {
    #  enable = true;
    #  rootless = {
    #    enable = true;
    #    setSocketVariable = true;
    #  };
    #};

    # Podman
    virtualisation = {
      podman = {
        enable = true;

        # Create a `docker` alias for podman, to use it as a drop-in replacement
        dockerCompat = true;

        # Required for containers under podman-compose to be able to talk to each other.
        defaultNetwork.settings.dns_enabled = true;
      };
      # Virtualbox
      virtualbox.host.enable = true;
    };

    # Wireshark
    programs.wireshark.enable = true;

    # Steam
    programs.steam = {
      enable = true;
      #remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      #dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
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
          mesa-demos
        ];
      };
    };
    environment.sessionVariables = {
      # Needed for gamescope to run in steam
      ENABLE_VKBASALT = "1";
      # Default browser
      BROWSER = "firefox";
      # Always allow unfree nix packages 😛
      NIXPKGS_ALLOW_UNFREE = "1";
    };

    # Enable Android stuff
    programs.adb.enable = true;

    # Bootloader
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # Use zen kernel
    #boot.kernelPackages = pkgs.linuxPackages_zen;

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
      xkb.layout = "us,se";
      xkb.variant = "";
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
      extraGroups = [ "networkmanager" "wheel" "adbusers" "docker" "wireshark" "davfs2" "libvirtd" "vboxusers" ];
    };

    # Mullvad Service
    #services.mullvad-vpn.enable = true;

    # Enable the flatpak service
    services.flatpak.enable = true;

    # Collect all the garbage automatically!
    #nix.gc = {
    #  automatic = true;
    #  dates = "weekly";
    #  options = "--delete-older-than 7d";
    #};

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

