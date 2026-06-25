# Main "system config", common desktop settings go here
{ inputs, self, ... }: {
  flake.homeModules.desktop = { pkgs, lib, ... }: let
    pkgs-unstable = import inputs.nixpkgs-unstable { system = pkgs.stdenv.hostPlatform.system; config.allowUnfree = true; };
  in {
    imports = [
      self.homeModules.neovim
    ];
    # Browser
    programs.librewolf = {
      enable = true;
      settings = {
        # Vertical tabs
        "sidebar.verticalTabs" = true;
        # Restore previous session on startup
        "browser.startup.page" = 3;
        # Enable webgl
        "webgl.disabled" = false;
        # Don't clear cookies and history
        "privacy.clearOnShutdown.history" = false;
        "privacy.clearOnShutdown.cookies" = false;
        "privacy.sanitize.sanitizeOnShutdown" = false;
        # Force big scrollbars
        "widget.non-native-theme.scrollbar.size.override" = 25;
        # Middle mouse button scrolling
        "general.autoScroll" = true;

        # Change fingerprint protection.
        #"privacy.fingerprintingProtection" = false;
        "privacy.resistFingerprinting" = false;
        #"privacy.fingerprintingProtection.overrides" = "+AllTargets,-CSSPrefersColorScheme";
      };
      profiles = {
        default = {
          name = "default";
          isDefault = true;
          extensions.force = true;
        };
      };
    };

    ## Terminal
    programs.foot = {
      settings.main.term = "xterm-256color";
      enable = true;
      server.enable = true;
    };

    xdg.userDirs.setSessionVariables = true;

    # Ghci prompt
    home.file.".ghci".source = ./rakarake/.ghci;

    # SSH
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      #matchBlocks."ssh.rakarake.xyz".proxyCommand = "${pkgs.cloudflared}/bin/cloudflared access ssh --hostname ssh.rakarake.xyz";
    };

    # Pdf viewer
    programs.zathura = {
      enable = true;
      options = {
        selection-clipboard = "clipboard";
      };
    };

    # Virt-manager error free
    dconf.settings = {
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = [ "qemu:///system" ];
        uris = [ "qemu:///system" ];
      };
    };

    # Mangohud
    programs.mangohud = {
      enable = true;
      settings = {
        toggle_hud = "Shift_L+F12";
        toggle_preset = "Shift_L+F10";
        toggle_hud_position = "Shift_L+F11";
        toggle_fps_limit = "Shift_L+F1";
        toggle_logging = "Shift_L+F2";
        reload_cfg = "Shift_L+F4";
        upload_log = "Shift_L+F3";

        no_display = true;
      };
    };

    nixpkgs.config.allowUnfree = true;

    # User specific packages
    home.packages = with pkgs; [
      zathuraPkgs.zathura_pdf_mupdf
      appimage-run
      protonup-qt
      kdePackages.filelight
      nicotine-plus
      #ardour
      r2modman
      #pkgs.osu-lazer
      supertuxkart
      gamescope
      audacity
      pkgsRocm.blender
      inkscape
      emote
      gcolor3
      handbrake
      video-trimmer
      easyeffects
      file-roller
      rclone
      gnome-clocks
      gnupg1
      okteta
      krita
      gimp3
      obsidian
      hieroglyphic
      strawberry
      gdb
      renderdoc
      qbittorrent
      discord
      kdePackages.kate
      kdePackages.kdenlive
      pkgs-unstable.aichat
      poppler-utils # Needed for pdf RAG
      pkgs-unstable.opencode
      pkgs-unstable.yt-dlp
      pkgs-unstable.grayjay
      pkgs-unstable.komikku
      libresprite

      # Emulators
      fceux
      dolphin-emu
      #torzu
      ryubing
      (pkgs.retroarch.withCores (
        cores: with cores; [
          mesen
          bsnes
          citra
          parallel-n64
        ]
      ))

      # Minecraft time
      prismlauncher
      glfw3-minecraft
      jdk21

      # Hacking
      skim
      cargo-mommy
    ];

    programs.vesktop.enable = true;
    programs.element-desktop.enable = true;

    #age.secrets.rakarake-rclone-webdav = {
    #  file = ../../secrets/rakarake-rclone-webdav.age;
    #  mode = "600";
    #};

    # Moment
    nixpkgs.config.permittedInsecurePackages = [
      "olm-3.2.16" # For nheko matrix client
      "fluffychat-linux-1.26.1" # Fluffychat
      "electron-27.3.11"
      "dotnet-runtime-7.0.20" # Vintage story
      "mbedtls-2.28.10" # I have no idea
    ];

    xdg.desktopEntries =
      let
        # A desktop entry that launches an electron app with ozone turned on
        electronWaylandApp = name: {
          name = "${name} wayland";
          exec = "${name} --ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-webrtc-pipewire-capturer";
          icon = name;
        };
        qtWaylandApp = name: {
          name = "${name} wayland";
          exec = ''${name} -platform "wayland;xcb"'';
          icon = name;
        };
        qtX11App = name: {
          name = "${name} X11";
          exec = ''${name} -platform "xcb"'';
          icon = name;
        };
        # Takes a list of executable names and makes wayland desktop entries for them
        makeElectronWaylandApps =
          appNames:
          (lib.listToAttrs (
            map (name: {
              name = "${name}Wayland";
              value = electronWaylandApp name;
            }) appNames
          ));
        makeQTWaylandApps =
          appNames:
          (lib.listToAttrs (
            map (name: {
              name = "${name}Wayland";
              value = qtWaylandApp name;
            }) appNames
          ));
        makeQTX11Apps =
          appNames:
          (lib.listToAttrs (
            map (name: {
              name = "${name}X11";
              value = qtX11App name;
            }) appNames
          ));
      in
      {
        godotSingleWindow = {
          name = "Godot 4 Single Window";
          genericName = "Godot 4 Single Window";
          exec = "godot4 --single-window";
        };
        steamGamescope = {
          name = "Steam Gamescope";
          genericName = "Steam";
          # -e enables steam integration, -f fullscreens the window by default
          exec = "gamescope -W 1920 -H 1080 --adaptive-sync -f -r 600 -e -- steam";
        };
      }
      // (makeElectronWaylandApps [
        "code"
        "codium"
        "vesktop"
      ])
      // (makeQTWaylandApps [
        "monero-wallet-gui"
      ])
      // (makeQTX11Apps [
        "eden"
      ]);
  };
  flake.nixosModules.desktop = { lib, config, pkgs, outputs, inputs, ... }: {
    environment.systemPackages = with pkgs; [
      libnotify # gives notify-send
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
      powertop # Power usage inspector
      kitty
      sl
      wl-clipboard
      tree
      unzip
      zip
      timidity # MIDI CLI player
      freepats # MIDI soundfont
      btrfs-progs
      distrobox
      pandoc
      pwvucontrol
      gparted
      tmux
      nextcloud-client
      mesa-demos # Has programs such as glxgears
      adwaita-icon-theme # Just to be safe
      mpv
      imv
      perf # Performance metrics
      nix-index # For working with /nix/store
      nix-search
      wireshark
      qemu
      nix-tree
      man-pages
      man-pages-posix
      wineWowPackages.waylandFull
      libreoffice-qt
      onlyoffice-desktopeditors
      hunspell # Libreoffice spelling
      hunspellDicts.sv_SE # Swedish
      hunspellDicts.en_US # American
      hunspellDicts.en_GB-ise # English
      librewolf
      ungoogled-chromium
      thunderbird
      qpwgraph
      ffmpeg
      waypipe
      kdePackages.okular
      android-studio
      #davfs2
      scrcpy
      exfat
      rclone
      # Needed for gsettings programs to work, probably, maybe
      gsettings-desktop-schemas
      gnome-calculator  # Still havn't found a better one
      nix-search-cli
      inputs.nix-versions.packages.${system}.default
      android-tools # adb
      lm_sensors
      steam-run
    ];

    programs.gamemode = {
      enable = true;
      settings = {
        general = {
          renice = 10;
        };
      
        # Warning: GPU optimisations have the potential to damage hardware
        #gpu = {
        #  apply_gpu_optimisations = "accept-responsibility";
        #  gpu_device = 0;
        #  amd_performance_level = "high";
        #};
      
        custom = {
          start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
          end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
        };
      };
    };

    # Rescue kernel panics
    boot.crashDump.enable = true;

    # GPG
    services.pcscd.enable = true;
    programs.gnupg.agent = {
      enable = true;
      pinentryPackage = pkgs.pinentry-curses;
      enableSSHSupport = true;
    };

    # Development man-pages for packages
    documentation.dev.enable = true;

    programs.obs-studio = {
      enable = true;
      # v4l2 kernel modules
      enableVirtualCamera = true;
    };

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
    fonts.packages =
      with pkgs;
      [
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
        liberation_ttf
        fira-code
        fira-code-symbols
        mplus-outline-fonts.githubRelease
        dina-font
        proggyfonts
        orbitron
        corefonts # Microsoft fonts
      ]
      ++ (builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts));

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
    hardware.steam-hardware.enable = true; # To enable steam controller etc.
    nixpkgs.config.packageOverrides = pkgs: {
      steam = pkgs.steam.override {
        extraEnv = {
          MANGOHUD = "1";
        };
        extraPkgs =
          pkgs: with pkgs; [
            libXcursor
            libXi
            libXinerama
            libXScrnSaver
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

      # Bigger buffers for less crackling
      extraConfig.pipewire."99-latency" = {
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.quantum" = 512;
          "default.clock.min-quantum" = 256;
          "default.clock.max-quantum" = 1024;
        };
      };
    };

    # Enable touchpad support (enabled default in most desktopManager).
    # services.xserver.libinput.enable = true;

    # Define a user account. Don't forget to set a password with ‘passwd’.
    #programs.zsh.enable = true;
    users.users.rakarake = {
      isNormalUser = true;
      description = "Rakarake";
      #shell = pkgs.zsh;
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

        # Magic docker user.
        "docker"

        # For gamemode to be able to renice.
        "gamemode"
      ];
    };
    users.groups.davfs2 = { };

    # Needed for xremap home-manager config to work
    hardware.uinput.enable = true;

    ## Mullvad Service
    services.mullvad-vpn.enable = true;
    services.mullvad-vpn.package = pkgs.mullvad-vpn;

    # Enable the flatpak service
    services.flatpak.enable = true;
    fonts.fontDir.enable = true; # Fonts don't work otherwise?
    xdg.portal.enable = true;

    # Required for rclone to mount with systemd?
    programs.fuse.userAllowOther = true;

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
        libXcomposite
        libXtst
        libXrandr
        libXext
        libX11
        libXfixes
        libGL
        libva
        pipewire
        libxcb
        libXdamage
        libxshmfence
        libXxf86vm
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
        libXinerama
        libXcursor
        libXrender
        libXScrnSaver
        libXi
        libSM
        libICE
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
        libXt
        libXmu
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
        libXft
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
        alsa-plugins
        alsa-topology-conf
        alsa-ucm-conf
        alsa-utils
        expat
        # for blender
        libxkbcommon

        libxcrypt-legacy # For natron
        libGLU # For natron

        # Appimages need fuse, e.g. https://musescore.org/fr/download/musescore-x86_64.AppImage
        fuse
        e2fsprogs

        libsm
        harfbuzz
      ];
    };
  };
}
