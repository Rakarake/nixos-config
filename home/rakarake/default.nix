# Root of my home-manager config, enable either desktop or server
# to get nice stuff.
# Choose a desktop such as gnome or kde.
{ lib, outputs, config, pkgs, self, user, hostname, inputs, ... }:
let
  environmentVariables = {
    EDITOR = lib.mkForce "${config.home-xdg.text-editor.bin}";
    VISUAL = "nvim";
    BROWSER = config.home-xdg.browser.bin;
    MANPAGER= "nvim +Man!";
    # Enable wayland for qt and electron by default, just unset to use default
    QT_QPA_PLATFORM = "wayland";
    NIXOS_OZONE_WL = "1";
  };
  # Custom packages defined in the toplevel flake
  cpkgs = outputs.packages.${pkgs.system};
in
{
  nixpkgs.config.allowUnfree = true;
  imports = [
    ./desktop.nix
    ./server.nix
    ./gnome.nix
    ./hyprland
    ./neovim
    ./rofi
    ./dwl
    ./river
    ./grompt
    ./bash.nix
    inputs.nix-index-database.hmModules.nix-index
    inputs.stylix.homeModules.stylix
    inputs.catppuccin.homeModules.catppuccin
    inputs.xremap.homeManagerModules.default
  ];
  # Follow the rules!
  services.xremap.enable = lib.mkDefault false;
  home.stateVersion = "23.05";

  # Bash config
  home-bash.enable = true;

  # Btop
  programs.btop.enable = true;

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

    # My scripts
    cpkgs.amogus
    cpkgs.simple-shell-utils
  ];

  home-neovim.enable = true;

  # Shell aliases
  home.shellAliases = {
    g = "git";
    e = "nvim";
    b = config.home-xdg.browser.bin;
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
    nd = "nix develop";
    rebuild = "${pkgs.nh}/bin/nh os switch .";
    rebuildboot = "${pkgs.nh}/bin/nh os boot .";
    homebuild = "${pkgs.nh}/bin/nh home switch -c ${user}@${hostname}-default .";
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
      #set -g status off

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
}

