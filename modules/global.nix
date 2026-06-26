{ inputs, self, ... }: {
  # flake-parts modules, so that we can expose homeModules etc.
  imports = [
    inputs.home-manager.flakeModules.home-manager
  ];

  # Default rakarake home config.
  flake.homeConfigurations."rakarake" = let
    pkgs = import inputs.nixpkgs { system = "x86_64-linux"; config.allowUnfree = true; };
  in inputs.home-manager.lib.homeManagerConfiguration {
    modules = [
      self.homeModules.global
      self.homeModules.desktop
      self.homeModules.styling
      ({ lib, ... }: {
        home.stateVersion = "23.05";
        home.username = "rakarake";
        home.homeDirectory = "/home/rakarake";
      })
    ];
    inherit pkgs;
  };

  flake.homeModules.global = { lib, config, pkgs, inputs, ... }: let
    environmentVariables = {
      EDITOR = lib.mkForce "nvim";
      VISUAL = "nvim";
      BROWSER = "librewolf";
      MANPAGER= "nvim +Man!";
      # Enable wayland for qt and electron by default, just unset to use default
      QT_QPA_PLATFORM = "wayland";
      NIXOS_OZONE_WL = "1";
    };
 in {
    imports = [
      #(self.homeModules.bash {})
      #inputs.agenix.homeManagerModules.default
      #inputs.nix-index-database.homeModules.nix-index
      # TODO move to stylix
      #inputs.stylix.homeModules.stylix
    ];

    # Bash config
    #home-bash.enable = true;

    # Btop
    programs.btop = {
      enable = true;
    };

    programs.bat.enable = true;

    # Session variables
    home.sessionVariables = environmentVariables;
    systemd.user.sessionVariables = environmentVariables;

    home.packages = with pkgs; [
      bc  # basic calculator
      typst

      # Rusty utils
      fd
      ripgrep
      ripgrep-all  # Searches within structured documents (pdf, docx etc)

      # I'm stupid
      tldr
      wikiman

      # The best program ever
      lazygit
    ];

    # Shell aliases
    home.shellAliases = {
      g = "git";
      e = "nvim";
      # For "NeoVim with Port"
      nvp = "nvim --listen localhost:15923";
      b = "librewolf";
      f = "dolphin & disown";
      open = "xdg-open";
      ":q" = "exit";
      ".." = "cd ..";
      cp = "cp -v";
      mv = "mv -v";
      rm = "rm -v";
      ks = "kitten ssh";

      # Swag
      uwu = "${pkgs.fastfetch}/bin/fastfetch --logo ${self}/home/rakarake/sillyascii";
      
      # Open new terminal in directory
      gg = "gnome-terminal . &";
      xx = "kgx & disown";
      aa = "alacritty & disown";
      kk = "kitty & disown";
      
      # Networking
      iplist = "${pkgs.nmap}/bin/nmap -sP 192.168.1.1/24";
      
      # VSCode/Codium
      codew = "NIXOS_OZONE_WL=1 code";
      codiw = "NIXOS_OZONE_WL=1 codium";
      
      # Nix Fast
      nd = "nix develop";
      rebuild = "${pkgs.nh}/bin/nh os switch .";
      rebuildboot = "${pkgs.nh}/bin/nh os boot .";
      # idk if this works
      homebuild = "${pkgs.nh}/bin/nh home switch -c ${config.home.username} .";
      lightbuild = "${pkgs.nh}/bin/nh home switch -c ${config.home.username}-light .";
      darkbuild = "${pkgs.nh}/bin/nh home switch -c ${config.home.username}-dark .";
    };

    # Tmux
    programs.tmux = {
      enable = true;
      mouse = true;
      escapeTime = 0;
      # Use Ctrl-A instead of Ctrl-B
      prefix = "C-a";
      keyMode = "vi";
      extraConfig = ''
        # Allows for sending images to the parent terminal
        set -g allow-passthrough

        # Diable status bar
        #set -g status off

        # Switch to last window
        bind-key C-a last-window

        # Easier previous/next window
        bind-key C-p previous-window
        bind-key C-n next-window

        # Proper color mode, https://unix.stackexchange.com/a/734894
        #set -g default-terminal "xterm-256color"
        set-option -g default-terminal "tmux-256color" 
        set-option -ga terminal-overrides ",xterm-256color:Tc"
      '';
    };
    # Git config
    programs.git = {
      enable = true;
      lfs.enable = true;
      settings = {
        user = {
          username = "Rakarake";
          email = "raka@rakarake.xyz";
          signingkey = "98CF6C24F40B3531!";
        };
        alias = {
          a = "add";
          co = "checkout";
          b = "branch";
          c = "commit";
          s = "status";
          r = "remote";
          l = "log";
          cl = "clone";
          p = "pull";
          pr = "pull --rebase";
          pu = "push";
          f = "fetch";
          sh = "show";
        };
        core.editor = "nvim";
        color.ui = "auto";
        pull.rebase = true;
      };
    };
  };

  flake.nixosModules.global = { pkgs, ... }: {
    imports = [
      # At least make home manager available
      inputs.home-manager.nixosModules.home-manager
      inputs.agenix.nixosModules.default
    ];

    environment.systemPackages = with pkgs; [
      # Make the home manager command available
      pkgs.home-manager
      inputs.agenix.packages."${system}".default
      comma
      podman-compose
      btrfs-progs
    ];

    nixpkgs.overlays = [
      # Replace openssl with libressl
      (final: super: { 
        nginxStable = super.nginxStable.override { openssl = super.pkgs.libressl; }; 
      })
    ];

    # Global nix settings
    nix.settings = {
      # Enable Flakes
      experimental-features = [ "flakes" "nix-command" ];
      # Cachix
      substituters = [
        "https://hyprland.cachix.org"
        # Needed for CUDA
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        # Needed for CUDA
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;
    # This program is sooo good, I want it everywhere
    programs.nh.enable = true;

    ## Podman
    virtualisation = {
      podman = {
        enable = true;

        # Create a `docker` alias for podman, to use it as a drop-in replacement
        dockerCompat = true;

        # Required for containers under podman-compose to be able to talk to each other.
        defaultNetwork.settings.dns_enabled = true;
      };
      # Virtualbox
      #virtualbox.host.enable = true;
    };
    #virtualisation.docker = {
    #  enable = false;
    #  rootless = {
    #    enable = true;
    #    setSocketVariable = true;
    #  };
    #};
    };
}

