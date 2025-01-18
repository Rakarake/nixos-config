{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.home-neovim;
in
{
  options.home-neovim = {
    enable = lib.mkEnableOption "My super duper cool neovim config";
  };

  config = lib.mkIf cfg.enable {
    # Make sure undodir exists
    xdg.configFile."nvim/undodir/gamnangstyle".text = "whop\n";
    # Neovim filetype specific configs
    xdg.configFile."nvim/ftplugin/gdscript.lua".source = ./ftplugin/gdscript.lua;
    xdg.configFile."nvim/ftplugin/html.lua".source = ./ftplugin/html.lua;
    xdg.configFile."nvim/snippets/cs.lua".source = ./snippets/cs.lua;

    # LSP packages
    home.packages = with pkgs; [
      ripgrep                        # Needed for telescope's grep functionality
      vscode-langservers-extracted   # HTML / CSS / JSON / ESLint language server
      ccls                           # A C/C++ language server # C / C++
      haskell-language-server        # Haskell
      nil                            # Nix??? 😲
      rustfmt                        # Rust
      rust-analyzer                  # Rust language server
      lua-language-server            # Lua
      gopls                          # Go
      (agda.withPackages [ agdaPackages.standard-library ]) # Agda
      tinymist                                              # Typst
      inputs.wgsl_analyzer.packages.${system}.default       # WGSL
      omnisharp-roslyn                                      # C#
      erlang-ls                                             # Erlang
      pyright                                               # Python
    ];

    # Neovim config
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      plugins = with pkgs.vimPlugins; [
        nvim-lspconfig
        nvim-treesitter.withAllGrammars
        plenary-nvim
        telescope-nvim
        #catppuccin-nvim  # Theme
        toggleterm-nvim
        vimwiki
        typst-vim
        # LSP
        nvim-lspconfig
        nvim-cmp
        cmp-nvim-lsp
        luasnip
        editorconfig-vim
        # DAP
        nvim-dap
        telescope-dap-nvim
        # Other
        mini-nvim            # MANY THINGS
        # Oil
        oil-nvim
        # Rust
        rustaceanvim
      ];
      extraLuaConfig = builtins.readFile ./config.lua + ''
-- C# LSP support
require'lspconfig'.omnisharp.setup {
     capabilities = capabilities,
     on_attach = on_attach,
     flags = lsp_flags,
     cmd = { "dotnet", "${pkgs.omnisharp-roslyn}/lib/omnisharp-roslyn/OmniSharp.dll" },

     -- Enables support for reading code style, naming convention and analyzer
     -- settings from .editorconfig.
     enable_editorconfig_support = true,

     -- If true, MSBuild project system will only load projects for files that
     -- were opened in the editor. This setting is useful for big C# codebases
     -- and allows for faster initialization of code navigation features only
     -- for projects that are relevant to code that is being edited. With this
     -- setting enabled OmniSharp may load fewer projects and may thus display
     -- incomplete reference lists for symbols.
     enable_ms_build_load_projects_on_demand = false,

     -- Enables support for roslyn analyzers, code fixes and rulesets.
     enable_roslyn_analyzers = false,

     -- Specifies whether 'using' directives should be grouped and sorted during
     -- document formatting.
     organize_imports_on_format = false,

     -- Enables support for showing unimported types and unimported extension
     -- methods in completion lists. When committed, the appropriate using
     -- directive will be added at the top of the current file. This option can
     -- have a negative impact on initial completion responsiveness,
     -- particularly for the first few completion sessions after opening a
     -- solution.
     enable_import_completion = false,

     -- Specifies whether to include preview versions of the .NET SDK when
     -- determining which version to use for project loading.
     sdk_include_prereleases = true,

     -- Only run analyzers against open files when 'enableRoslynAnalyzers' is
     -- true
     analyze_open_documents_only = false,
}
      '';
    };
  };
}
