-- Load filetypes using Lua
vim.g.did_load_filetypes = 0
vim.g.do_filetype_lua = 1

vim.filetype.add({
    extension = {
        md = 'markdown.pandoc'
    }
})

-- ============================ PLUGINS  ===============================
local Plug = vim.fn['plug#']
vim.call('plug#begin')

-- Vim improvements
Plug('ggandor/leap.nvim')
Plug('rhysd/clever-f.vim')
Plug('tpope/vim-surround')
Plug('tpope/vim-commentary')
Plug('tpope/vim-repeat')
Plug('junegunn/vim-easy-align')

-- Fuzzy find
Plug('/usr/local/opt/fzf')
Plug('junegunn/fzf.vim')

-- Extra text objects
Plug('michaeljsmith/vim-indent-object')

-- Linting
Plug('neovim/nvim-lspconfig')
Plug('williamboman/nvim-lsp-installer')
Plug('ms-jpq/coq_nvim', { branch = 'coq' })
-- Plug('nvim-lua/lsp_extensions.nvim')

-- Syntax
Plug('nvim-treesitter/nvim-treesitter', { ['do'] = ':TSUpdate'} )
Plug('rust-lang/rust.vim')
Plug('vim-pandoc/vim-pandoc-syntax')
Plug('sevko/vim-nand2tetris-syntax')

-- GUI improvements
Plug('nvim-lualine/lualine.nvim')

-- Colorschemes
Plug('sainnhe/everforest')
Plug('sainnhe/gruvbox-material')
Plug('rmehri01/onenord.nvim')
Plug('rebelot/kanagawa.nvim')

vim.call('plug#end')

-- ============================ GENERAL SETTINGS ================================
local set = vim.opt

set.shell          = '/bin/sh'
set.number         = true
set.relativenumber = true
set.undofile       = true
set.showmatch      = false
set.modeline       = false
set.scrolloff      = 5
-- set.signcolumn     = "yes"
set.shortmess:append('c')

-- Tabs (expand to 4 spaces)
set.shiftwidth  = 4
set.tabstop     = 4
set.softtabstop = 4
set.expandtab   = true

-- Better searching
set.ignorecase = true
set.smartcase  = true

-- GUI
local colorscheme = 'gruvbox-material'
set.background    = 'dark'

vim.g.gruvbox_material_background         = 'hard'
vim.g.gruvbox_material_better_performance = 1
vim.g.everforest_background               = 'hard'
vim.g.everforest_better_performance       = 1

set.showcmd       = false
set.showmode      = false -- Do not show vim mode, because I have lualine
set.termguicolors = true
vim.cmd('colorscheme ' .. colorscheme)

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
        lualine_a = {'mode'},
        lualine_b = {'branch', 'diff', 'diagnostics'},
        lualine_c = {'filename'},
        lualine_x = { wordcount, 'encoding', 'fileformat', 'filetype'},
        lualine_y = {'progress'},
        lualine_z = {'location'}
    },
}

-- Pandoc markdown
vim.g['pandoc#syntax#conceal#use']                = 0
vim.g['pandoc#syntax#style#emphases']             = 0
vim.g['pandoc#syntax#style#use_definition_lists'] = 0

-- Rust formatting
vim.g.rustfmt_autosave      = 1
vim.g.rustfmt_emit_files    = 1
vim.g.rustfmt_fail_silently = 0

-- Coq completion
vim.g.coq_settings = {
    auto_start = 'shut-up',
    ['clients.snippets.warn'] = {} -- No warning message
} 

-- Treesitter
require('nvim-treesitter.configs').setup {
    ensure_installed = { 'rust', 'lua', 'fish', 'haskell' },
    highlight = {
        enable = true,
    },
}

-- Lsp Installer
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
map('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
map('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
map('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
map('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)

local on_attach = function(client, bufnr)
    local bufmap = vim.api.nvim_buf_set_keymap

    -- Enable completion triggered by <c-x><c-o>
    -- vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    bufmap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    bufmap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
    bufmap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    bufmap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    bufmap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
    bufmap(bufnr, 'n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
    bufmap(bufnr, 'n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
    bufmap(bufnr, 'n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
    bufmap(bufnr, 'n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    bufmap(bufnr, 'n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    bufmap(bufnr, 'n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
    bufmap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
    bufmap(bufnr, 'n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
end

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local servers = { 'rust_analyzer' }
for _, lsp in pairs(servers) do
    require('lspconfig')[lsp].setup {
        on_attach = on_attach,
    }
end

-- ========================= KEYBOARD MAPPINGS ============================
local map = vim.keymap.set

require('leap').set_default_keymaps()

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

-- ========================== AUTOCOMMANDS ===========================
local autocmd = vim.api.nvim_create_autocmd

-- -- Inlay hints (chaining; requires neovim 0.8.0+)
-- autocmd({'CursorHold', 'CursorHoldI'}, {
--     pattern = '*.rs',
--     callback = function () require('lsp_extensions').inlay_hints({ only_current_line = true }) end
-- })

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
