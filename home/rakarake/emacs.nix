{ pkgs, ... }: {
  programs.emacs = {
    enable = true;
    package = pkgs.emacs-pgtk;
    extraPackages = epkgs: with epkgs; [
      evil
      evil-collection
      ivy
      eat

      agda2-mode
    ];
    extraConfig = ''
      ; Hide UI garbage
      (menu-bar-mode 0)
      (tool-bar-mode 0)
      (scroll-bar-mode 0)
      (add-to-list 'default-frame-alist '(undecorated . t))

      ; Agda mode
      (load-file (let ((coding-system-for-read 'utf-8))
                 (shell-command-to-string "agda-mode locate"))
      )

      ; Normal? copy-paste
      (setq x-select-enable-clipboard t)
      (setq evil-want-yank-to-clipboard t)
      (setq evil-want-C-y-to-clipboard t)

      ; Evil mode
      (evil-mode 1)
      
      ; Ivy mode: completion
      (ivy-mode 1)
    '';
  };
}
