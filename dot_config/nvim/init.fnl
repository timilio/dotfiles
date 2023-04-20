;;; =============== QUICK CONFIG =================
(local treesitters [:fennel :fish :markdown :markdown_inline :rust :toml :haskell :python :lua :comment :bash :c :zig :nix :swift :org :html])
(local lsp-servers [:zk :rust_analyzer :taplo :pylsp :zls :sourcekit :lua_ls :emmet_ls])
(local colorscheme "everforest")
(local background "dark")

;;; ================= PLUGINS ====================
(let [plugins (require :lazy)]
  (plugins.setup
    ["udayvir-singh/tangerine.nvim" ; Fennel compiler

     "sainnhe/everforest" ; everforest
     "Iron-E/nvim-soluarized" ; soluarized
     "ellisonleao/gruvbox.nvim" ; gruvbox
     "olimorris/onedarkpro.nvim" ; onedarkpro
     "nyoom-engineering/oxocarbon.nvim" ; oxocarbon
     "NLKNguyen/papercolor-theme" ; PaperColor

     ;; New/better motions and operators
     {1 "tpope/vim-surround" :dependencies ["tpope/vim-repeat"]}
     {1 "numToStr/Comment.nvim" :config true}
     {1 "ggandor/leap.nvim" :dependencies ["tpope/vim-repeat"]
      :config #(let [leap (require :leap)] (leap.add_default_mappings))}
     {1 "ggandor/flit.nvim" :config true}
     {1 "echasnovski/mini.align" :config #(let [align (require :mini.align)] (align.setup))}

     ;; Fuzzy finder
     {1 "ibhagwan/fzf-lua" :dependencies ["kyazdani42/nvim-web-devicons"]}
     "stevearc/dressing.nvim" ; Use fuzzy finder for vim.select and fancy lsp rename (vim.select)

     ;; Linting (language servers)
     "neovim/nvim-lspconfig"
     {1 "williamboman/mason.nvim"
      :opts {:ui {:icons {:package_installed "✓"
                          :package_pending "➜"
                          :package_uninstalled "✗"}}}}
     {1 "williamboman/mason-lspconfig.nvim"
      :build ":PylspInstall black python-lsp-black ruff python-lsp-ruff mypy pylsp-mypy isort pyls-isort"}
     {1 "lukas-reineke/lsp-format.nvim" :config true} ; Auto-formatting on save
     {1 "j-hui/fidget.nvim" :config true} ; Lsp progress eye-candy

     ;; Autocompletion (I switched from coq_nvim because it didn't show some lsp
     ;; completions and jump to mark was janky)
     {1 "hrsh7th/nvim-cmp"
      :dependencies ["dcampos/nvim-snippy" "dcampos/cmp-snippy"
                     "hrsh7th/cmp-nvim-lsp" ; Completions sources (LSP, text from BUF, path completion)
                     "hrsh7th/cmp-buffer"
                     "hrsh7th/cmp-path"
                     {1 "jc-doyle/cmp-pandoc-references" :ft :markdown}
                     {1 "mtoohey31/cmp-fish" :ft :fish}]}

     ;; Syntax and highlighting
     {1 "nvim-treesitter/nvim-treesitter" :build ":TSUpdate"}
     "nvim-treesitter/nvim-treesitter-textobjects"
     "p00f/nvim-ts-rainbow" ; Rainbow parentheses for lisps
     {1 "fladson/vim-kitty" :ft :kitty}
     {1 "adimit/prolog.vim" :ft :prolog}

     ;; Language specific stuff
     {1 "saecki/crates.nvim" :event "BufRead Cargo.toml" ; Rust crates assistance
      :dependencies ["nvim-lua/plenary.nvim"] :config true}
     {1 "jbyuki/nabla.nvim" :commit :5379635} ; LaTeX math preview

     ;; Notetaking
     {1 "nvim-neorg/neorg" :build ":Neorg sync-parsers"
      :opts {:load {"core.defaults" {}
                    "core.completion" {:config {:engine :nvim-cmp}}}}
      :dependencies ["nvim-lua/plenary.nvim"]}
     {1 "nvim-orgmode/orgmode"
      :config #(let [orgmode (require :orgmode)]
                 (orgmode.setup_ts_grammar)
                 (orgmode.setup {:org_agenda_files ["~/Documents/org/*.org"]
                                 :org_default_notes_file "~/Documents/org/refile.org"}))}

     ;; Statusline
     {1 "nvim-lualine/lualine.nvim"
      :dependencies ["kyazdani42/nvim-web-devicons"]}]))

;;; ================= GENERAL SETTINGS =====================
(local opt vim.opt)

(set vim.g.mapleader ",")
(set opt.number true)
(set opt.relativenumber true)
(set opt.timeoutlen 500)
(set opt.undofile true) ; Permanent undo history
;; (set opt.modeline false) ; Security?
(set opt.swapfile false)
(set opt.updatetime 750) ; Make lsp more responsive
(set opt.scrolloff 5) ; Proximity in number of lines before scrolling

;; Completions
(opt.shortmess:append :c)
(set opt.pumheight 10) ; Number of autocomplete suggestions displayed at once

;; Tabs expand to 4 spaces
(set opt.shiftwidth 4)
(set opt.tabstop 4)
(set opt.softtabstop 4)
(set opt.expandtab true)

;; Better searching
(set opt.ignorecase true)
(set opt.smartcase true)

;; GUI and colorscheme
;; (set opt.cmdheight 0) ; EXPERIMENTAL
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

;; LaTeX math preview (or lsp hover)
(map :n "K" #(let [nabla (require :nabla)
                   (nabla-ok _) (pcall nabla.popup)]
               (when (not nabla-ok) (pcall vim.lsp.buf.hover))))

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
   :settings {:pylsp {:plugins {:ruff {:ignore ["E501"]}}}}
   :capabilities (let [cmp-nvim-lsp (require :cmp_nvim_lsp)]
                   (cmp-nvim-lsp.default_capabilities))})

;; Enable language servers
(let [req (require :lspconfig)]
  (each [_ server (pairs lsp-servers)]
    (let [lsp (. req server)]
      (lsp.setup lspconfig))))

;;; ==================== USER COMMANDS ======================
(local usercmd vim.api.nvim_create_user_command)

(usercmd :Spellcheck #(let [req (require :lspconfig)]
                        (req.ltex.setup {:on_attach lspconfig.on_attach
                                         :autostart false})
                        (vim.cmd :LspStart))
         {:desc "Enable LTeX language server for spell and grammar checking"})

;;; ==================== FILETYPES =======================
;; Add filetype detection for chezmoi template files
(vim.filetype.add {:extension {:tmpl (fn [path _bufnr]
                                       (let [ext (path:match "%a+%.tmpl$")]
                                         (ext:match "%a+")))}})

;;; ==================== AUTOCOMMANDS =======================
(vim.api.nvim_create_augroup :user {:clear true})
(fn autocmd [event opts]
  (tset opts :group :user) ; Augroup for my autocommands and so they can be sourced multiple times
  (vim.api.nvim_create_autocmd event opts))

;; Check and compile nvim config on save
(autocmd :BufWritePost
         {:pattern "**/nvim/**.fnl"
          :callback #(vim.cmd "silent FnlBuffer")})

;; Indentation for fennel
(autocmd :FileType
         {:pattern :fennel
          :callback #(do (set opt.lisp true)
                         (opt.lispwords:append [:fn :each :match :icollect :collect :for :while])
                         (opt.lispwords:remove [:if]))}) ; non-keyword indentation

;; Highlight text when yanking
(autocmd :TextYankPost {:callback #(vim.highlight.on_yank)})

;; Disable autocomment when opening line
(autocmd :FileType {:callback #(opt.formatoptions:remove :o)})

;; Open a file from its last left off position
(autocmd :BufReadPost
         {:callback #(when (and (not (: (vim.fn.expand "%:p") :match ".git"))
                                (let [mark-line (vim.fn.line "'\"")]
                                  (and (> mark-line 1)
                                       (<= mark-line (vim.fn.line "$")))))
                       (vim.cmd "normal! g'\"")
                       (vim.cmd "normal zz"))})
