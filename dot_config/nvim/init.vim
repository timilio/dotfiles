set shell=/bin/sh
set nocompatible

" =======================================
" # PLUGINS
" =======================================

call plug#begin()
" Vim improvements
Plug 'editorconfig/editorconfig-vim'
Plug 'ggandor/leap.nvim'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-repeat'
Plug 'junegunn/vim-easy-align'
Plug 'christoomey/vim-titlecase'

" Extra text objects
Plug 'wellle/targets.vim'
Plug 'michaeljsmith/vim-indent-object'
Plug 'kana/vim-textobj-user'
Plug 'kana/vim-textobj-entire'
Plug 'glts/vim-textobj-comment'
Plug 'julian/vim-textobj-variable-segment'

" Linting
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Syntax
Plug 'rust-lang/rust.vim'
Plug 'neovimhaskell/haskell-vim'
Plug 'dag/vim-fish'
Plug 'sevko/vim-nand2tetris-syntax'

" GUI improvements
Plug 'chriskempson/base16-vim'
Plug 'itchyny/lightline.vim'
call plug#end()

" Rust formatting
let g:rustfmt_autosave = 1
let g:rustfmt_emit_files = 1
let g:rustfmt_fail_silently = 0

" ---------
" Lightline
" ---------
let g:lightline = {
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'readonly', 'filename', 'modified' ] ],
      \   'right': [ [ 'lineinfo' ],
      \              [ 'percent' ],
      \              [ 'wordcount', 'fileencoding', 'filetype' ] ]
      \ },
      \ 'component_function': {
      \   'wordcount': 'WordCount'
      \ },
      \ }

function! WordCount()
    if !(&filetype ==# 'markdown') " Only show in markdown files
        return ""
    endif

    let currentmode = mode()
    if !exists("g:lastmode_wc")
        let g:lastmode_wc = currentmode
    endif
    " if we modify file, open a new buffer, be in visual ever, or switch modes
    " since last run, we recompute.
    if &modified || !exists("b:wordcount") || currentmode =~? '\c.*v' || currentmode != g:lastmode_wc
        let g:lastmode_wc = currentmode
        let l:old_position = getpos('.')
        let l:old_status = v:statusmsg
        execute "silent normal g\<c-g>"
        if v:statusmsg == "--No lines in buffer--"
            let b:wordcount = 0
        else
            let s:split_wc = split(v:statusmsg)
            if index(s:split_wc, "Selected") < 0
                let b:wordcount = str2nr(s:split_wc[11])
            else
                let b:wordcount = str2nr(s:split_wc[5])
            endif
            let v:statusmsg = l:old_status
        endif
        call setpos('.', l:old_position)
        return b:wordcount
    else
        return b:wordcount
    endif
endfunction

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
set hidden " enable hidden buffers
set encoding=utf-8
set fileformats=unix,dos,mac
set number " absolute number and relative numbers
set relativenumber
set showmatch " highlight matching brackets
set scrolloff=2
set laststatus=2 " always enable statusbar (lightline)
set backspace=indent,eol,start " backspace over anything
set noerrorbells visualbell t_vb=
set mouse+=a

" Tabs (expand to 4 spaces)
set shiftwidth=4
set tabstop=4
set softtabstop=4
set expandtab

" CoC settings
set updatetime=300
set shortmess+=c
set signcolumn=yes

" Better searching
set ignorecase
set smartcase
set incsearch
set gdefault

" GUI
set noshowcmd
set noshowmode " because I have lightline
set cmdheight=1
if !has('gui_running')
    set t_Co=256
endif
set termguicolors
set background=dark
colorscheme base16-gruvbox-dark-hard
let base16colorspace=256

" Less glaring hints (linting) 
call Base16hi("CocHintSign", g:base16_gui03, "", g:base16_cterm03, "", "", "")

" =======================================
" # KEYBOARD MAPPINGS
" =======================================

" Default keymaps for leap.nvim
lua require('leap').set_default_keymaps()

" Start interactive EasyAlign in visual and for motion/textobj
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

" Redo
nnoremap U <C-R>

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

" Jump to last edit position on opening file (except for git commits)
if has("autocmd")
    au BufReadPost * if expand('%:p') !~# '\m/\.git/' && line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

" Highlight text when yanking
au TextYankPost * silent! lua vim.highlight.on_yank()
