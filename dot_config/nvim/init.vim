set nocompatible

" =======================================
" # PLUGINS
" =======================================

call plug#begin()
" Vim improvements
Plug 'justinmk/vim-sneak'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'

" Linting (:Coc...)
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" Plug 'neovim/nvim-lspconfig'
" Plug 'nvim-lua/lsp_extensions.nvim'
" Plug 'ray-x/lsp_signature.nvim'

" Syntax
Plug 'rust-lang/rust.vim'
Plug 'sevko/vim-nand2tetris-syntax'

" GUI improvements
Plug 'chriskempson/base16-vim'
Plug 'itchyny/lightline.vim'
call plug#end()

" Rust formatting
let g:rustfmt_autosave = 1
let g:rustfmt_emit_files = 1
let g:rustfmt_fail_silently = 0

" LSP configuration
" lua << END
" local lspconfig = require('lspconfig')
" local on_attach = function(client, bufnr)
"     local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
"     local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

"     -- Mappings.
"     local opts = { noremap=true, silent=true }

"     -- See `:help vim.lsp.*` for documentation on any of the below functions
"     buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
"     buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
"     buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
"     buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
"     buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
"     buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
"     buf_set_keymap('n', '<space>r', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
"     buf_set_keymap('n', '<space>a', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
"     buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
"     buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
"     buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
"     buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
"     buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
"     buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)

"     -- Get signatures (and _only_ signatures) when in argument lists.
"     require "lsp_signature".on_attach({
"         doc_lines = 0,
"         handler_opts = {
"             border = "none"
"         },
"     })
" end

" --local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
" lspconfig.rust_analyzer.setup {
"     on_attach = on_attach,
"     flags = {
"         debounce_text_changes = 150,
"     },
"     settings = {
"         ["rust-analyzer"] = {
"             cargo = {
"                 allFeatures = true,
"             },
"         },
"     },
"     --capabilities = capabilities,
" }

" vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
"     vim.lsp.diagnostic.on_publish_diagnostics, {
"         virtual_text = true,
"         signs = true,
"         update_in_insert = true,
"     }
" )
" END

" ----------
" CoC
" ----------

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Make <CR> auto-select the first completion item and notify coc.nvim to
" format on enter, <cr> could be remapped by other vim plugin
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>r <Plug>(coc-rename)

" =======================================
" # EDITOR SETTINGS
" =======================================
syntax on
filetype plugin indent on
set autoindent
set hidden
set encoding=utf-8
set fileformats=unix,dos,mac
set scrolloff=2
set showmatch
set number
set relativenumber
set laststatus=2
set backspace=indent,eol,start
set noerrorbells visualbell t_vb=
set colorcolumn=100
set mouse+=a

" Tabs
set shiftwidth=4
set tabstop=4
set softtabstop=4
set expandtab

" CoC settings
set cmdheight=2
set updatetime=300
set shortmess+=c
set signcolumn=yes

" Better searching
set ignorecase
set smartcase
set incsearch
set gdefault

" GUI
set noshowmode " because I have lightline
if !has('gui_running')
    set t_Co=256
endif

set termguicolors
set background=dark
colorscheme base16-gruvbox-dark-hard
let base16colorspace=256

" Make comments more prominent and hints less glaring
" call Base16hi("Comment", g:base16_gui09, "", g:base16_cterm09, "", "", "")
call Base16hi("CocHintSign", g:base16_gui03, "", g:base16_cterm03, "", "", "")

" =======================================
" # KEYBOARD MAPPINGS
" =======================================

" Jump to start and end of line using the home row keys
map H ^
map L $

" Redo
nnoremap U <C-R>

" Find and replace selected word
nnoremap <leader>x *``cgn
nnoremap <leader>X #``cgN

" Easier escape keys
nnoremap <C-j> <Esc>
inoremap <C-j> <Esc>
vnoremap <C-j> <Esc>
snoremap <C-j> <Esc>
xnoremap <C-j> <Esc>
cnoremap <C-j> <C-c>
onoremap <C-j> <Esc>
lnoremap <C-j> <Esc>
tnoremap <C-j> <Esc>
nnoremap <C-k> <Esc>
inoremap <C-k> <Esc>
vnoremap <C-k> <Esc>
snoremap <C-k> <Esc>
xnoremap <C-k> <Esc>
cnoremap <C-k> <C-c>
onoremap <C-k> <Esc>
lnoremap <C-k> <Esc>
tnoremap <C-k> <Esc>

" Cancel search
noremap  <silent> <BS> :nohlsearch<CR>

" Disable moving with arrow keys
nnoremap <up> <nop>
nnoremap <down> <nop>
inoremap <up> <nop>
inoremap <down> <nop>
inoremap <left> <nop>
inoremap <right> <nop>

" Left and right arrow keys switch buffers
nnoremap <left> :bp<CR>
nnoremap <right> :bn<CR>

" =======================================
" # AUTOCOMMANDS
" =======================================

" Jump to last edit position on opening file
if has("autocmd")
    " Ignore git commit
    au BufReadPost * if expand('%:p') !~# '\m/\.git/' && line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

" Highlight text when yanking
au TextYankPost * silent! lua vim.highlight.on_yank()

" Enable type inlay hints
" autocmd CursorHold,CursorHoldI *.rs :lua require'lsp_extensions'.inlay_hints{ only_current_line = true }
