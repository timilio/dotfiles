;;; =============== QUICK CONFIG =================
(local treesitters [:fennel :fish :markdown :markdown_inline :rust :toml :haskell :python :lua :bash :c :zig :nix])
(local lsp-servers [:zk :rust_analyzer :taplo :pylsp :hls :zls])
(local colorscheme "everforest")
(local background "dark")

;;; ================= PLUGINS ====================
(let [packer (require :packer)]
  (packer.startup
    (fn [use]
      (use "wbthomason/packer.nvim") ; Package manager
      (use "udayvir-singh/tangerine.nvim") ; Fennel compiler

      ;; Colorschemes
      (use "Iron-E/nvim-soluarized") ; soluarized
      (use "ellisonleao/gruvbox.nvim") ; gruvbox
      (use "sainnhe/everforest") ; everforest
      (use "olimorris/onedarkpro.nvim") ; onedarkpro
      (use {1 "shaunsingh/oxocarbon.nvim" :run "./install.sh"}) ; oxocarbon
      (use "EdenEast/nightfox.nvim")

      ;; Vim improvements
      (use "gpanders/editorconfig.nvim") ; https://editorconfig.org/
      (use {1 "ahmedkhalf/project.nvim" ; Automatically cd into root dir
            :config #(let [project (require :project_nvim)]
                       (project.setup {:patterns [".git" ".zk"]
                                       :exclude_dirs ["~/Documents/ossu/*"]}))})

      ;; New/better motions and operators
      (use {1 "tpope/vim-surround" :requires "tpope/vim-repeat"})
      (use {1 "numToStr/Comment.nvim"
            :config #(let [Comment (require :Comment)] (Comment.setup))})
      (use {1 "ggandor/leap.nvim" :requires "tpope/vim-repeat"
            :config #(let [leap (require :leap)] (leap.set_default_keymaps))})
      (use "rhysd/clever-f.vim")
      (use {1 "junegunn/vim-easy-align" :requires "tpope/vim-repeat"})

      ;; Fuzzy finder
      (use {1 "ibhagwan/fzf-lua"
            :requires ["/usr/local/opt/fzf" "kyazdani42/nvim-web-devicons"]})
      (use "stevearc/dressing.nvim") ; Use fuzzy finder for vim.select and fancy lsp rename (vim.select)

      ;; Linting (language servers)
      (use "neovim/nvim-lspconfig")
      (use "williamboman/mason.nvim")
      (use "williamboman/mason-lspconfig.nvim")
      (use {1 "lukas-reineke/lsp-format.nvim" ; Auto-formatting on save
            :config #(let [format (require :lsp-format)] (format.setup))})
      (use {1 "j-hui/fidget.nvim" ; Lsp progress eye-candy
            :config #(let [fidget (require :fidget)] (fidget.setup))})

      ;; Autocompletion (I switched from coq_nvim because it didn't show some lsp
      ;; completions and jump to mark was janky)
      (use {1 "hrsh7th/nvim-cmp"
            :requires ["L3MON4D3/LuaSnip" "saadparwaiz1/cmp_luasnip"]})
      (use ["hrsh7th/cmp-nvim-lsp" ; Completions sources (LSP, text from BUF, path completion)
            "hrsh7th/cmp-buffer"
            "hrsh7th/cmp-path"
            {1 "jc-doyle/cmp-pandoc-references" :ft :markdown}
            {1 "mtoohey31/cmp-fish" :ft :fish}])

      ;; Syntax and highlighting
      (use {1 "nvim-treesitter/nvim-treesitter" :run ":TSUpdate"})
      ;; (use "nvim-treesitter/nvim-treesitter-textobjects")
      (use "p00f/nvim-ts-rainbow") ; Rainbow parentheses for lisps
      (use {1 "fladson/vim-kitty" :ft :kitty})
      (use {1 "adimit/prolog.vim" :ft :prolog})

      ;; Language specific stuff
      (use {1 "saecki/crates.nvim" ; Rust crates assistance
            :event "BufRead Cargo.toml"
            :requires "nvim-lua/plenary.nvim"
            :config #(let [crates (require :crates)] (crates.setup))})
      (use {1 "jbyuki/nabla.nvim" :commit :5379635}) ; LaTeX math preview

      ;; Statusline
      (use {1 "nvim-lualine/lualine.nvim"
            :requires ["kyazdani42/nvim-web-devicons"]}))))

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
(opt.shortmess:append :c)
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
; (set opt.cmdheight 0) ; EXPERIMENTAL
(set opt.colorcolumn :80)
(set opt.showcmd false) ; Don't show me what keys I'm pressing
(set opt.showmode false) ; Do not show vim mode, because I have statusline plugin
(set opt.termguicolors true) ; Make colors display correctly
(set opt.background background)
(vim.cmd.colorscheme colorscheme)

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
  (map [:n :v] "<Leader>f" fzf.builtin)
  (map [:n :v] "<Leader>h" fzf.help_tags)
  (map [:n :v] "<Leader>g" fzf.grep_project)
  (map [:n :v] "<Leader>e" fzf.files))

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

;; Lualine
(let [lualine (require :lualine)
      get-theme (fn [cs]
                  (match cs
                    :soluarized :solarized
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
(let [tree-config (require :nvim-treesitter.configs)]
  (tree-config.setup {:ensure_installed treesitters
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
                                           (if (not= lang :fennel) ; only for lisps
                                               lang))}}))

;; Mason (lsp-installer/...)
(let [mason (require :mason)]
  (mason.setup {:ui {:icons {:package_installed "✓"
                             :package_pending "➜"
                             :package_uninstalled "✗"}}}))

;; Lsp Installer (setup before LspConfig!)
(let [lsp-installer (require :mason-lspconfig)]
  (lsp-installer.setup {:automatic_installation {:exclude [:zk]}}))

;; LspConfig
(local lspconfig
  {:on_attach (fn on-attach [client bufnr]
                (let [buf {:silent true :buffer bufnr}
                      fzf (require :fzf-lua)
                      lsp-format (require :lsp-format)]
                  (lsp-format.on_attach client)
                  (map :n "gd" vim.lsp.buf.definition buf)
                  (map :n "<Leader>r" vim.lsp.buf.rename buf)
                  (map :n "<Leader>c" vim.lsp.buf.code_action buf)
                  (set vim.wo.signcolumn :yes) ; Enable signcolumn for diagnostics in current window
                  (map :n "gr" fzf.lsp_references)
                  (map :n "<Leader>d" fzf.lsp_workspace_diagnostics)))
   :settings {:pylsp {:plugins {:autopep8 {:enabled false}}}} ; use YAPF instead
   :capabilities (let [cmp-nvim-lsp (require :cmp_nvim_lsp)]
                   (cmp-nvim-lsp.default_capabilities))})

;; Enable language servers
(let [req (require :lspconfig)]
  (each [_ server (pairs lsp-servers)]
    (let [lsp (. req server)]
      (lsp.setup lspconfig))))

;;; ==================== USER COMMANDS ======================
(local usercmd vim.api.nvim_create_user_command)

(usercmd :Spell (fn []
                  (print "Enabling LTeX...")
                  (let [req (require :lspconfig)]
                    (req.ltex.setup {:on_attach lspconfig.on-attach
                                           :autostart false}))
                  (vim.cmd :LspStart))
         {:desc "Enable LTeX language server for spell and grammar checking"})

;;; ==================== FILETYPES =======================
(vim.filetype.add {:extension {:tmpl (fn [path _bufnr]
                                       (let [ext (path:match "%a+%.tmpl$")]
                                         (ext:match "%a+")))}})

;;; ==================== AUTOCOMMANDS =======================
(vim.api.nvim_create_augroup :user {:clear true})
(fn autocmd [event opts]
  (tset opts :group :user) ; Augroup for my autocommands and so they can be sourced multiple times
  (vim.api.nvim_create_autocmd event opts))

;; Highlight text when yanking
(autocmd :TextYankPost {:callback #(vim.highlight.on_yank)})

;; Disable autocomment when opening line
(autocmd :FileType {:callback #(opt.formatoptions:remove :o)})

;; Indentation for fennel
(autocmd :FileType
         {:pattern :fennel
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

;; Open a file from its last left off position
(autocmd :BufReadPost
         {:callback (fn []
                      (when (and (not (: (vim.fn.expand "%:p") :match ".git"))
                                 (let [mark-line (vim.fn.line "'\"")]
                                   (and (> mark-line 1)
                                        (<= mark-line (vim.fn.line "$")))))
                        (vim.cmd "normal! g'\"")
                        (vim.cmd "normal zz")))})
