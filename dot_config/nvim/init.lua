-- Load filetypes using Lua
vim.g.did_load_filetypes = 0 -- Don't use filetypes.vim
vim.g.do_filetype_lua    = 1 -- Use filetypes.lua

-- =============== QUICK CONFIG =================
local treesitters = { 'fish', 'lua', 'markdown', 'rust', 'toml', 'haskell', 'python', 'fennel' }
local lsp_servers = { 'sumneko_lua', 'rust_analyzer', 'hls', 'pylsp', 'zk' }
local colorscheme = 'everforest'
local background  = 'dark'

-- ================= PLUGINS ====================
require('packer').startup(function(use)
    use { 'wbthomason/packer.nvim', lock = true } -- Managed by chezmoi

    -- Colorschemes
    use 'Iron-E/nvim-soluarized' -- soluarized
    use 'ellisonleao/gruvbox.nvim' -- gruvbox
    use 'sainnhe/everforest' -- everforest
    use 'Mofiqul/dracula.nvim' -- dracula
    use 'folke/tokyonight.nvim' -- tokyonight
    use 'rmehri01/onenord.nvim' -- onenord

    -- Vim improvements
    use 'gpanders/editorconfig.nvim'
    use 'jbyuki/nabla.nvim' -- LaTeX math preview
    use { 'numToStr/Comment.nvim', config = function() require('Comment').setup() end }
    use { 'echasnovski/mini.nvim', branch = 'stable' } -- Better vim-surround
    use { 'junegunn/vim-easy-align', requires = 'tpope/vim-repeat' }
    use { 'ggandor/leap.nvim', -- Jump with 's' ('z' and 'x' in operator-pending mode)
        config   = function() require('leap').set_default_keymaps() end,
        requires = 'tpope/vim-repeat' }

    -- Fuzzy finder
    use { 'ibhagwan/fzf-lua',
        requires = { '/usr/local/opt/fzf', 'kyazdani42/nvim-web-devicons' } }

    -- Linting (Language Servers)
    use 'neovim/nvim-lspconfig'
    use { 'williamboman/nvim-lsp-installer',
        requires = 'neovim/nvim-lspconfig' }

    -- Autocompletion (I switched from coq_nvim because it didn't show some lsp
    -- completions and jump to mark was janky)
    use { 'hrsh7th/nvim-cmp',
        config = function() require('completions') end, -- Setup completions in ./lua/completions.lua
        requires = { 'L3MON4D3/LuaSnip', 'saadparwaiz1/cmp_luasnip' } }
    use { 'hrsh7th/cmp-nvim-lsp', -- Completions sources (LSP, text from BUF, path completion)
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',
        'hrsh7th/cmp-emoji', -- Complete and insert markdown emoji (e.g. :duck: -> 🦆)
        { 'kdheepak/cmp-latex-symbols', ft = 'markdown' }, -- Complete and insert math symbols with LaTeX
        { 'jc-doyle/cmp-pandoc-references', ft = 'markdown' },
        { "mtoohey31/cmp-fish", ft = "fish" },
        requires = 'hrsh7th/nvim-cmp' }
    use { 'rafamadriz/friendly-snippets', disable = true,
        config = function() require('luasnip.loaders.from_vscode').lazy_load() end }

    -- Syntax and highlighting
    use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
    use { 'nvim-treesitter/nvim-treesitter-textobjects',
        requires = 'nvim-treesitter/nvim-treesitter' }
    use { 'fladson/vim-kitty', ft = 'kitty' }
    use { 'sevko/vim-nand2tetris-syntax', ft = { 'hack_asm', 'hack_vm', 'hdl', 'jack' } }

    -- Rust
    use { 'saecki/crates.nvim',
        event    = 'BufRead Cargo.toml',
        config   = function() require('crates').setup() end,
        requires = 'nvim-lua/plenary.nvim' }

    -- Statusline
    use { 'nvim-lualine/lualine.nvim', requires = 'kyazdani42/nvim-web-devicons' }
end)

-- ================= GENERAL SETTINGS =====================
local set = vim.opt

vim.g.mapleader    = ','
set.number         = true
set.relativenumber = true
set.undofile       = true -- Permanent undo history
set.modeline       = false
set.swapfile       = false
set.updatetime     = 750 -- Make lsp more responsive
set.scrolloff      = 5 -- Proximity in number of lines before scrolling

-- Completions
set.shortmess:append('c')
set.pumheight = 10 -- Number of autocomplete suggestions displayed at once

-- Tabs (expand to 4 spaces)
set.shiftwidth  = 4
set.tabstop     = 4
set.softtabstop = 4
set.expandtab   = true

-- Better searching
set.ignorecase = true
set.smartcase  = true

-- GUI and colorscheme
set.showcmd       = false -- Don't show me what keys I'm pressing
set.showmode      = false -- Do not show vim mode, because I have statusline plugin
set.termguicolors = true -- Make colors display correctly
vim.cmd('colorscheme ' .. colorscheme)
set.background = background

-- Change diagnostic letters to icons (in the gutter)
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- ================== PLUGIN SETUP ====================

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

-- I want only 'gc' textobject (main plugin is numToStr/Comment.nvim)
require('mini.comment').setup({ mappings = { comment = '', comment_line = '', textobject = 'gc', } })

-- Lualine
local wordcount = function()
    local dict = vim.fn.wordcount()
    return dict.visual_words or dict.words
end

local get_theme = function(cs)
    if cs == 'soluarized' then
        return 'solarized'
    elseif cs == 'dracula' then
        return 'dracula-nvim'
    elseif cs == 'gruvbox' then
        return 'powerline'
    end
    -- Try to find theme, else use 'auto'
    local ok, theme = pcall(require, 'lualine.themes.' .. cs)
    if ok then return theme else return 'auto' end
end

require('lualine').setup({
    options = {
        icons_enabled        = true,
        theme                = get_theme(colorscheme),
        component_separators = '|',
        section_separators   = '',
        disabled_filetypes   = {},
        always_divide_middle = true,
        globalstatus         = true,
    },
    sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'diagnostics' },
        lualine_c = { 'filename' },
        lualine_x = { wordcount, 'encoding', 'filetype' },
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
            lookahead = true, -- Automatically jump forward to next target textobject
            keymaps = {
                ['ac'] = '@comment.outer',
                ['af'] = '@function.outer',
                ['if'] = '@function.inner',
                ['aa'] = '@parameter.outer',
                ['ia'] = '@parameter.inner',
            },
        },
    },
})

-- Lsp Installer (setup before LspConfig!)
require('nvim-lsp-installer').setup({
    automatic_installation = { exclude = { 'zk' } }, -- Installs all lsps required by LspConfig automatically
    ui = {
        icons = {
            server_installed = '✓',
            server_pending = '➜',
            server_uninstalled = '✗'
        }
    }
})

-- LspConfig
local map = vim.keymap.set
local silent = { silent = true }

map('n', '[d', vim.diagnostic.goto_prev, silent)
map('n', ']d', vim.diagnostic.goto_next, silent)

local on_attach = function(_, bufnr)
    local buf = { silent = true, buffer = bufnr }
    -- map('n', 'K', vim.lsp.buf.hover, buf) -- now defined later with nabla math preview
    map('n', 'gd', vim.lsp.buf.definition, buf)
    map('n', '<Leader>p', vim.lsp.buf.formatting, buf)
    map('n', '<Leader>r', vim.lsp.buf.rename, buf)
    map('n', '<Leader>c', vim.lsp.buf.code_action, buf)
    vim.wo.signcolumn = 'yes' -- Enable signcolumn for diagnostics in current window
    map('n', 'gr', require('fzf-lua').lsp_references)
    map('n', '<Leader>d', require('fzf-lua').lsp_workspace_diagnostics)
end

-- Enable language servers
for _, lsp in pairs(lsp_servers) do
    require('lspconfig')[lsp].setup({
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
        capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities()),
    })
end

-- =================== KEYBOARD MAPPINGS ======================

-- LaTeX math preview (hover)
map('n', 'K', function()
    -- If on math, preview math, else try to lsp hover
    local ok, _ = pcall(require('nabla').popup)
    if not ok then
        pcall(vim.lsp.buf.hover)
    end
end)

-- EasyAlign
map({ 'n', 'v' }, 'ga', '<Plug>(EasyAlign)')

-- Fuzzy finder
require('fzf-lua').register_ui_select()
map({ 'n', 'v' }, '<Leader>f', require('fzf-lua').builtin, silent)
map({ 'n', 'v' }, '<Leader>h', require('fzf-lua').help_tags, silent)
map({ 'n', 'v' }, '<Leader>l', require('fzf-lua').lines, silent)
map({ 'n', 'v' }, '<Leader>g', require('fzf-lua').grep_project, silent)
map({ 'n', 'v' }, '<Leader>e', function()
    require('fzf-lua').files({ cmd = 'fd . -t f' }) -- Ignore hidden files
end, silent)

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
map('n', '<Leader>q', ':bd<CR>', silent)

-- Disable arrow keys but make left and right switch buffers
map({ 'n', 'i' }, '<up>', '<nop>')
map({ 'n', 'i' }, '<down>', '<nop>')
map('n', '<left>', ':bp<CR>', silent)
map('i', '<left>', '<nop>')
map('n', '<right>', ':bn<CR>', silent)
map('i', '<right>', '<nop>')

-- Switch windows with alt & movement keys (MAC)
map({ 'n', 'v' }, '∆', '<C-W>j')
map({ 'n', 'v' }, '˚', '<C-W>k')
map({ 'n', 'v' }, '˙', '<C-W>h')
map({ 'n', 'v' }, '¬', '<C-W>l')

-- ==================== USER COMMANDS ======================
local cmd = vim.api.nvim_create_user_command

cmd('Spell', function()
    print('Enabling LTEX...')
    require('lspconfig').ltex.setup({ on_attach = on_attach, autostart = false })
    vim.cmd('LspStart')
end, { desc = 'Enable LTEX language server for spell and grammar checking' })

-- ==================== AUTOCOMMANDS =======================
local autocmd = vim.api.nvim_create_autocmd

-- Disable autocomment when opening line
autocmd('BufWinEnter', {
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
