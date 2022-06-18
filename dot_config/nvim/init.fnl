;; Load filetypes using Lua
(set vim.g.did_load_filetypes 0) ; Don't use filetypes.vim
(set vim.g.do_filetype_lua 1) ; Use filetypes.lua

;;; =============== QUICK CONFIG =================
(local treesitters ["fennel" "fish" "markdown" "rust" "toml" "haskell" "python" "lua" "bash" "help"])
(local lsp-servers ["zk" "rust_analyzer" "hls" "pylsp" "sumneko_lua"])
(local colorscheme "gruvbox")
(local background "dark")

;;; ================= PLUGINS ====================
(local pack (require :packer))
(pack.startup
  (fn [use]
    (use "wbthomason/packer.nvim") ; Package manager
    (use "udayvir-singh/tangerine.nvim") ; Fennel compiler

    ;; Colorschemes
    (use "Iron-E/nvim-soluarized") ; soluarized
    (use "ellisonleao/gruvbox.nvim") ; gruvbox
    (use "sainnhe/everforest") ; everforest
    (use "Mofiqul/dracula.nvim") ; dracula
    (use "folke/tokyonight.nvim") ; tokyonight
    (use "rmehri01/onenord.nvim") ; onenord

    ;; Vim improvements
    (use "gpanders/editorconfig.nvim") ; https://editorconfig.org/
    (use "rhysd/clever-f.vim")
    (use "jbyuki/nabla.nvim") ; LaTeX math preview
    (use {1 "numToStr/Comment.nvim"
          :config #(let [Comment (require :Comment)] (Comment.setup))})
    (use {1 "echasnovski/mini.nvim" :branch "stable"}) ; For better vim-surround
    (use {1 "junegunn/vim-easy-align" :requires "tpope/vim-repeat"})
    (use {1 "ggandor/leap.nvim" :requires "tpope/vim-repeat"
          :config #(let [leap (require :leap)] (leap.set_default_keymaps))})
    (use {1 "j-hui/fidget.nvim" ; Lsp progress eye-candy
          :config #(let [fidget (require :fidget)] (fidget.setup))})

    ;; Fuzzy finder
    (use {1 "ibhagwan/fzf-lua"
          :requires ["/usr/local/opt/fzf" "kyazdani42/nvim-web-devicons"]})

    ;; Linting (language servers)
    (use "neovim/nvim-lspconfig")
    (use "williamboman/nvim-lsp-installer")
    (use {1 "lukas-reineke/lsp-format.nvim" ; Auto-formatting on save
          :config #(let [format (require :lsp-format)] (format.setup))})

    ;; Autocompletion (I switched from coq_nvim because it didn't show some lsp
    ;; completions and jump to mark was janky)
    (use {1 "hrsh7th/nvim-cmp"
          :config #(require "plugin/completion")
          :requires ["L3MON4D3/LuaSnip" "saadparwaiz1/cmp_luasnip"]})
    (use ["hrsh7th/cmp-nvim-lsp" ; Completions sources (LSP, text from BUF, path completion)
          "hrsh7th/cmp-buffer"
          "hrsh7th/cmp-path"
          "hrsh7th/cmp-emoji" ; Complete and insert markdown emoji (e.g. :duck: -> 🦆)
          {1 "kdheepak/cmp-latex-symbols" :ft "markdown"} ; Complete and insert math symbols with LaTeX
          {1 "jc-doyle/cmp-pandoc-references" :ft "markdown"}
          {1 "mtoohey31/cmp-fish" :ft "fish"}])

    ;; Syntax and highlighting
    (use {1 "nvim-treesitter/nvim-treesitter" :run ":TSUpdate"})
    (use "nvim-treesitter/nvim-treesitter-textobjects")
    (use "p00f/nvim-ts-rainbow") ; Rainbow parentheses for lisps
    (use {1 "fladson/vim-kitty" :ft "kitty"})
    (use {1 "sevko/vim-nand2tetris-syntax"
          :ft ["hack_asm" "hack_vm" "hdl" "jack"]})

    ;; Language specific stuff
    (use {1 "saecki/crates.nvim"
          :event "BufRead Cargo.toml"
          :config #(let [crates (require :crates)] (crates.setup))
          :requires "nvim-lua/plenary.nvim"})

    ;; Statusline
    (use {1 "nvim-lualine/lualine.nvim"
          :requires ["kyazdani42/nvim-web-devicons"]})))

;;; ================= GENERAL SETTINGS =====================
(local opt vim.opt)

(set vim.g.mapleader ",")
(set opt.number true)
(set opt.relativenumber true)
(set opt.timeoutlen 500)
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
(set opt.showcmd false) ; Don't show me what keys I'm pressing
(set opt.showmode false) ; Do not show vim mode, because I have statusline plugin
(set opt.termguicolors true) ; Make colors display correctly
(when (not vim.g.loaded_vimrc)
  (vim.cmd (.. "colorscheme " colorscheme))
  (set opt.background background)
  (set vim.g.loaded_vimrc true)) ; otherwise :FnlBuffer makes colors weird

;; Change diagnostic letters to icons (in the gutter)
(each [kind sign (pairs {:Error " " :Warn " " :Hint " " :Info " "})]
  (let [hl (.. "DiagnosticSign" kind)]
    (vim.fn.sign_define hl {:text sign :texthl hl :numhl hl})))

;;; =================== KEYBOARD MAPPINGS ======================
(local map vim.keymap.set)

;; PackerSync
(map :n "<Leader>p" #(vim.cmd :PackerSync))

;; LaTeX math preview (or lsp hover)
(map :n "K" (fn []
              (let [nabla (require :nabla)
                    (nabla-ok _) (pcall nabla.popup)]
                (when (not nabla-ok) (pcall vim.lsp.buf.hover)))))

;; EasyAlign
(map [:n :v] "ga" "<Plug>(EasyAlign)")

;; Fuzzy finder
(let [fzf (require :fzf-lua)]
  (fzf.register_ui_select)
  (map [:n :v] "<Leader>f" fzf.builtin)
  (map [:n :v] "<Leader>h" fzf.help_tags)
  (map [:n :v] "<Leader>l" fzf.lines)
  (map [:n :v] "<Leader>g" fzf.grep_project)
  (map [:n :v] "<Leader>e" #(fzf.files {:cmd "fd . -t f"}))) ; Ignore hidden files

;; Center search results
(map :n "n" "nzz" {:silent true})
(map :n "N" "Nzz" {:silent true})
(map :n "*" "*zz" {:silent true})
(map :n "#" "#zz" {:silent true})
(map :n "g*" "g*zz" {:silent true})

;; Stop searching with backspace
(map "" "<BS>" #(vim.cmd :nohlsearch))

;; Undo
(map :n "U" "<C-R>")

;; Diagnostics
(map :n "[d" vim.diagnostic.goto_prev)
(map :n "]d" vim.diagnostic.goto_next)

;; Delete buffer
(map :n "<Leader>q" #(vim.cmd :bd))
(map :n "<Leader>w" #(vim.cmd :w))

;; Disable arrow keys but make left and right switch buffers
(map [:n :i] "<up>" "<nop>")
(map [:n :i] "<down>" "<nop>")
(map :n "<left>" #(vim.cmd :bp))
(map :i "<left>" "<nop>")
(map :n "<right>" #(vim.cmd :bn))
(map :i "<right>" "<nop>")

;; Switch windows with alt & movement keys (MAC)
(map [:n :v] "∆" "<C-W>j")
(map [:n :v] "˚" "<C-W>k")
(map [:n :v] "˙" "<C-W>h")
(map [:n :v] "¬" "<C-W>l")

;;; ================== PLUGIN SETUP ====================

;; Surround plugin
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
  (mini-comment.setup {:mappings {:comment "" :comment_line "" :textobject "gc"}}))

;; Lualine
(let [lualine (require :lualine)
      get-theme (fn [cs]
                  (match cs
                    :soluarized :solarized
                    :dracula :dracula-nvim
                    :gruvbox :powerline
                    _ (match (pcall require (.. :lualine.themes cs))
                        (true theme) theme
                        (false _) :auto)))
      wordcount #(let [dict (vim.fn.wordcount)]
                   (or dict.visual_words dict.words))]
  (lualine.setup {:options {:icons_enabled true
                            :theme (get-theme colorscheme)
                            :component_separators "|"
                            :section_separators ""
                            :globalstatus true}
                  :sections {:lualine_a [:mode]
                             :lualine_b [:diagnostics]
                             :lualine_c [:filename]
                             :lualine_x [wordcount :filetype]
                             :lualine_y [:progress]
                             :lualine_z [:location]}}))

;; Treesitter syntax highlighting
(let [tree-configs (require :nvim-treesitter.configs)]
  (tree-configs.setup {:ensure_installed treesitters
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
                                            (if (not= lang "fennel") ; only for lisps
                                                lang))}}))

;; Lsp Installer (setup before LspConfig!)
(let [lsp-installer (require :nvim-lsp-installer)]
  (lsp-installer.setup {:automatic_installation {:exclude ["zk"]}
                        :ui {:icons {:server_installed "✓"
                                     :server_pending "➜"
                                     :server_uninstalled "✗"}}}))

;; LspConfig
(local lspconfig
  (let [cmp-nvim-lsp (require :cmp_nvim_lsp)]
    {:on_attach (fn on-attach [client bufnr]
                  (let [buf {:silent true :buffer bufnr}
                        fzf (require :fzf-lua)
                        lsp-format (require :lsp-format)]
                    (lsp-format.on_attach client)
                    (map :n "gd" vim.lsp.buf.definition buf)
                    (map :n "<Leader>r" vim.lsp.buf.rename buf)
                    (map :n "<Leader>c" vim.lsp.buf.code_action buf)
                    (set vim.wo.signcolumn "yes") ; Enable signcolumn for diagnostics in current window
                    (map :n "gr" fzf.lsp_references)
                    (map :n "<Leader>d" fzf.lsp_workspace_diagnostics)))
     :settings {:Lua {:runtime {:version :LuaJIT}
                      :diagnostics {:globals :vim} ; Recognize the `vim` global
                      :workspace {:library (vim.api.nvim_get_runtime_file "" true)}
                      :telemetry {:enable false}}}
     :capabilities (cmp-nvim-lsp.update_capabilities (vim.lsp.protocol.make_client_capabilities))}))

;; Enable language servers
(each [_ lsp (pairs lsp-servers)]
  ((. (. (require :lspconfig) lsp) :setup) lspconfig))

;;; ==================== USER COMMANDS ======================
(local usercmd vim.api.nvim_create_user_command)

(usercmd :Spell (fn []
                  (print "Enabling LTeX...")
                  (let [lspconfig (require :lspconfig)]
                    (lspconfig.ltex.setup {:on_attach lspconfig.on-attach
                                           :autostart false}))
                  (vim.cmd :LspStart))
         {:desc "Enable LTeX language server for spell and grammar checking"})

;;; ==================== AUTOCOMMANDS =======================
(vim.api.nvim_create_augroup :user {:clear true})
(fn autocmd [event opts]
  (tset opts :group :user) ; Augroup for my autocommands and so they can be sourced
  (vim.api.nvim_create_autocmd event opts))

;; Indentation for fennel
(autocmd :FileType
         {:pattern "fennel"
          :callback (fn []
                      (set opt.lisp true)
                      (opt.lispwords:append [:fn :each :match :icollect :collect :for :while])
                      (opt.lispwords:remove [:if]))}) ; non-keyword indentation

;; Check and compile nvim config on save
(autocmd :BufWritePost
         {:pattern "**/nvim/**.fnl"
          :callback (fn []
                      (vim.cmd "silent FnlBuffer")
                      (let [editorconfig (require :editorconfig)]
                        (editorconfig.config)))}) ; Must reload editorconfig after sourcing nvim

;; Disable autocomment when opening line
(autocmd :FileType {:callback #(opt.formatoptions:remove "o")})

;; Highlight text when yanking
(autocmd :TextYankPost {:callback #(vim.highlight.on_yank)})

;; Open a file from its last left off position
(autocmd :BufReadPost
         {:callback (fn []
                      (when (and (not (: (vim.fn.expand "%:p") :match ".git"))
                                 (let [mark-line (vim.fn.line "'\"")]
                                   (and (> mark-line 1)
                                        (<= mark-line (vim.fn.line "$")))))
                        (vim.cmd "normal! g'\"")
                        (vim.cmd "normal zz")))})
