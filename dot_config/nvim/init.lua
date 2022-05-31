-- Load filetypes using Lua
vim.g.did_load_filetypes = 0 -- Don't use filetypes.vim
vim.g.do_filetype_lua    = 1 -- Use filetypes.lua

-- =============== QUICK CONFIG =================
local treesitters = { 'fish', 'lua', 'markdown', 'comment', 'rust', 'toml', 'haskell', 'python' }
local lsps        = { 'sumneko_lua', 'rust_analyzer', 'hls', 'pylsp' }
local colorscheme = 'soluarized'
vim.o.background  = 'light'

-- ================= PLUGINS ====================
require('packer').startup(function(use)
    use { 'wbthomason/packer.nvim', lock = true } -- Managed by chezmoi

    -- Colorschemes
    use 'ellisonleao/gruvbox.nvim' -- gruvbox
    use 'Iron-E/nvim-soluarized' -- soluarized
    use 'sainnhe/everforest' -- everforest
    use 'Mofiqul/dracula.nvim' -- dracula
    use 'folke/tokyonight.nvim' -- tokyonight
    use 'rmehri01/onenord.nvim' -- onenord

    -- Vim improvements
    use 'gpanders/editorconfig.nvim'
    use { 'numToStr/Comment.nvim', config = function() require('Comment').setup() end }
    use { 'echasnovski/mini.nvim', branch = 'stable' } -- Better vim-surround
    use { 'junegunn/vim-easy-align', requires = 'tpope/vim-repeat' } -- Easily align stuff with 'ga'
    use 'rhysd/clever-f.vim' -- Better 'f' and 't'
    use { 'ggandor/leap.nvim', -- Jump with 's' ('z' and 'x' in operator-pending mode)
        config   = function() require('leap').set_default_keymaps() end,
        requires = 'tpope/vim-repeat' }

    -- Fuzzy finder
    use { 'ibhagwan/fzf-lua',
        requires = { '/usr/local/opt/fzf', 'kyazdani42/nvim-web-devicons' } }

    -- Linting
    use { 'neovim/nvim-lspconfig' }
    use { 'williamboman/nvim-lsp-installer',
        -- 'ray-x/lsp_signature.nvim', -- Type signature hints
        requires = 'neovim/nvim-lspconfig' }

    -- Autocompletion
    use { 'ms-jpq/coq_nvim', lock = true, branch = 'coq', run = 'python3 -m coq deps' }
    use { 'ms-jpq/coq.artifacts', lock = true, branch = 'artifacts', requires = 'ms-jpq/coq_nvim' } -- Snippets

    -- Syntax
    use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
    use { 'nvim-treesitter/nvim-treesitter-textobjects',
        -- 'nvim-treesitter/nvim-treesitter-context',
        requires = 'nvim-treesitter/nvim-treesitter' }
    use { 'sevko/vim-nand2tetris-syntax', ft = { 'hack_asm', 'hack_vm', 'hdl', 'jack' } }

    -- Rust
    use { 'saecki/crates.nvim',
        event    = 'BufRead Cargo.toml',
        config   = function() require('crates').setup({ src = { coq = { enabled = true } } }) end,
        requires = 'nvim-lua/plenary.nvim' }

    -- Statusline
    use { 'nvim-lualine/lualine.nvim', requires = 'kyazdani42/nvim-web-devicons' }
end)

-- ================= GENERAL SETTINGS =====================
local set = vim.opt

vim.g.mapleader    = ','
set.shell          = '/bin/sh'
set.number         = true
set.relativenumber = true
set.undofile       = true
set.modeline       = false
set.swapfile       = false
set.updatetime     = 750
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
    end
    -- Try to find theme, else use 'auto'
    local ok, theme = pcall(require, 'lualine.themes.' .. cs)
    if ok then
        return theme
    else
        return 'auto'
    end
end

require('lualine').setup({
    options = {
        icons_enabled        = true,
        theme                = get_theme(colorscheme),
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

map('n', '[d', vim.diagnostic.goto_prev, silent)
map('n', ']d', vim.diagnostic.goto_next, silent)

local on_attach = function(_, bufnr)
    local buf = { silent = true, buffer = bufnr }
    map('n', 'K', vim.lsp.buf.hover, buf)
    map('n', '<Leader>p', vim.lsp.buf.formatting, buf)
    map('n', '<Leader>r', vim.lsp.buf.rename, buf)
    map('n', '<Leader>c', vim.lsp.buf.code_action, buf)
    vim.wo.signcolumn = 'yes' -- Enable signcolumn for diagnostics for current window
end

-- Coq_nvim completion
vim.g.coq_settings = {
    keymap = {
        jump_to_mark = '<C-j>',
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
map({ 'n', 'v' }, 'ga', '<Plug>(EasyAlign)')

-- Fuzzy finder
require('fzf-lua').register_ui_select()
map({ 'n', 'v' }, '<Leader>f', require('fzf-lua').builtin, silent)
map({ 'n', 'v' }, '<Leader>e', require('fzf-lua').files, silent)
map({ 'n', 'v' }, '<Leader>h', require('fzf-lua').help_tags, silent)
map({ 'n', 'v' }, '<Leader>d', require('fzf-lua').lsp_workspace_diagnostics, silent)
map({ 'n', 'v' }, '<Leader>l', require('fzf-lua').lines, silent)
map({ 'n', 'v' }, '<Leader>g', require('fzf-lua').grep_project, silent)

-- Center search results
map('n', 'n', 'nzz', silent)
map('n', 'N', 'Nzz', silent)
map('n', '*', '*zz', silent)
map('n', '#', '#zz', silent)
map('n', 'g*', 'g*zz', silent)

-- Stop searching with backspace
map('', '<BS>', ':nohlsearch<CR>', silent)

-- Move to beginning and end of line with H and L
map('', 'H', '^')
map('', 'L', '$')

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
