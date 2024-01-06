;;; =============== QUICK CONFIG =================
(local treesitters [:fennel :fish :markdown :markdown_inline :rust :toml :haskell :python :lua :comment :bash :c :cpp :zig :nix :html :css :javascript :sql :latex :elixir])
(local lsp-servers [:zk :rust_analyzer :taplo :pylsp :zls :clangd :lua_ls :fennel_language_server :quick_lint_js :texlab :typst_lsp :elixirls :nil_ls])
(local colorscheme "everforest")
(local background "dark")

;;; ================= PLUGINS ====================
(let [plugins (require :lazy)]
  (plugins.setup
    ["udayvir-singh/tangerine.nvim" ; Fennel compiler

     "sainnhe/everforest" ; everforest
     "Iron-E/nvim-soluarized" ; soluarized
     "ellisonleao/gruvbox.nvim" ; gruvbox
     "olimorris/onedarkpro.nvim" ; onedark

     ;; New/better motions and operators
     {1 "tpope/vim-surround" :dependencies ["tpope/vim-repeat"]}
     {1 "numToStr/Comment.nvim" :config true}
     {1 "ggandor/leap.nvim" :dependencies ["tpope/vim-repeat"]
      :config #(let [leap (require :leap)] (leap.add_default_mappings))}
     {1 "ggandor/flit.nvim" :config true}
     {1 "echasnovski/mini.align" :config #(let [align (require :mini.align)] (align.setup))}
     "dhruvasagar/vim-table-mode" ; <leader>tm

     ;; Fuzzy finder
     {1 "ibhagwan/fzf-lua" :dependencies ["kyazdani42/nvim-web-devicons"]}
     "stevearc/dressing.nvim" ; Use fuzzy finder for vim.select and fancy lsp rename (vim.select)

     ;; Linting and formatting (language servers)
     "neovim/nvim-lspconfig"
     {1 "williamboman/mason.nvim" :build ":MasonUpdate"
      :opts {:providers []}}
     {1 "williamboman/mason-lspconfig.nvim"
      :build ":PylspInstall black python-lsp-black ruff python-lsp-ruff mypy pylsp-mypy"}
     {1 "nvimtools/none-ls.nvim" :dependencies ["nvim-lua/plenary.nvim"]}
     "jay-babu/mason-null-ls.nvim"
     {1 "lukas-reineke/lsp-format.nvim" :config true} ; Auto-formatting on save
     {1 "j-hui/fidget.nvim" :tag "legacy" :config true} ; Lsp progress eye-candy
     "ray-x/lsp_signature.nvim" ; Function signature help with lsp

     ;; Debugging
     "mfussenegger/nvim-dap"
     {1 "jay-babu/mason-nvim-dap.nvim" :opts {:ensure_installed ["python" "codelldb"]}}
     {1 "mfussenegger/nvim-dap-python"
      :config #(let [dap-python (require :dap-python)]
                 (set dap-python.test_runner :pytest)
                 (dap-python.setup (.. (vim.fn.stdpath :data)
                                       "/mason/packages/debugpy/venv/bin/python")))
      :ft :python :dependencies ["mfussenegger/nvim-dap" "rcarriga/nvim-dap-ui"]}
     {1 "rcarriga/nvim-dap-ui"
      :config #(let [dap (require :dap) dapui (require :dapui)]
                 (dapui.setup {:layouts [{:elements [{:id "breakpoints" :size 0.10}
                                                     {:id "stacks" :size 0.25}
                                                     {:id "watches" :size 0.25}
                                                     {:id "scopes" :size 0.40}]
                                          :size 40
                                          :position "left"}
                                         {:elements [{:id "repl" :size 0.55}
                                                     {:id "console" :size 0.45}]
                                          :size 10
                                          :position "bottom"}]})
                 (tset dap.listeners.after.event_initialized :dapui_config #(dapui.open {:reset true}))
                 (tset dap.listeners.before.event_terminated :dapui_config #(dapui.close))
                 (tset dap.listeners.before.event_exited :dapui_config #(dapui.close)))
      :dependencies ["mfussenegger/nvim-dap"]}

     ;; Autocompletion (I switched from coq_nvim because it didn't show some lsp
     ;; completions and jump to mark was janky)
     {1 "hrsh7th/nvim-cmp"
      :dependencies ["dcampos/nvim-snippy" "dcampos/cmp-snippy"
                     "lukas-reineke/cmp-under-comparator"
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
     {1 "kaarmu/typst.vim" :ft :typst :commit :e72561f}

     ;; Language specific stuff
     {1 "saecki/crates.nvim" :event "BufRead Cargo.toml" ; Rust crates assistance
      :dependencies ["nvim-lua/plenary.nvim"] :opts {:null_ls {:enabled true}
                                                     :src {:cmp {:enabled true}}}}
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
(each [kind sign (pairs {:Error "󰅚 " :Warn "󰀪 " :Hint "󰌶 " :Info "󰋽 "})]
  (let [hl (.. "DiagnosticSign" kind)]
    (vim.fn.sign_define hl {:text sign :texthl hl :numhl hl})))

;; Debugging icons
(vim.fn.sign_define :DapBreakpoint {:text " " :texthl "red"})
(vim.fn.sign_define :DapStopped {:text " " :texthl "green"})

;;; =================== KEYBOARD MAPPINGS ======================
(local map vim.keymap.set)

;; Debugging
(map :n "<Leader>dc" #(vim.cmd :DapContinue))
(map :n "<Leader>db" #(vim.cmd :DapToggleBreakpoint))
(map :n "<Leader>dpr" #(let [dap-python (require :dap-python)]
                         (dap-python.test_method)))

;; LaTeX math preview (or lsp hover)
(map :n "K" #(let [nabla (require :nabla)
                   (nabla-ok _) (pcall nabla.popup)]
               (when (not nabla-ok) (pcall vim.lsp.buf.hover))))

(map :n "<Leader>tm" #(vim.cmd :TableModeToggle))

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
                             :lualine_x [wordcount :encoding :fileformat :filetype]
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
                                           (if (not= lang :fennel) lang))}})) ; only for lisps

;; Lsp Installer (setup before LspConfig!)
(let [lsp-installer (require :mason-lspconfig)]
  (lsp-installer.setup {:ensure_installed (icollect [_ lsp (ipairs lsp-servers)]
                                            (if (not= lsp :zk) lsp))}))

;; LspConfig
(local lspconfig
  {:on_attach (fn [client bufnr]
                (let [buf {:silent true :buffer bufnr}
                      fzf (require :fzf-lua)
                      lsp-format (require :lsp-format)
                      lsp-signature (require :lsp_signature)]
                  (lsp-format.on_attach client)
                  (lsp-signature.on_attach {:doc_lines 0 :hint_enable false})
                  (map :n "gd" vim.lsp.buf.definition buf)
                  (map :n "<Leader>r" vim.lsp.buf.rename buf)
                  (map :n "<Leader>c" vim.lsp.buf.code_action buf)
                  (set vim.wo.signcolumn :yes) ; Enable signcolumn for diagnostics in current window
                  (map :n "gr" fzf.lsp_references)
                  (map :n "<Leader>d" fzf.lsp_workspace_diagnostics)))
   :settings {:pylsp {:plugins {:ruff {:extendSelect ["I"]}}}
              :fennel {:workspace {:library (vim.api.nvim_list_runtime_paths)}
                       :diagnostics {:globals ["vim"]}}}
   :capabilities (let [cmp-nvim-lsp (require :cmp_nvim_lsp)]
                   (cmp-nvim-lsp.default_capabilities))})

;; Enable language servers
(let [req (require :lspconfig)]
  (each [_ server (pairs lsp-servers)]
    (let [lsp (. req server)]
      (lsp.setup lspconfig))))

;; Set up null-ls
(let [null-ls (require :null-ls)
      mason-null-ls (require :mason-null-ls)]
  (null-ls.setup {:on_attach (fn [client _]
                               (let [lsp-format (require :lsp-format)]
                                 (lsp-format.on_attach client)))
                  :sources [(null-ls.builtins.formatting.biome.with
                              {:extra_args ["--indent-style" "space"
                                            "--indent-size" "4"]
                               :disabled_filetypes [:json]})
                            null-ls.builtins.formatting.fixjson
                            (null-ls.builtins.formatting.djlint.with
                              {:extra_args ["--indent" "2"]})]})
  (mason-null-ls.setup {:automatic_installation true}))

;; Debugging
(let [dap (require :dap)
      codelldb [{:name "Launch file" :type "codelldb" :request "launch"
                 :program #(vim.fn.input "Path to executable: " (.. (vim.fn.getcwd) "/") "file")
                 :cwd "${workspaceFolder}" :stopOnEntry false}]]
  (set dap.adapters.codelldb {:type "server" :port "${port}"
                              :executable {:command (.. (vim.fn.stdpath :data)
                                                        "/mason/packages/codelldb/extension/adapter/codelldb")
                                           :args ["--port" "${port}"]}})
  (set dap.configurations.c codelldb)
  (set dap.configurations.cpp codelldb)
  (set dap.configurations.rust codelldb))

;;; ==================== USER COMMANDS ======================
(local usercmd vim.api.nvim_create_user_command)

(usercmd :Spellcheck #(let [req (require :lspconfig)]
                        (req.ltex.setup {:on_attach lspconfig.on_attach
                                         :autostart false})
                        (vim.cmd :LspStart))
         {:desc "Enable LTeX language server for spell and grammar checking"})

;;; ==================== FILETYPES =======================
(set vim.g.c_syntax_for_h true)

;; Add filetype detection for chezmoi template files
(vim.filetype.add {:extension {:tmpl (fn [path _bufnr]
                                       (let [ext (path:match "%a+%.tmpl$")]
                                         (ext:match "%a+")))}})

;;; ==================== AUTOCOMMANDS =======================
(vim.api.nvim_create_augroup :user {:clear true})
(fn autocmd [event opts]
  (tset opts :group :user) ; Augroup for my autocommands and so they can be sourced multiple times
  (vim.api.nvim_create_autocmd event opts))

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
