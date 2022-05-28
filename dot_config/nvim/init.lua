-- Load filetypes using Lua
vim.g.did_load_filetypes = 0 -- Don't use filetypes.vim
vim.g.do_filetype_lua    = 1 -- Use filetypes.lua

-- =============== QUICK CONFIG =================
local treesitters = { 'fish', 'lua', 'markdown', 'rust', 'toml', 'haskell', 'python' }
local lsps        = { 'sumneko_lua', 'rust_analyzer', 'hls', 'pylsp' }
local colorscheme = 'solarized'
vim.o.background  = 'light'

-- ================= PLUGINS ====================
local Plug = vim.fn['plug#']
vim.call('plug#begin')

-- Colorschemes
Plug('ishan9299/nvim-solarized-lua') -- solarized
Plug('ellisonleao/gruvbox.nvim') -- gruvbox
Plug('rmehri01/onenord.nvim') -- onenord
Plug('sainnhe/everforest') -- everforest
Plug('sainnhe/gruvbox-material') -- gruvbox-material

-- Vim improvements
Plug('ggandor/leap.nvim') -- Jump with 's' ('z' and 'x' in operator-pending mode)
Plug('junegunn/vim-easy-align')
Plug('tpope/vim-repeat') -- For leap.nvim and vim-easy-align
Plug('rhysd/clever-f.vim') -- Better 'f' and 't'
Plug('echasnovski/mini.nvim', { branch = 'stable' })

-- Fuzzy finder
Plug('/usr/local/opt/fzf') -- fzf binary path
Plug('ibhagwan/fzf-lua')

-- Linting
Plug('neovim/nvim-lspconfig')
Plug('williamboman/nvim-lsp-installer')
Plug('ms-jpq/coq_nvim', { branch = 'coq', ['do'] = 'python3 -m coq deps' }) -- Autocompletion
-- Plug('ms-jpq/coq.artifacts', { branch = 'artifacts' }) -- Snippets
-- Plug('ray-x/lsp_signature.nvim') -- Type signature hints

-- Treesitter and syntax
Plug('nvim-treesitter/nvim-treesitter', { ['do'] = ':TSUpdate' })
Plug('nvim-treesitter/nvim-treesitter-textobjects')
-- Plug('nvim-treesitter/nvim-treesitter-context') -- https://github.com/nvim-treesitter/nvim-treesitter-context
Plug('JoosepAlviste/nvim-ts-context-commentstring')
Plug('sevko/vim-nand2tetris-syntax')

-- GUI improvements
Plug('nvim-lualine/lualine.nvim') -- Customizable statusline
Plug('kyazdani42/nvim-web-devicons') -- Filetype icons for lualine

vim.call('plug#end')

-- ================= GENERAL SETTINGS =====================
local set = vim.opt

vim.g.mapleader    = ','
set.shell          = '/bin/sh'
set.number         = true
set.relativenumber = true
set.undofile       = true
set.modeline       = false
set.scrolloff      = 5
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
set.showcmd       = false
set.showmode      = false -- Do not show vim mode, because I have statusline plugin
set.termguicolors = true
vim.cmd('colorscheme ' .. colorscheme)

-- ================== PLUGIN SETUP ====================

-- Leap.nvim
require('leap').set_default_keymaps()

-- Mini.nvim modules
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

require('mini.comment').setup({
    hooks = {
        pre = require('ts_context_commentstring.internal').update_commentstring,
    },
})

-- Lualine
local function wordcount()
    local dict = vim.fn.wordcount()
    return dict.visual_words or dict.words
end

require('lualine').setup({
    options = {
        icons_enabled        = true,
        theme                = colorscheme,
        component_separators = { left = '|', right = '|' },
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
})

-- Treesitter syntax highlighting
require('nvim-treesitter.configs').setup({
    ensure_installed = treesitters,
    highlight = {
        enable = true,
    },
    -- Textobjects provided by nvim-treesitter/nvim-treesitter-textobjects
    textobjects = {
        select = {
            enable = true,
            lookahead = true, -- Automatically jump forward to textobj
            keymaps = {
                ['ac'] = '@comment.outer',
                ['af'] = '@function.outer',
                ['if'] = '@function.inner',
                ['aa'] = '@parameter.outer',
                ['ia'] = '@parameter.inner',
            },
        },
    },
    context_commentstring = {
        enable = true,
        enable_autocmd = false, -- Pre-hook on mini.comment
        config = {
            fish = '# %s',
        }
    },
})

-- Lsp Installer (setup before LspConfig!)
require('nvim-lsp-installer').setup({
    automatic_installation = true, -- Installs all lsps required by LspConfig automatically
    ui = {
        icons = {
            server_installed = '✓',
            server_pending = '➜',
            server_uninstalled = '✗'
        }
    }
})

-- LspConfig with completions provided by coq_nvim
local map = vim.keymap.set
local silent = { silent = true }

map('n', '<Leader>e', vim.diagnostic.open_float, silent)
map('n', '[d', vim.diagnostic.goto_prev, silent)
map('n', ']d', vim.diagnostic.goto_next, silent)
map('n', '<Leader>q', vim.diagnostic.setloclist, silent)

local on_attach = function(_, bufnr)
    local buf = { silent = true, buffer = bufnr }
    map('n', 'gD', vim.lsp.buf.declaration, buf)
    map('n', 'gd', vim.lsp.buf.definition, buf)
    map('n', 'K', vim.lsp.buf.hover, buf)
    map('n', 'gi', vim.lsp.buf.implementation, buf)
    map('n', '<Leader>k', vim.lsp.buf.signature_help, buf)
    map('n', '<Leader>wa', vim.lsp.buf.add_workspace_folder, buf)
    map('n', '<Leader>wr', vim.lsp.buf.remove_workspace_folder, buf)
    map('n', '<Leader>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, buf)
    map('n', '<Leader>D', vim.lsp.buf.type_definition, buf)
    map('n', '<Leader>r', vim.lsp.buf.rename, buf)
    map('n', '<Leader>ca', vim.lsp.buf.code_action, buf)
    map('n', 'gr', vim.lsp.buf.references, buf)
    map('n', '<Leader>p', vim.lsp.buf.formatting, buf)
    vim.wo.signcolumn = 'yes' -- Enable signcolumn for diagnostics for current window
end

-- Coq_nvim completion
vim.g.coq_settings = {
    keymap = {
        jump_to_mark = '<c-n>',
    },
    auto_start = 'shut-up', -- Disable startup message
    ['clients.snippets.warn'] = {} -- No 'missing snippets' warning
}

-- Enable language servers
for _, lsp in pairs(lsps) do
    require('lspconfig')[lsp].setup(require('coq').lsp_ensure_capabilities({
        on_attach = on_attach,
        -- Settings for various language servers
        settings = {
            Lua = {
                runtime = {
                    version = 'LuaJIT',
                },
                diagnostics = {
                    -- Get the language server to recognize the `vim` global
                    globals = { 'vim' },
                },
                workspace = {
                    -- Make the server aware of Neovim runtime files
                    library = vim.api.nvim_get_runtime_file('', true),
                },
                telemetry = {
                    enable = false,
                },
            },
        },
    }))
end

-- =================== KEYBOARD MAPPINGS ======================
-- local map = vim.keymap.set
-- local silent = { silent = true }

-- EasyAlign
map({ 'n', 'x' }, 'ga', '<Plug>(EasyAlign)')

-- Fuzzy finder
require('fzf-lua').register_ui_select()
map({ 'n', 'x' }, '<Leader>f', require('fzf-lua').builtin, silent)

-- Center search results
map('n', 'n', 'nzz', silent)
map('n', 'N', 'Nzz', silent)
map('n', '*', '*zz', silent)
map('n', '#', '#zz', silent)
map('n', 'g*', 'g*zz', silent)

-- Stop searching with backspace
map('', '<BS>', ':nohlsearch<CR>', silent)

-- Undo
map('n', 'U', '<C-R>')

-- Delete buffer
map('n', '<Leader>b', ':bd<CR>', silent)

-- Disable arrow keys but make left and right switch buffers
map({ 'n', 'i' }, '<up>', '<nop>')
map({ 'n', 'i' }, '<down>', '<nop>')
map('n', '<left>', ':bp<CR>')
map('i', '<left>', '<nop>')
map('n', '<right>', ':bn<CR>')
map('i', '<right>', '<nop>')

-- Switch windows with ctrl & movement keys
map({ 'n', 'x' }, '<C-j>', '<C-w>j')
map({ 'n', 'x' }, '<C-k>', '<C-w>k')
map({ 'n', 'x' }, '<C-h>', '<C-w>h')
map({ 'n', 'x' }, '<C-l>', '<C-w>l')

-- ==================== USER COMMANDS ======================
local cmd = vim.api.nvim_create_user_command

local function spell()
    print('Enabling LTEX...')
    require('lspconfig').ltex.setup({ on_attach = on_attach, autostart = false })
    vim.cmd('LspStart')
end

cmd('Spell', spell, { desc = 'Enable LTEX language server for spell and grammar checking' })

-- ==================== AUTOCOMMANDS =======================
local autocmd = vim.api.nvim_create_autocmd

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
