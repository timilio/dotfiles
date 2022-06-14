;; Load filetypes using Lua
(local g vim.g)
(set g.did_load_filetypes 0) ; Don't use filetypes.vim
(set g.do_filetype_lua 1) ; Use filetypes.lua

;;; =============== QUICK CONFIG =================
(local treesitters ["fish" "markdown" "rust" "toml" "haskell" "python" "fennel"])
(local lsp-servers ["rust_analyzer" "hls" "pylsp" "zk"])
(local colorscheme "soluarized")
(local background "dark")

;;; ================= PLUGINS ====================
(local pack (require :packer))
(pack.startup (fn [use]
  (use "wbthomason/packer.nvim")
  (use "udayvir-singh/tangerine.nvim")

  ;; Colorschemes
  (use "Iron-E/nvim-soluarized") ; soluarized
  (use "ellisonleao/gruvbox.nvim") ; gruvbox
  (use "sainnhe/everforest") ; everforest
  (use "Mofiqul/dracula.nvim") ; dracula
  (use "folke/tokyonight.nvim") ; tokyonight
  (use "rmehri01/onenord.nvim") ; onenord

  ;; Vim improvements
  (use "gpanders/editorconfig.nvim")
  (use "rhysd/clever-f.vim")
  (use "jbyuki/nabla.nvim") ; LaTeX math preview
  (use {1 "numToStr/Comment.nvim"
        :config (fn [] (let [Comment (require :Comment)] (Comment.setup)))})
  (use {1 "echasnovski/mini.nvim" :branch "stable"}) ; Better vim-surround
  (use {1 "junegunn/vim-easy-align" :requires "tpope/vim-repeat"})
  (use {1 "ggandor/leap.nvim" ; Jump with "s" ("z" and "x" in operator-pending mode)
        :config (fn [] (let [leap (require :leap)] (leap.set_default_keymaps)))
        :requires "tpope/vim-repeat"})

  ;; Fuzzy finder
  (use {1 "ibhagwan/fzf-lua"
        :requires ["/usr/local/opt/fzf" "kyazdani42/nvim-web-devicons"]})

  ;; Linting (Language Servers)
  (use "neovim/nvim-lspconfig")
  (use {1 "williamboman/nvim-lsp-installer" :requires "neovim/nvim-lspconfig"})

  ;; Autocompletion (I switched from coq_nvim because it didn"t show some lsp
  ;; completions and jump to mark was janky)
  (use {1 "hrsh7th/nvim-cmp"
        :config (fn [] (require "completions")) ; Setup completions in ./lua/completions.lua
        :requires ["L3MON4D3/LuaSnip" "saadparwaiz1/cmp_luasnip"]})
  (use {1 "hrsh7th/cmp-nvim-lsp" ; Completions sources (LSP, text from BUF, path completion)
        2 "hrsh7th/cmp-buffer"
        3 "hrsh7th/cmp-path"
        4 "hrsh7th/cmp-emoji" ; Complete and insert markdown emoji (e.g. :duck: -> 🦆)
        5 {1 "kdheepak/cmp-latex-symbols" :ft "markdown"} ; Complete and insert math symbols with LaTeX
        6 {1 "jc-doyle/cmp-pandoc-references" :ft "markdown"}
        7 {1 "mtoohey31/cmp-fish" :ft "fish"}
        :requires "hrsh7th/nvim-cmp"})
  (use {1 "rafamadriz/friendly-snippets" :disable true
        :config (fn [] (let [loader (require :luasnip.loaders.from_vscode)]
                         (loader.lazy_load)))})

  ;; Syntax and highlighting
  (use {1 "nvim-treesitter/nvim-treesitter" :run ":TSUpdate"})
  (use {1 "nvim-treesitter/nvim-treesitter-textobjects"
        2 "p00f/nvim-ts-rainbow" ; Rainbow parentheses for lisps
        :requires "nvim-treesitter/nvim-treesitter"})
  (use {1 "fladson/vim-kitty"
        :ft "kitty"})
  (use {1 "sevko/vim-nand2tetris-syntax"
        :ft ["hack_asm" "hack_vm" "hdl" "jack"]})

  ;; Rust
  (use {1 "saecki/crates.nvim"
        :event "BufRead Cargo.toml"
        :config (fn [] (let [crates (require :crates)] (crates.setup)))
        :requires "nvim-lua/plenary.nvim"})

  ;; Statusline
  (use {1 "nvim-lualine/lualine.nvim"
        :requires "kyazdani42/nvim-web-devicons"})))

;;; ================= GENERAL SETTINGS =====================
(local opt vim.opt)

(set g.mapleader ",")
(set opt.number true)
(set opt.relativenumber true)
(set opt.undofile true) ; Permanent undo history
(set opt.modeline false)
(set opt.swapfile false)
(set opt.updatetime 750) ; Make lsp more responsive
(set opt.scrolloff 5) ; Proximity in number of lines before scrolling

;; Completions
(opt.shortmess:append "c")
(set opt.pumheight 10) ; Number of autocomplete suggestions displayed at once

;; Tabs (expand to 4 spaces)
(set opt.shiftwidth 4)
(set opt.tabstop 4)
(set opt.softtabstop 4)
(set opt.expandtab true)

;; Better searching
(set opt.ignorecase true)
(set opt.smartcase true)

;; GUI and colorscheme
(set opt.showcmd false) ; Don"t show me what keys I"m pressing
(set opt.showmode false) ; Do not show vim mode, because I have statusline plugin
(set opt.termguicolors true) ; Make colors display correctly
(vim.cmd (.. "colorscheme " colorscheme))
(set opt.background background)

;; Change diagnostic letters to icons (in the gutter)
(let [signs {:Error " " :Warn " " :Hint " " :Info " "}]
  (each [kind sign (pairs signs)]
    (let [hl (.. "DiagnosticSign" kind)]
      (vim.fn.sign_define hl {:text sign :texthl hl :numhl hl}))))

;;; ================== PLUGIN SETUP ====================

;; Mini.nvim modules
(let [surround (require :mini.surround)]
  (surround.setup {:mappings {:add "ys"
                              :delete "ds"
                              :replace "cs"
                              :highlight ""
                              :find ""
                              :find_left ""
                              :update_n_lines ""}}))

;; I want only "gc" textobject (main plugin is numToStr/Comment.nvim)
(let [mini-comment (require :mini.comment)]
  (mini-comment.setup {:mappings {:comment ""
                                  :comment_line ""
                                  :textobject "gc"}}))

;; Lualine
(fn wordcount []
  (let [dict (vim.fn.wordcount)]
    (or dict.visual_words dict.words)))

(fn get-theme [cs]
  (match cs
    :soluarized :solarized
    :dracula :dracula-nvim
    :gruvbox :powerline
    _ (match (pcall require (.. :lualine.themes cs))
        (true theme) theme
        (false _) :auto)))

(let [lualine (require :lualine)]
  (lualine.setup {:options {:icons_enabled true
                            :theme (get-theme colorscheme)
                            :component_separators "|"
                            :section_separators ""
                            :globalstatus true}
                  :sections {:lualine_a [:mode]
                             :lualine_b [:diagnostics]
                             :lualine_c [:filename]
                             :lualine_x [wordcount :encoding :filetype]
                             :lualine_y [:progress]
                             :lualine_z [:location]}}))

;; Treesitter syntax highlighting
(let [configs (require :nvim-treesitter.configs)]
  (configs.setup {:ensure_installed treesitters
                  :highlight {:enable true}
                  :textobjects {:select {:enable true
                                         :lookahead true
                                         :keymaps {"ac" "@comment.outer"
                                                   "af" "@function.outer"
                                                   "if" "@function.inner"
                                                   "aa" "@parameter.outer"
                                                   "ia" "@parameter.inner"}}}
                  :rainbow {:enable true
                            :disable (icollect [_ lang (ipairs treesitters)]
                                       (if (not= lang "fennel")
                                           lang))}}))

;; Lsp Installer (setup before LspConfig!)
(let [lsp-installer (require :nvim-lsp-installer)]
  (lsp-installer.setup {:automatic_installation {:exclude [:zk]}
                        :ui {:icons {:server_installed "✓"
                                     :server_pending "➜"
                                     :server_uninstalled "✗"}}}))

;; LspConfig
(local map vim.keymap.set)

(map :n "[d" vim.diagnostic.goto_prev {:silent true})
(map :n "]d" vim.diagnostic.goto_next {:silent true})

(fn on-attach [_ bufnr]
  (let [buf {:silent true
             :buffer bufnr}
        fzf (require :fzf-lua)]
    (map :n "K" vim.lsp.buf.hover buf) ; now defined later with nabla math preview
    (map :n "gd" vim.lsp.buf.definition buf)
    (map :n "<Leader>p" vim.lsp.buf.formatting buf)
    (map :n "<Leader>r" vim.lsp.buf.rename buf)
    (map :n "<Leader>c" vim.lsp.buf.code_action buf)
    (set vim.wo.signcolumn "yes") ; Enable signcolumn for diagnostics in current window
    (map :n "gr" fzf.lsp_references)
    (map :n "<Leader>d" fzf.lsp_workspace_diagnostics)))

;; Enable language servers

(each [_ lsp (pairs lsp-servers)]
  (let [lspconfig (. (require :lspconfig) lsp)
        cmp-nvim-lsp (require :cmp_nvim_lsp)]
    (lspconfig.setup
      {:on_attach on-attach
       :settings {:Lua {:runtime {:version :LuaJIT}
                        :diagnostics {:globals :vim} ; Recognize the `vim` global
                        :workspace {:library (vim.api.nvim_get_runtime_file "" true)}
                        :telemetry {:enable false}}}
       :capabilities (cmp-nvim-lsp.update_capabilities (vim.lsp.protocol.make_client_capabilities))})))

;;; =================== KEYBOARD MAPPINGS ======================

;; LaTeX math preview (hover)
(map :n "K" (fn []
              (let [nabla (require :nabla)
                    (nabla-ok _) (pcall nabla.popup)]
                (or nabla-ok (pcall vim.lsp.buf.hover))))) ; If on math, preview math, else try to lsp hover

;; EasyAlign
(map [:n :v] "ga" "<Plug>(EasyAlign)")

;; Fuzzy finder
(let [fzf (require :fzf-lua)]
  (fzf.register_ui_select)
  (map [:n :v] "<Leader>f" fzf.builtin {:silent true})
  (map [:n :v] "<Leader>h" fzf.help_tags {:silent true})
  (map [:n :v] "<Leader>l" fzf.lines {:silent true})
  (map [:n :v] "<Leader>g" fzf.grep_project {:silent true})
  (map [:n :v] "<Leader>e" (fn [] (fzf.files {:cmd "fd . -t f"})) {:silent true})) ; Ignore hidden files

;; Center search results
(map :n "n" "nzz" {:silent true})
(map :n "N" "Nzz" {:silent true})
(map :n "*" "*zz" {:silent true})
(map :n "#" "#zz" {:silent true})
(map :n "g*" "g*zz" {:silent true})

;; Stop searching with backspace
(map "" "<BS>" ":nohlsearch<CR>" {:silent true})

;; Undo
(map :n "U" "<C-R>")

;; Delete buffer
(map :n "<Leader>q" ":bd<CR>" {:silent true})

;; Disable arrow keys but make left and right switch buffers
(map [:n :i] "<up>" "<nop>")
(map [:n :i] "<down>" "<nop>")
(map :n "<left>" ":bp<CR>" {:silent true})
(map :i "<left>" "<nop>")
(map :n "<right>" ":bn<CR>" {:silent true})
(map :i "<right>" "<nop>")

;; Switch windows with alt & movement keys (MAC)
(map [:n :v] "∆" "<C-W>j")
(map [:n :v] "˚" "<C-W>k")
(map [:n :v] "˙" "<C-W>h")
(map [:n :v] "¬" "<C-W>l")

;;; ==================== USER COMMANDS ======================
(local cmd vim.api.nvim_create_user_command)

(cmd "Spell"
     (fn []
       (do
         (print "Enabling LTeX...")
         (let [lspconfig (require :lspconfig)]
           (lspconfig.ltex.setup {:on_attach on-attach :autostart false}))
         (vim.cmd :LspStart)))
     {:desc "Enable LTeX language server for spell and grammar checking"})

;;; ==================== AUTOCOMMANDS =======================
(local autocmd vim.api.nvim_create_autocmd)

;; Disable autocomment when opening line
(autocmd :BufWinEnter
         {:callback (fn [] (opt.formatoptions:remove "o"))})

;; Highlight text when yanking
(autocmd :TextYankPost
         {:callback (fn [] (vim.highlight.on_yank))})

;; Open a file from its last left off position
(autocmd :BufReadPost
         {:callback (fn []
                      (when (and (not (: (vim.fn.expand "%:p") :match ".git"))
                                 (let [mark-line (vim.fn.line "'\"")]
                                   (and (> mark-line 1)
                                        (<= mark-line (vim.fn.line "$")))))
                        (vim.cmd "normal! g'\"")
                        (vim.cmd "normal zz")))})
