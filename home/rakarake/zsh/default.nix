{
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    history.size = 50000;
    history.ignoreAllDups = true;
    history.path = "$HOME/.zsh_history";
    plugins = [
      {
        name = "zsh-vim-mode";
        src = ./.;
        file = "zsh-vim-mode.plugin.zsh";
      }
    ];
    localVariables = {
      PS1="%F{blue}%B%1~ $ %b%f";
      RPS1="";
      KEYTIMEOUT="1";
      MODE_CURSOR_VIINS="blinking bar";
      MODE_CURSOR_REPLACE="block";
      MODE_CURSOR_VICMD="block";
      MODE_CURSOR_SEARCH="steady underline";
      MODE_CURSOR_VISUAL="$MODE_CURSOR_VICMD steady bar";
      MODE_CURSOR_VLINE="$MODE_CURSOR_VISUAL";
    };
    profileExtra = ''
      # :q to exit
      :q() {
        exit
      }
    '';
  };
}
