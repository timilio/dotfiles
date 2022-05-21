-- Load filetypes using Lua
vim.g.did_load_filetypes = 0
vim.g.do_filetype_lua    = 1

-- =============== QUICK CONFIG =================
local treesitters = { 'fish', 'lua', 'rust', 'toml', 'haskell', 'python' }
local lsps        = { 'rust_analyzer' }
local colorscheme = 'onenord'
vim.o.background  = 'light'

-- ================= PLUGINS ====================
local Plug = vim.fn['plug#']
vim.call('plug#begin')

-- Colorschemes
Plug('sainnhe/everforest')       -- everforest
Plug('sainnhe/gruvbox-material') -- gruvbox-material
Plug('rmehri01/onenord.nvim')    -- onenord
Plug('rebelot/kanagawa.nvim')    -- kanagawa

-- Vim improvements
Plug('ggandor/leap.nvim')
Plug('tpope/vim-repeat') -- For leap.nvim
Plug('echasnovski/mini.nvim', { branch = 'stable' })
Plug('rhysd/clever-f.vim')
Plug('junegunn/vim-easy-align')

-- Fuzzy find
Plug('/usr/local/opt/fzf')
Plug('junegunn/fzf.vim')

-- Linting
Plug('neovim/nvim-lspconfig')
Plug('williamboman/nvim-lsp-installer')
Plug('ms-jpq/coq_nvim', { branch = 'coq', ['do'] = 'python3 -m coq deps' })
-- Plug('nvim-lua/lsp_extensions.nvim') -- Inlay type hints for Rust (requires nvim 0.8.0+)

-- Syntax
Plug('nvim-treesitter/nvim-treesitter', { ['do'] = ':TSUpdate' })
Plug('rust-lang/rust.vim') -- Rust auto-formatting
Plug('sevko/vim-nand2tetris-syntax')

-- GUI improvements
Plug('nvim-lualine/lualine.nvim')

vim.call('plug#end')

-- ================= GENERAL SETTINGS =====================
local set = vim.opt

set.shell          = '/bin/sh'
set.number         = true
set.relativenumber = true
set.undofile       = true
set.showmatch      = false
set.modeline       = false
set.scrolloff      = 5
-- set.signcolumn     = "yes" -- Stop flickering lsp diagnostics
set.shortmess:append('c')

-- Tabs (expand to 4 spaces)
set.shiftwidth  = 4
set.tabstop     = 4
set.softtabstop = 4
set.expandtab   = true

-- Better searching
set.ignorecase = true
set.smartcase  = true

-- GUI and colorscheme
vim.g.gruvbox_material_background         = 'hard'
vim.g.gruvbox_material_better_performance = 1
vim.g.everforest_background               = 'hard'
vim.g.everforest_better_performance       = 1

set.showcmd       = false
set.showmode      = false -- Do not show vim mode, because I have statusline plugin
set.termguicolors = true
vim.cmd('colorscheme ' .. colorscheme)

-- ================== PLUGIN SETUP ====================

-- Leap.nvim
require('leap').set_default_keymaps()

-- Mini.nvim setup
require('mini.surround').setup({
    mappings = {
        add            = 'ys', -- Add surrounding in Normal and Visual modes
        delete         = 'ds', -- Delete surrounding
        replace        = 'cs', -- Replace surrounding
        highlight      = '', -- Highlight surrounding
        find           = '', -- Find surrounding (to the right)
        find_left      = '', -- Find surrounding (to the left)
        update_n_lines = '', -- Update `n_lines`
    },
})
require('mini.comment').setup()
require('mini.starter').setup()

-- Lualine
local function wordcount()
    local dict = vim.fn.wordcount()
    return dict.visual_words or dict.words
end

require('lualine').setup {
    options = {
        icons_enabled        = true,
        theme                = colorscheme,
        component_separators = '',
        section_separators   = '',
        disabled_filetypes   = {},
        always_divide_middle = true,
        globalstatus         = true,
    },
    sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'diagnostics' },
        lualine_c = { 'filename' },
        lualine_x = { wordcount, 'encoding', 'fileformat', 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' }
    },
}

-- Treesitter syntax highlighting
require('nvim-treesitter.configs').setup {
    ensure_installed = treesitters,
    highlight = {
        enable = true,
    },
}

-- Rust formatting
vim.g.rustfmt_autosave      = 1
vim.g.rustfmt_emit_files    = 1
vim.g.rustfmt_fail_silently = 0

-- Lsp Installer (setup before LspConfig!)
require("nvim-lsp-installer").setup({
    automatic_installation = true,
    ui = {
        icons = {
            server_installed = "✓",
            server_pending = "➜",
            server_uninstalled = "✗"
        }
    }
})

-- LspConfig
local map = vim.api.nvim_set_keymap
local opts = { noremap=true, silent=true }
map('n', '<leader>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
map('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
map('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
map('n', '<leader>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)

local on_attach = function(client, bufnr)
    local bufmap = vim.api.nvim_buf_set_keymap
    bufmap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    bufmap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
    bufmap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    bufmap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    bufmap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
    bufmap(bufnr, 'n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
    bufmap(bufnr, 'n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
    bufmap(bufnr, 'n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
    bufmap(bufnr, 'n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    bufmap(bufnr, 'n', '<leader>r', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    bufmap(bufnr, 'n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
    bufmap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
    bufmap(bufnr, 'n', '<leader>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
end

-- Coq completion
vim.g.coq_settings = {
    auto_start = 'shut-up',
    ['clients.snippets.warn'] = {} -- No warning message
} 

-- Enable language servers with additional completion capabilities offered by coq_nvim
for _, lsp in pairs(lsps) do
    require('lspconfig')[lsp].setup(require('coq').lsp_ensure_capabilities({
        on_attach = on_attach,
    }))
end

-- =================== KEYBOARD MAPPINGS ======================
local map = vim.keymap.set

-- Plugins
map({'n','x'}, 'ga', '<Plug>(EasyAlign)')

-- Fuzzy finder
map('', '<C-p>', ':Files<CR>')

-- Center search results
map('n', 'n',  'nzz',  { silent = true })
map('n', 'N',  'Nzz',  { silent = true })
map('n', '*',  '*zz',  { silent = true })
map('n', '#',  '#zz',  { silent = true })
map('n', 'g*', 'g*zz', { silent = true })

-- Stop searching with backspace
map('', '<BS>', ':nohlsearch<CR>', { silent = true })

-- Undo
map('n', 'U', '<C-R>')

-- Disable arrow keys but make left and right switch buffers
map('n', '<up>',    '<nop>')
map('n', '<down>',  '<nop>')
map('n', '<left>',  ':bp<CR>')
map('n', '<right>', ':bn<CR>')
map('i', '<up>',    '<nop>')
map('i', '<down>',  '<nop>')
map('i', '<left>',  '<nop>')
map('i', '<right>', '<nop>')

-- Switch windows with ctrl & movement keys
map('n', '<C-j>', '<C-w>j')
map('n', '<C-k>', '<C-w>k')
map('n', '<C-h>', '<C-w>h')
map('n', '<C-l>', '<C-w>l')

-- ==================== AUTOCOMMANDS =======================
local autocmd = vim.api.nvim_create_autocmd

-- -- Inlay hints (chaining; requires neovim 0.8.0+)
-- autocmd({'CursorHold', 'CursorHoldI'}, {
--     pattern = '*.rs',
--     callback = function () require('lsp_extensions').inlay_hints({ only_current_line = true }) end
-- })

-- Disable autocomment when opening line
autocmd('BufReadPost', {
    callback = function() set.formatoptions:remove('o') end
})

-- Highlight text when yanking
autocmd('TextYankPost', {
    callback = function() vim.highlight.on_yank() end
})

-- Open a file from its last left off position
autocmd('BufReadPost', {
    callback = function()
        if not vim.fn.expand('%:p'):match '.git' and vim.fn.line '\'"' > 1 and vim.fn.line '\'"' <= vim.fn.line '$' then
            vim.cmd 'normal! g\'"'
            vim.cmd 'normal zz'
        end
    end
})
