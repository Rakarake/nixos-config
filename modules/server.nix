{ pkgs, ...}: {
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

    # Python
    python3
    # Java
    jdk17
  ];

}
