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
    home.file.".config/nvim/undodir/gamnangstyle".text = "whop\n";
    # Neovim filetype specific configs
    home.file.".config/nvim/ftplugin/gdscript.lua".source = ./ftplugin/gdscript.lua;
    home.file.".config/nvim/ftplugin/html.lua".source = ./ftplugin/html.lua;
    home.file.".config/nvim/snippets/cs.lua".source = ./snippets/cs.lua;

    # LSP packages
    home.packages = with pkgs; [
      # HTML / CSS / JSON / ESLint language server
      vscode-langservers-extracted

      # C / C++
      ccls          # A C/C++ language server

      # Haskell
      haskell-language-server

      # Nix??? 😲
      nil  # Nix language server

      # Rust
      rustfmt
      rust-analyzer # Rust language server

      # Lua
      lua-language-server

      # Go
      gopls

      # Agda
      (agda.withPackages [ agdaPackages.standard-library ])

      # Typst
      typst-lsp

      # WGSL
      inputs.wgsl_analyzer.packages.${system}.default

      # C#
      omnisharp-roslyn

      # Erlang
      erlang-ls
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
      ];
      extraLuaConfig = ''
-- Neovim configuration
vim.g.mapleader = ' '

-- Load filetype specific configurations
vim.cmd('filetype plugin on')
vim.cmd('filetype indent plugin on')

-- Theme / Colorscheme
--vim.cmd.colorscheme("catppuccin-macchiato")

-- Treesitter setup
require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
}

-- Add WGSL filetype
vim.filetype.add({extension = {wgsl = "wgsl"}})

-- Universal run
vim.keymap.set('n', '<leader>rr', '<cmd>belowright split term://bash ./run.sh<cr>')

-- Vimwiki
vim.g.vimwiki_list = {{path = '~/vimwiki/', syntax = 'markdown', ext = '.md'}}

-- Telescope
-- Only files visible to git
vim.keymap.set('n', '<leader>ff', '<cmd>Telescope git_files<cr>')
-- All files
vim.keymap.set('n', '<leader>fv', '<cmd>Telescope find_files<cr>')
vim.keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<cr>')
vim.keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<cr>')
vim.keymap.set('n', '<leader>fh', '<cmd>Telescope help_tags<cr>')

-- Buffers
vim.keymap.set('n', '<leader>bn', '<cmd>bnext<cr>')
vim.keymap.set('n', '<leader>bp', '<cmd>bprevious<cr>')
vim.keymap.set('n', '<leader>bd', '<cmd>bdelete<cr>')

-- Insert a tab with Shift-Tab in insert mode
vim.keymap.set('i', '<S-Tab>', '<C-V><Tab>')

-- Settings
vim.opt.tabstop = 4                   -- Tab length
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true              -- Use spaces instead of tabs
vim.o.colorcolumn = '78'              -- Line-has-gone-too-far indicator to the right
vim.opt.wrap = true                   -- Line wrap/break at word
vim.opt.linebreak = true
vim.opt.title = true                  -- Show file and path in window-title
vim.opt.number = true                 -- Current line number one column to the left, numbers above and below are relative
vim.opt.relativenumber = true
vim.opt.autoindent = true             -- Autoindent for non recognicable files
vim.opt.timeoutlen = 500              -- Space delay
vim.opt.incsearch = true              -- Good search highlighting
vim.opt.clipboard = "unnamedplus"     -- Set clipboard to system's
vim.opt.secure = true                 -- Secure files yes
vim.opt.ignorecase = true             -- Case insensitive search when no caps
vim.opt.smartcase = true

-- Eternal undo
vim.opt.swapfile = false  -- No backup/swap files
vim.opt.backup = false
vim.opt.undodir = '/home/rakarake/.config/nvim/undodir/'
vim.opt.undofile = true

-- Clear highlighting and everything at bottom
vim.keymap.set('n', '<leader>p', '<cmd>nohlsearch<Bar>:echo<cr>')

-- Toggleterm
local toggleterm = require("toggleterm").setup {
    size = vim.o.columns * 0.45,
    direction = 'vertical', 
    open_mapping = [[<C-P>]],
    hide_numbers = true, -- hide the number column in toggleterm buffers
    shade_filetypes = {},
    shading_factor = 0,
    autochdir = false, -- when neovim changes it current directory the terminal will change it's own when next it's opened
    start_in_insert = true,
    insert_mappings = true, -- whether or not the open mapping applies in insert mode
    terminal_mappings = true, -- whether or not the open mapping applies in the opened terminals
    persist_size = true,
    persist_mode = true, -- if set to true (default) the previous terminal mode will be remembered
    close_on_exit = true, -- close the terminal window when the process exits
    auto_scroll = true, -- automatically scroll to the bottom on terminal output
    -- This field is only relevant if direction is set to 'float'
    winbar = {
        enabled = false,
        name_formatter = function(term) --  term: Terminal
            return term.name
        end
    },
}
-- Go to left window in terminal mode
vim.keymap.set('t', '<C-w>h', "<C-\\><C-n><C-w>h",{silent = true})

-- LSP Configuration
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<space>ro', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<space>fm', vim.lsp.buf.formatting, bufopts)
end
local lsp_flags = {
  -- This is the default in Nvim 0.7+
  debounce_text_changes = 150,
}

-- luasnip setup
local luasnip = require 'luasnip'

require("luasnip.loaders.from_lua").lazy_load({ paths = "~/.config/nvim/snippets" })

-- nvim-cmp configuration
-- Add additional capabilities supported by nvim-cmp
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities()
-- nvim-cmp setup
local cmp = require 'cmp'
cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<C-n>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<C-p>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}

--Enable (broadcasting) snippet capability for completion
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

-- Individual language server setup

-- HTML
require'lspconfig'.html.setup {
    capabilities = capabilities,
    on_attach = on_attach,
    flags = lsp_flags,
}

-- CSS
require'lspconfig'.cssls.setup {
    capabilities = capabilities,
    on_attach = on_attach,
    flags = lsp_flags,
}

-- Javascript
require'lspconfig'.eslint.setup{
    capabilities = capabilities,
    on_attach = on_attach,
    flags = lsp_flags,
}

-- C/C++
require'lspconfig'.ccls.setup{
    capabilities = capabilities,
    on_attach = on_attach,
    flags = lsp_flags,
}

-- Rust
require'lspconfig'.rust_analyzer.setup{
    capabilities = capabilities,
    on_attach = on_attach,
    flags = lsp_flags,
    -- Server-specific settings...
    settings = {
      ["rust-analyzer"] = {}
    }
}

-- Haskell
require'lspconfig'.hls.setup{
    capabilities = capabilities,
    on_attach = on_attach,
    flags = lsp_flags,
    filetypes = { 'haskell', 'lhaskell', 'cabal' },
}

-- GDScript
require'lspconfig'.gdscript.setup{
    capabilities = capabilities,
    on_attach = on_attach,
    flags = lsp_flags,
}

-- Java
require'lspconfig'.jdtls.setup{
     capabilities = capabilities,
     on_attach = on_attach,
     flags = lsp_flags,
 }

-- Nix
require'lspconfig'.nil_ls.setup{
     capabilities = capabilities,
     on_attach = on_attach,
     flags = lsp_flags,
}

-- Go
require'lspconfig'.gopls.setup{
     capabilities = capabilities,
     on_attach = on_attach,
     flags = lsp_flags,
}

-- WGSL
require'lspconfig'.wgsl_analyzer.setup{
     capabilities = capabilities,
     on_attach = on_attach,
     flags = lsp_flags,
}

-- Typst
require'lspconfig'.typst_lsp.setup{
     capabilities = capabilities,
     on_attach = on_attach,
     flags = lsp_flags,
}

-- Erlang
require'lspconfig'.erlangls.setup{
     capabilities = capabilities,
     on_attach = on_attach,
     flags = lsp_flags,
}

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

-- Catppuccin theme integrations
--require("catppuccin").setup({
--    integrations = {
--        --cmp = true,
--        --gitsigns = true,
--        --nvimtree = true,
--        telescope = true,
--        --notify = false,
--        --mini = false,
--    }
--})
      '';
    };
  };
}
