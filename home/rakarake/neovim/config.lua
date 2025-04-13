-- Neovim configuration

-- Leader key
vim.g.mapleader = ' '

-- Load filetype specific configurations
vim.cmd('filetype plugin on')
vim.cmd('filetype indent plugin on')

-- Theme / Colorscheme
--vim.cmd.colorscheme("catppuccin-macchiato")
vim.cmd.colorscheme "catppuccin"

-- Treesitter setup
require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
}

-- Add WGSL filetype
vim.filetype.add({extension = {wgsl = "wgsl"}})

-- Vimwiki
vim.g.vimwiki_list = {{path = '~/Notes/', syntax = 'markdown', ext = '.md'}}
vim.g.vimwiki_global_ext = 0
-- use telescope to find vimwiki pages
vim.keymap.set('n', '<leader>fww', function() require'telescope.builtin'.find_files({ cwd = '~/Notes/', prompt_title = 'vimwiki' }) end)
vim.keymap.set('n', '<leader>fwg', function() require'telescope.builtin'.live_grep({ cwd = '~/Notes/', prompt_title = 'vimwiki' }) end)

-- Telescope
require'telescope'.setup()
-- Enalbe DAP integration
require'telescope'.load_extension('dap')
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
vim.keymap.set('n', '<leader>bf', '<cmd>e %:h<cr>', {silent = true})

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
local toggleterm = require'toggleterm'.setup {
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
vim.keymap.set('t', '<C-n>', "<C-\\><C-n>",{silent = true})

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
  --vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  --local bufopts = { noremap=true, silent=true, buffer=bufnr }
  --vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  --vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  --vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  --vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  --vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  --vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  --vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  --vim.keymap.set('n', '<space>wl', function()
  --  print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  --end, bufopts)
  --vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
  --vim.keymap.set('n', '<space>ro', vim.lsp.buf.rename, bufopts)
  --vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  --vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  --vim.keymap.set('n', '<space>fm', vim.lsp.buf.formatting, bufopts)
end
local lsp_flags = {
  -- This is the default in Nvim 0.7+
  debounce_text_changes = 150,
}

-- luasnip setup
local luasnip = require'luasnip'

require'luasnip.loaders.from_lua'.lazy_load({ paths = "~/.config/nvim/snippets" })

-- Enable built in completion
--vim.api.nvim_create_autocmd('LspAttach', {
--  callback = function(ev)
--    local client = vim.lsp.get_client_by_id(ev.data.client_id)
--    if client:supports_method('textDocument/completion') then
--      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
--    end
--  end,
--})
---- taken from: https://codeberg.org/zacoons/.dotfiles/src/branch/master/.config/nvim/lua/config/lazy.lua
---- see `:h completeopt`
--vim.opt.completeopt="menuone,noselect,popup,fuzzy"
---- map <c-space> to activate completion, (normaly <c-x><c-o>)
--vim.keymap.set("i", "<c-space>", function() vim.lsp.completion.get() end)
---- map <cr> to <c-y> when the popup menu is visible
--vim.keymap.set("i", "<cr>", "pumvisible() ? '<c-y>' : '<cr>'", { expr = true })


--Enable (broadcasting) snippet capability for completion
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

-- Built in neovim lsp config, for the peice of mind
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = false,
    signs = true,
    update_in_insert = false,
    underline = false,
    border = "single",
    severity_sort = true,
})

local default = {
    capabilities = capabilities,
    on_attach = on_attach,
    flags = lsp_flags,
}

-- Individual language server setup
-- HTML
require'lspconfig'.html.setup(default)

-- CSS
require'lspconfig'.cssls.setup(default)

-- Javascript
require'lspconfig'.eslint.setup(default)

-- C/C++
require'lspconfig'.ccls.setup(default)

---- Rust
--require'lspconfig'.rust_analyzer.setup {
--    capabilities = capabilities,
--    on_attach = on_attach,
--    flags = lsp_flags,
--    -- Server-specific settings...
--    settings = {
--      ["rust-analyzer"] = {}
--    },
--    commands = {
--        ExpandMacro = {
--            function()
--                vim.lsp.buf_request_all(0, "rust-analyzer/expandMacro", vim.lsp.util.make_position_params(), vim.print)
--            end
--        },
--    },
--}

-- Haskell
require'lspconfig'.hls.setup {
    capabilities = capabilities,
    on_attach = on_attach,
    flags = lsp_flags,
    filetypes = { 'haskell', 'lhaskell', 'cabal' },
}

-- Python
require'lspconfig'.pyright.setup(default)

-- GDScript
require'lspconfig'.gdscript.setup(default)

-- Java
require'lspconfig'.jdtls.setup(default)

-- Nix
require'lspconfig'.nil_ls.setup(default)

-- Go
require'lspconfig'.gopls.setup(default)

-- WGSL
require'lspconfig'.wgsl_analyzer.setup(default)

-- Typst
require'lspconfig'.tinymist.setup(default)

-- Erlang
require'lspconfig'.erlangls.setup(default)



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

-- DAP (Debug Adapter Protocol)
vim.keymap.set('n', '<space>db', require'dap'.toggle_breakpoint, opts)
vim.keymap.set('n', '<space>dc', require'dap'.continue, opts)
vim.keymap.set('n', '<space>ds', require'dap'.step_over, opts)
vim.keymap.set('n', '<space>di', require'dap'.step_into, opts)
vim.keymap.set('n', '<space>dr', require'dap'.repl.open, opts)

-- Godot
local dap = require('dap')
dap.adapters.godot = {
  type = "server",
  host = '127.0.0.1',
  port = 6006,
}
dap.configurations.gdscript = {
  {
    type = "godot",
    request = "launch",
    name = "Launch scene",
    project = "${workspaceFolder}",
  }
}

-- mini libraries
require'mini.icons'.setup()
require'mini.align'.setup()
require'mini.move'.setup()
require'mini.surround'.setup()
require'mini.completion'.setup()

-- Oil
require'oil'.setup({
  keymaps = {
    ["<BS>"] = { "actions.parent", mode = "n" },
  }
})
vim.keymap.set('n', '<space>od', require"oil".open, opts)

-- Hex editor
vim.keymap.set("n", "<leader>hr", "<cmd>%! xxd<CR><cmd>set filetype=xxd<CR>")
-- Using marks, does not work
--vim.keymap.set("n", "<leader>hw", "mx<cmd>%! xxd -r<CR><cmd>w<CR><cmd>%! xxd<CR>'x")
local write_hex = function ()
    local win = vim.api.nvim_get_current_win()
    local pos = vim.api.nvim_win_get_cursor(win)
    vim.cmd("%!xxd -r")
    vim.cmd("w")
    vim.cmd("%!xxd")
    vim.api.nvim_win_set_cursor(win, pos)
end

vim.keymap.set("n", "<leader>hw", write_hex)

