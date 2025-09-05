{
  programs.emacs = {
    enable = true;
    extraPackages = epkgs: with epkgs; [
      agda2-mode
    ];
    extraConfig = ''
      (load-file (let ((coding-system-for-read 'utf-8))
                 (shell-command-to-string "agda-mode locate"))
      )
    '';
  };
}
