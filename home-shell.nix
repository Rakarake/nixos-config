{ ... }: {
  # Generic shell options
  home.file.".alias".source = ./.alias;
  # Bash config
  home.file.".bashrc".source = ./.bashrc;
  # ZSH config
  home.file.".zshrc".source = ./.zshrc;
}
