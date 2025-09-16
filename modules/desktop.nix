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
      wget
      gnumake
      git
      git-lfs
      openssh
      fastfetch
      onefetch
      bat
      htop
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
      pwvucontrol
      gparted
      gamemode
      tmux
      nextcloud-client
      gnome-software
      mesa-demos  # Has programs such as glxgears
      adwaita-icon-theme  # Just to be safe
      mpv
      vlc
      imv
      linuxPackages_latest.perf # Performance metrics
      impression    # Boot drive creator
      nix-index     # For working with /nix/store
      nix-search
      libnotify
      wireshark
      libresprite
      qemu
      nix-tree
      man-pages
      man-pages-posix
      wineWowPackages.waylandFull
      libreoffice-qt
      onlyoffice-bin
      hunspell                 # Libreoffice spelling
      hunspellDicts.sv_SE      # Swedish
      hunspellDicts.en_US      # American
      hunspellDicts.en_GB-ise  # English
      librewolf
      ungoogled-chromium
      thunderbird
      qpwgraph
      #easyeffects
      gnome-mines
      gnome-sound-recorder
      ffmpeg
      waypipe
      kdePackages.okular
      android-studio
      #davfs2
    ];

    # Rescue kernel panics
    boot.crashDump.enable = true;

    # Droidcam
    programs.droidcam.enable = true;

    # GPG
    services.pcscd.enable = true;
    programs.gnupg.agent = {
       enable = true;
       pinentryPackage = pkgs.pinentry-curses;
       enableSSHSupport = true;
    };

    # Development man-pages for packages
    documentation.dev.enable = true;

    # Fwupd, firmware updater
    # fwupdmgr get-devices - to get devices
    # fwupdmgr refresh - to download metadata
    # fwupdmgr get-updates - to see which devices can be updated
    # fwupdmgr update - to update devices (now or at boot)
    services.fwupd.enable = true;

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
      #"electron-20.3.12"
      #"electron-24.8.6"
      #"electron-25.9.0"
      #"freeimage-unstable-2021-11-01"
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
      orbitron
      corefonts  # Microsoft fonts
    ] ++ (builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts));

    ## GPG / GnuPG
    #programs.gnupg.agent = {
    #  enable = true;
    #  # Enable the 'pinentryFlavor' in the DE specific config
    #  #enableSSHSupport = true;
    #};

    # Docker or podman is needed for distrobox, it seems that podman works better

    # Docker
    #virtualisation.docker = {
    #  enable = true;
    #  rootless = {
    #    enable = true;
    #    setSocketVariable = true;
    #  };
    #};

    # Wireshark
    programs.wireshark.enable = true;

    # Firejail
    programs.firejail.enable = true;

    ## Use encrypted cloudflare DNS
    #networking = {
    #  nameservers = [ "1.1.1.1" "::1" ];
    #  networkmanager.dns = "none";
    #};
    #services.dnscrypt-proxy2.enable = true;
    #systemd.services.dnscrypt-proxy2.serviceConfig = {
    #  StateDirectory = "dnscrypt-proxy";
    #};

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
      # Always allow unfree nix packages :(
      NIXPKGS_ALLOW_UNFREE = "1";
    };

    # Enable Android stuff
    programs.adb.enable = true;
    # Required by CalyxOS installer?
    services.udev.packages = [
      pkgs.android-udev-rules
    ];

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
    #services.automatic-timezoned.enable = true;
    #services.localtimed.enable = true;

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

    ## Enable the X11 windowing system.
    #services.xserver.enable = true;

    # Configure keymap in X11
    services.xserver = {
      xkb.layout = "us,se";
      xkb.variant = "";
    };

    # Enable CUPS to print documents.
    services.printing.enable = true;

    # Enable sound with pipewire.
    services.pulseaudio.enable = false;
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
      extraGroups = [
        "networkmanager"
        # For sudo
        "wheel"
        "seat"
        # Adb: android debugging
        "adbusers"
        "docker"
        "wireshark"
        "davfs2"

        # For viritualization
        "libvirtd"
        "vboxusers"

        # Needed for xremap
        "uinput"
        "input"

        # RTS LAB
        "dialout"
      ];
    };
    users.groups.davfs2 = {};

    # Needed for xremap home-manager config to work
    hardware.uinput.enable = true;

    # Mullvad Service
    services.mullvad-vpn.enable = true;

    # Enable the flatpak service
    services.flatpak.enable = true;
    fonts.fontDir.enable = true;  # Fonts don't work otherwise?
    xdg.portal.enable = true;

    # Collect all the garbage automatically!
    #nix.gc = {
    #  automatic = true;
    #  dates = "weekly";
    #  options = "--delete-older-than 7d";
    #};

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

    # Nix ld with list copied from https://wiki.nixos.org/wiki/Nix-ld
    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [
        # List by default
        zlib
        zstd
        stdenv.cc.cc
        curl
        openssl
        attr
        libssh
        bzip2
        libxml2
        acl
        libsodium
        util-linux
        xz
        systemd
        
        # My own additions
        xorg.libXcomposite
        xorg.libXtst
        xorg.libXrandr
        xorg.libXext
        xorg.libX11
        xorg.libXfixes
        libGL
        libva
        pipewire
        xorg.libxcb
        xorg.libXdamage
        xorg.libxshmfence
        xorg.libXxf86vm
        libelf

        # Required
        glib
        gtk2

        # Inspired by steam
        # https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/st/steam/package.nix#L36-L85
        networkmanager      
        vulkan-loader
        libgbm
        libdrm
        libxcrypt
        coreutils
        pciutils
        zenity
        # glibc_multi.bin # Seems to cause issue in ARM
        
        # # Without these it silently fails
        xorg.libXinerama
        xorg.libXcursor
        xorg.libXrender
        xorg.libXScrnSaver
        xorg.libXi
        xorg.libSM
        xorg.libICE
        gnome2.GConf
        nspr
        nss
        cups
        libcap
        SDL2
        libusb1
        dbus-glib
        ffmpeg
        # Only libraries are needed from those two
        libudev0-shim
        
        # needed to run unity
        gtk3
        icu
        libnotify
        gsettings-desktop-schemas
        # https://github.com/NixOS/nixpkgs/issues/72282
        # https://github.com/NixOS/nixpkgs/blob/2e87260fafdd3d18aa1719246fd704b35e55b0f2/pkgs/applications/misc/joplin-desktop/default.nix#L16
        # log in /home/leo/.config/unity3d/Editor.log
        # it will segfault when opening files if you don’t do:
        # export XDG_DATA_DIRS=/nix/store/0nfsywbk0qml4faa7sk3sdfmbd85b7ra-gsettings-desktop-schemas-43.0/share/gsettings-schemas/gsettings-desktop-schemas-43.0:/nix/store/rkscn1raa3x850zq7jp9q3j5ghcf6zi2-gtk+3-3.24.35/share/gsettings-schemas/gtk+3-3.24.35/:$XDG_DATA_DIRS
        # other issue: (Unity:377230): GLib-GIO-CRITICAL **: 21:09:04.706: g_dbus_proxy_call_sync_internal: assertion 'G_IS_DBUS_PROXY (proxy)' failed
        
        # Verified games requirements
        xorg.libXt
        xorg.libXmu
        libogg
        libvorbis
        SDL
        SDL2_image
        glew110
        libidn
        tbb
        
        # Other things from runtime
        flac
        freeglut
        libjpeg
        libpng
        libpng12
        libsamplerate
        libmikmod
        libtheora
        libtiff
        pixman
        speex
        SDL_image
        SDL_ttf
        SDL_mixer
        SDL2_ttf
        SDL2_mixer
        libappindicator-gtk2
        libdbusmenu-gtk2
        libindicator-gtk2
        libcaca
        libcanberra
        libgcrypt
        libvpx
        librsvg
        xorg.libXft
        libvdpau
        # ...
        # Some more libraries that I needed to run programs
        pango
        cairo
        atk
        gdk-pixbuf
        fontconfig
        freetype
        dbus
        alsa-lib
        expat
        # for blender
        libxkbcommon

        libxcrypt-legacy # For natron
        libGLU # For natron

        # Appimages need fuse, e.g. https://musescore.org/fr/download/musescore-x86_64.AppImage
        fuse
        e2fsprogs
      ];
    };  
  };
}

