-- Neovim configuration
vim.g.mapleader = ' '

-- Theme / Colorscheme
vim.cmd.colorscheme("catppuccin-macchiato")

-- Treesitter setup
require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
}

-- Universal run
vim.keymap.set('n', '<leader>rr', '<cmd>belowright split term://bash ./run.sh<cr>')

-- Vimwiki
vim.cmd('filetype plugin on')
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
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
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


-- Catppuccin theme integrations
require("catppuccin").setup({
    integrations = {
        --cmp = true,
        --gitsigns = true,
        --nvimtree = true,
        telescope = true,
        --notify = false,
        --mini = false,
    }
})
