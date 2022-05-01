set nocompatible

" =======================================
" # PLUGINS
" =======================================

call plug#begin()
Plug 'chriskempson/base16-vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'rust-lang/rust.vim'
call plug#end()

" Rust
let g:rustfmt_autosave = 1
let g:rustfmt_emit_files = 1
let g:rustfmt_fail_silently = 0

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
nmap <leader>rn <Plug>(coc-rename)

" =======================================
" # EDITOR SETTINGS
" =======================================
syntax on
filetype plugin indent on
set autoindent
set hidden
set encoding=utf-8
set fileformats=unix,dos,mac
set wildmenu
set showmatch
set number
set relativenumber
set laststatus=2
set backspace=indent,eol,start
set noerrorbells visualbell t_vb=
set mouse+=a

" Tabs
set shiftwidth=4
set tabstop=4
set softtabstop=4
set expandtab

" Coc settings
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
if !has('gui_running')
    set t_Co=256
endif

set termguicolors
set background=dark
" colorscheme base16-gruvbox-dark-hard
colorscheme base16-woodland
let base16colorspace=256
call Base16hi("Comment", g:base16_gui09, "", g:base16_cterm09, "", "", "")
call Base16hi("CocHintSign", g:base16_gui03, "", g:base16_cterm03, "", "", "")

" =======================================
" # KEYBOARD MAPPINGS
" =======================================
nmap Q <Nop> " 'Q' in normal mode enters Ex mode. You almost never want this.

" No arrow keys --- force yourself to use the home row
nnoremap <up> <nop>
nnoremap <down> <nop>
inoremap <up> <nop>
inoremap <down> <nop>
inoremap <left> <nop>
inoremap <right> <nop>

" Left and right can switch buffers
nnoremap <left> :bp<CR>
nnoremap <right> :bn<CR>
