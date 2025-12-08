-- Neovim configuration

-- Leader key
vim.g.mapleader = ' '

-- Load filetype specific configurations
vim.cmd('filetype plugin on')
vim.cmd('filetype indent plugin on')

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

-- undotree
vim.keymap.set('n', '<leader>ut', vim.cmd.UndotreeToggle)

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
vim.opt.scrolloff = 7                 -- The space below search result

-- Eternal undo
vim.opt.swapfile = false  -- No backup/swap files
vim.opt.backup = false
vim.opt.undodir = '/home/rakarake/.config/nvim/undodir/'
vim.opt.undofile = true

-- Clear highlighting and everything at bottom
vim.keymap.set('n', '<leader>p', '<cmd>nohlsearch<Bar>:echo<cr>')

-- Toggleterm
local toggleterm_opts = {
    size = vim.o.columns * 0.45,
    direction = 'vertical', 
    hide_numbers = true, -- hide the number column in toggleterm buffers
    shade_filetypes = {},
    shade_terminals = false,
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

local Terminal = require("toggleterm.terminal").Terminal

-- Default behaviour.
vim.keymap.set("n", "<C-P>", function()
  local dir = vim.fn.getcwd()
  toggleterm_opts["dir"] = dir
  Terminal:new(toggleterm_opts):toggle()
end)
vim.keymap.set("t", "<C-P>", function()
  Terminal:new(toggleterm_opts):toggle()
end)


-- Open in dir of current file.
vim.keymap.set("n", "<leader>th", function()
  local dir = vim.fn.expand("%:p:h")
  toggleterm_opts["dir"] = dir
  Terminal:new(toggleterm_opts):toggle()
end)

-- Go to left window in terminal mode
vim.keymap.set('t', '<C-w>h', "<C-\\><C-n><C-w>h",{silent = true})
vim.keymap.set('t', '<C-n>', "<C-\\><C-n>",{silent = true})

--local toggle_buffer = nil
--vim.keymap.set('n', '<C-p>', function()
--    local dir = vim.fn.expand("%:p:h")
--    vim.cmd(string.format(
--      "terminal bash -c 'cd %s && exec bash'",
--      dir
--    ))
--    vim.cmd("startinsert")
--    toggle_buffer = vim.cmd("echo bufnr('%')")
--end)
--
--vim.keymap.set('t', '<C-p>', function()
--    vim.cmd("bp")
--end)
---- No close message when closing terminal buffer
--vim.api.nvim_create_autocmd("TermClose", {
--  pattern = "*",
--  callback = function()
--    vim.cmd("bd!")
--  end,
--})

-- LSP Configuration
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)
vim.keymap.set('n', '<space>re', vim.lsp.buf.rename, opts)

-- Turn on/off highlighting
lsp_is_alive = true
vim.keymap.set('n', '<leader>ld', function()
    lsp_is_alive = not lsp_is_alive
    vim.diagnostic.config({
        signs=lsp_is_alive,
        severity_sort = lsp_is_alive,
        underline=lsp_is_alive,
        virtual_text=false,
        virtual_lines=false,
    })
end)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)

  --=-- Format on save if lsp supports it
  --=if client.supports_method("textDocument/formatting") then
  --=  vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
  --=  vim.api.nvim_create_autocmd("BufWritePre", {
  --=    group = augroup,
  --=    buffer = bufnr,
  --=    callback = function()
  --=      vim.lsp.buf.format()
  --=    end,
  --=  })
  --=end

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

-- luasnip setup
local luasnip = require'luasnip'
require'luasnip.loaders.from_lua'.lazy_load({ paths = "~/.config/nvim/snippets" })

--Enable (broadcasting) snippet capability for completion
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

local default = {
    capabilities = capabilities,
    on_attach = on_attach,
}

local lsps_with_default_config = {
    'html',
    'cssls',
    'eslint',
    'ccls',
    'pyright',
    'gdscript',
    'gdshader_lsp',
    'jdtls',
    'nil_ls',
    'gopls',
    'wgsl_analyzer',
    'tinymist',
    'erlangls',
    'zls',
    'hls',
}

-- Finally enable LSP:s
for i, lsp in ipairs(lsps_with_default_config) do
    vim.lsp.config(lsp, default)
    vim.lsp.enable(lsp)
end

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
require'mini.operators'.setup()
local miniclue = require('mini.clue')
miniclue.setup({
  triggers = {
    -- Leader triggers
    { mode = 'n', keys = '<Leader>' },
    { mode = 'x', keys = '<Leader>' },

    -- Built-in completion
    { mode = 'i', keys = '<C-x>' },

    -- `g` key
    { mode = 'n', keys = 'g' },
    { mode = 'x', keys = 'g' },

    -- Marks
    { mode = 'n', keys = "'" },
    { mode = 'n', keys = '`' },
    { mode = 'x', keys = "'" },
    { mode = 'x', keys = '`' },

    -- Registers
    { mode = 'n', keys = '"' },
    { mode = 'x', keys = '"' },
    { mode = 'i', keys = '<C-r>' },
    { mode = 'c', keys = '<C-r>' },

    -- Window commands
    { mode = 'n', keys = '<C-w>' },

    -- `z` key
    { mode = 'n', keys = 'z' },
    { mode = 'x', keys = 'z' },
  },

  clues = {
    -- Enhance this by adding descriptions for <Leader> mapping groups
    miniclue.gen_clues.builtin_completion(),
    miniclue.gen_clues.g(),
    miniclue.gen_clues.marks(),
    miniclue.gen_clues.registers(),
    miniclue.gen_clues.windows(),
    miniclue.gen_clues.z(),
  },
})

-- Autocompletion engine for LSP and other things
require'blink.cmp'.setup({
    keymap = {
        preset = 'default',
        ['<Tab>'] = { 'select_and_accept', 'fallback' },
        ['<C-l>'] = { 'show_documentation', 'fallback' },
        ['<C-h>'] = { 'hide_documentation', 'fallback' },
        ['<C-j>'] = { 'scroll_documentation_down', 'fallback' },
        ['<C-k>'] = { 'scroll_documentation_up', 'fallback' },
    },
    appearance = {
      nerd_font_variant = 'mono'
    },
    completion = { documentation = { auto_show = false } },
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
    },
    fuzzy = { implementation = "prefer_rust_with_warning" },
    -- Experimental feature (signatures: when starting writing a function)
    signature = { enabled = true }
})

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


-- ':HC' to open manpage in current buffer.
vim.cmd([[
	command -bar -nargs=? -complete=help HC execute s:HC(<q-args>)
	let s:did_open_help = v:false

	function s:HC(subject) abort
	  let mods = 'silent noautocmd keepalt'
	  if !s:did_open_help
	    execute mods .. ' help'
	    execute mods .. ' helpclose'
	    let s:did_open_help = v:true
	  endif
	  if !empty(getcompletion(a:subject, 'help'))
	    execute mods .. ' edit ' .. &helpfile
	    set buftype=help
	  endif
	  return 'help ' .. a:subject
	endfunction
]])

-- Harpoon
local harpoon = require("harpoon")
harpoon:setup()

-- Add to list
vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
vim.keymap.set("n", "<leader>y", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

vim.keymap.set("n", "<C-1>", function() harpoon:list():select(1) end)
vim.keymap.set("n", "<C-2>", function() harpoon:list():select(2) end)
vim.keymap.set("n", "<C-3>", function() harpoon:list():select(3) end)
vim.keymap.set("n", "<C-4>", function() harpoon:list():select(4) end)

-- Theme / Colorscheme
--vim.cmd.colorscheme("catppuccin-macchiato")
--vim.cmd.colorscheme "catppuccin"

-- Let rustaceanvim use keybinds etc
vim.g.rustaceanvim = {
  -- Plugin configuration
  tools = {
  },
  -- LSP configuration
  server = {
    -- Share on_attach with other LSP:s
    on_attach = on_attach,
    default_settings = {
      -- rust-analyzer language server configuration
      ['rust-analyzer'] = {
      },
    },
  },
  -- DAP configuration
  dap = {
  },
}
