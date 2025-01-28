{ lib, config, pkgs, self, user, hostname, ... }:
let
  cfg = config.home-common;
in
{
  imports = [
    ./bash.nix
  ];

  options.home-common = {
    enable = lib.mkEnableOption "The basics of being rakarake";
  };

  config = lib.mkIf cfg.enable {
    home.username = "rakarake";
    home.homeDirectory = "/home/rakarake";
    home.stateVersion = "23.05";
    programs.home-manager.enable = true;

    # Bash config
    home-bash.enable = true;

    # Session variables
    systemd.user.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      BROWSER = "firefox";
      MANPAGER= "nvim +Man!";
    };

    # Shell aliases
    home.shellAliases = {
      g = "git";
      e = "nvim";
      b = "firefox";
      open = "xdg-open";
      "\":q\"" = "exit";
      "\"..\"" = "cd ..";
      cp = "cp -v";
      mv = "mv -v";
      rm = "rm -v";
      ncmpcpp = "echo 'trying mpd: ' ; mpd ; ncmpcpp";
      bat = "bat --theme=base16";
      die = "sudo shutdown now";
      ks = "kitten ssh";

      # Swag
      uwu = "${pkgs.fastfetch}/bin/fastfetch --logo ${self}/home/rakarake/sillyascii";
      
      # Projects
      p = "cd ~/Projects";
      
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
      n = "cd ~/Projects/nixos-config";
      flake = "nix flake";
      nd = "nix develop";
      rebuild = "${pkgs.nh}/bin/nh os switch .";
      rebuildboot = "${pkgs.nh}/bin/nh os boot .";
      homebuild = "${pkgs.nh}/bin/nh home switch -c ${user}@${hostname} .";
      lightbuild = "${pkgs.nh}/bin/nh home switch -c ${user}@${hostname}-light .";
      darkbuild = "${pkgs.nh}/bin/nh home switch -c ${user}@${hostname}-dark .";
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
        set -g status off
      '';
    };

    # Git config
    programs.git = {
      enable = true;
      lfs.enable = true;
      userName  = "Rakarake";
      userEmail = "raka@rakarake.xyz";
      extraConfig = {
        core = {
          editor = "nvim";
        };
        color = {
          ui = "auto";
        };
        user = {
          signingKey = "98CF6C24F40B3531!";
        };
        pull = {
          rebase = false;
        };
      };
      aliases = {
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
    };
  };
}
