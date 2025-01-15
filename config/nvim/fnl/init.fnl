(set vim.g.mapleader ",")
(set vim.g.maplocalleader " ")
(local map vim.keymap.set)

(fn lspconfig []
  {:on_attach (fn [client bufnr]
                (let [bufopt {:silent true :buffer bufnr}
                      lsp-format (require :lsp-format)
                      lsp-signature (require :lsp_signature)]
                  (lsp-format.on_attach client)
                  (lsp-signature.on_attach {:floating_window false :hint_prefix ""})
                  (map :n "<Leader>r" vim.lsp.buf.rename bufopt)
                  (map :n "<Leader>c" vim.lsp.buf.code_action bufopt)
                  (set vim.wo.signcolumn :yes)))
   :settings {:fennel-ls {:extra-globals "vim"}}
   :capabilities (let [cmp-nvim-lsp (require :cmp_nvim_lsp)]
                   (cmp-nvim-lsp.default_capabilities))})

;;; =============== QUICK CONFIG =================
(local lsp-servers [:bashls :clangd :fennel_ls :jedi_language_server :nil_ls
                    :quick_lint_js :r_language_server :ruff :rust_analyzer
                    :taplo :texlab :tinymist :zk])
(local colorscheme "everforest")
(local background "dark")

;;; ================= PLUGINS ====================
(let [plugins (require :lazy)]
  (plugins.setup
    {:lockfile (vim.fn.expand "$HOME/.dotfiles/lazy-lock.json")
     :rocks {:enabled false} :change_detection {:enabled false}
     :spec [
       "sainnhe/everforest" ; everforest
       ; "Iron-E/nvim-soluarized" ; soluarized
       ; "ellisonleao/gruvbox.nvim" ; gruvbox
       ; "olimorris/onedarkpro.nvim" ; onedark

       ;; New/Better Motions and Operators
       {1 "tpope/vim-surround" :dependencies ["tpope/vim-repeat"]}
       {1 "numToStr/Comment.nvim" :config true}
       {1 "ggandor/leap.nvim" :dependencies ["tpope/vim-repeat"]
        :config #(let [leap (require :leap)] (leap.add_default_mappings))}
       {1 "ggandor/flit.nvim" :config true}
       {1 "echasnovski/mini.align" :keys "ga" :config true}
       {1 "dhruvasagar/vim-table-mode" :keys [["<Leader>tm" #(vim.cmd :TableModeToggle)]]}

       ;; Fuzzy Finder
       {1 "ibhagwan/fzf-lua" :dependencies ["nvim-tree/nvim-web-devicons"]
        :keys [["<Leader>f" #(vim.cmd "FzfLua builtin")]
               ["<Leader>h" #(vim.cmd "FzfLua helptags")]
               ["<Leader>g" #(vim.cmd "FzfLua grep_project")]
               ["gr"        #(vim.cmd "FzfLua lsp_references")]
               ["<Leader>d" #(vim.cmd "FzfLua lsp_workspace_diagnostics")]
               ["<Leader>e" #(vim.cmd "FzfLua files winopts.preview.delay=250")]]}
       "stevearc/dressing.nvim" ; Use fuzzy finder for vim.select and fancy lsp rename (vim.select)

       ;; File Explorer
       {1 "stevearc/oil.nvim" :opts #(do (map :n "-" #(vim.cmd :Oil)) {})
                              :dependencies ["nvim-tree/nvim-web-devicons"]}

       ;; Linting and Formatting (LSPs)
       {1 "neovim/nvim-lspconfig" :config #(let [req (require :lspconfig)]
                                             (each [_ server (pairs lsp-servers)]
                                               (let [lsp (. req server)]
                                                 (lsp.setup (lspconfig)))))}
       {1 "lukas-reineke/lsp-format.nvim" :opts {:r {:exclude [:r_language_server]}}} ; Auto-formatting on save
       {1 "j-hui/fidget.nvim" :event :LspProgress
        :opts {:progress {:ignore_empty_message true}}} ; Lsp progress eye-candy
       {1 "nvimtools/none-ls.nvim" :dependencies ["nvim-lua/plenary.nvim"]
        :config #(let [null-ls (require :null-ls)]
          (null-ls.setup
            {:on_attach (fn [client _]
                          (let [lsp-format (require :lsp-format)]
                            (lsp-format.on_attach client)))
             :sources [null-ls.builtins.formatting.alejandra
                       (null-ls.builtins.formatting.biome.with
                         {:extra_args ["--indent-style" "space"
                                       "--indent-width" "4"
                                       "--json-formatter-indent-width" "2"]})
                       (null-ls.builtins.formatting.djlint.with
                         {:extra_args ["--indent" "2"]})]}))}
       "ray-x/lsp_signature.nvim" ; Function signature help with lsp

       ;; Debugging
       {1 "mfussenegger/nvim-dap" :dependencies ["nvim-neotest/nvim-nio" "rcarriga/nvim-dap-ui"]
        :config #(let [dap (require :dap)
                       codelldb [{:name "Launch file" :type "codelldb" :request "launch"
                                  :program #(vim.fn.input "Path to executable: " (.. (vim.fn.getcwd) "/") "file")
                                  :cwd "${workspaceFolder}" :stopOnEntry false}]]
                   (set dap.adapters.codelldb {:type "server" :port "${port}"
                                               :executable {:command "codelldb"
                                                            :args ["--port" "${port}"]}})
                   (set dap.configurations.c codelldb)
                   (set dap.configurations.cpp codelldb)
                   (set dap.configurations.rust codelldb))
        :keys [["<F5>" #(vim.cmd :DapContinue)]
               ["<End>" #(vim.cmd :DapTerminate)]
               ["<F10>" #(vim.cmd :DapStepOver)]
               ["<F11>" #(vim.cmd :DapStepInto)]
               ["<F12>" #(vim.cmd :DapStepOut)]
               ["<Leader>db" #(vim.cmd :DapToggleBreakpoint)]]}

       {1 "mfussenegger/nvim-dap-python" :enabled false
        :config #(let [dap-python (require :dap-python)]
                   (set dap-python.test_runner :pytest)
                   (dap-python.setup (.. (vim.fn.stdpath :data)
                                         "/mason/packages/debugpy/venv/bin/python")))
        :ft :python :keys [["<Leader>dpr" #(let [dap-python (require :dap-python)]
                                             (dap-python.test_method))]]
       :dependencies ["mfussenegger/nvim-dap" "rcarriga/nvim-dap-ui"]}

       {1 "rcarriga/nvim-dap-ui" :lazy true :dependencies ["mfussenegger/nvim-dap"]
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
                   (tset dap.listeners.before.event_exited :dapui_config #(dapui.close)))}

       ;; Autocompletion
       {1 "hrsh7th/nvim-cmp"
        :dependencies ["L3MON4D3/LuaSnip" "saadparwaiz1/cmp_luasnip"
                       "lukas-reineke/cmp-under-comparator"
                       "hrsh7th/cmp-buffer"
                       "hrsh7th/cmp-nvim-lsp"]}

       ;; Syntax and Highlighting
       {1 "nvim-treesitter/nvim-treesitter" :build ":TSUpdate"
        :config #(let [ts (require :nvim-treesitter.configs)]
                   (ts.setup {:highlight {:enable true}
                              :ignore_install [:org]
                              :auto_install true}))}
       {1 "hiphish/rainbow-delimiters.nvim"
        :config #(let [rainbow (require :rainbow-delimiters.setup)]
                   (rainbow.setup {:whitelist [:fennel]})) :ft :fennel}
       {1 "kaarmu/typst.vim" :ft :typst}

       ;; Language Specific
       {1 "saecki/crates.nvim" :event "BufRead Cargo.toml" :tag :stable ; Rust crates assistance
        :opts {:lsp {:enabled true :on_attach lspconfig
                     :actions true :completion true :hover true}}}
       {1 "mfussenegger/nvim-jdtls" :ft :java :config
        #(let [home (os.getenv :HOME) nix-path (require :nix_path)
               jdtls (require :jdtls) jdtls-setup (require :jdtls.setup)
               java-config {:cmd [(.. nix-path.java "/bin/java")
                                  "-Declipse.application=org.eclipse.jdt.ls.core.id1"
                                  "-Dosgi.bundles.defaultStartLevel=4"
                                  "-Declipse.product=org.eclipse.jdt.ls.core.product"
                                  "-Dlog.protocol=true"
                                  "-Dlog.level=ALL"
                                  "-Xmx1g"
                                  "--add-modules=ALL-SYSTEM"
                                  "--add-opens" "java.base/java.util=ALL-UNNAMED"
                                  "--add-opens" "java.base/java.lang=ALL-UNNAMED"
                                  "-jar" (vim.fn.glob (.. nix-path.jdtls "/share/java/jdtls/plugins/org.eclipse.equinox.launcher_*.jar"))
                                  "-configuration" (.. home "/.local/share/jdtls/config_linux")
                                  "-data" (.. home "/.local/share/jdtls/data/" (vim.fn.fnamemodify (vim.fn.getcwd) ":p:h:t"))]
                            :root_dir (jdtls-setup.find_root [".git" "mvnw" "gradlew"])
                            :settings {:java {}}
                            :init_options {:bundles {}}}
               jdtls-start #(do (jdtls.start_or_attach (collect [k v (pairs (lspconfig)) &into java-config] k v))
                                false)] ; autocmd gets removed otherwise
           (vim.api.nvim_create_autocmd :FileType {:pattern :java :callback jdtls-start})
           (jdtls-start))}
       {1 "julian/lean.nvim" :ft :lean
        :config #(let [lean (require :lean)]
                   (lean.setup {:mappings true
                                :lsp {:on_attach (. (lspconfig) :on_attach)}}))
        :dependencies ["neovim/nvim-lspconfig" "nvim-lua/plenary.nvim"]}
       {1 "jbyuki/nabla.nvim" ; LaTeX math preview
        :keys [["K" #(let [nabla-utils (require :nabla.utils)]
                       (if (nabla-utils.in_mathzone)
                           (pcall (. (require :nabla) :popup))
                           (pcall vim.lsp.buf.hover)))]]}

       ;; Org Mode
       {1 "nvim-orgmode/orgmode" :event :VeryLazy :ft :org
        :opts {:org_agenda_files ["~/Documents/org/**/*"]
               :org_default_notes_file "~/Documents/org/refile.org"}}
       {1 "chipsenkbeil/org-roam.nvim" :dependencies ["nvim-orgmode/orgmode"]
        :opts {:directory "~/Documents/org"} :keys "<Leader>n"}

       ;; Statusline
       {1 "nvim-lualine/lualine.nvim" :dependencies ["nvim-tree/nvim-web-devicons"]
        :opts {:options {:icons_enabled true
                                    :theme :auto
                                    :component_separators "|"
                                    :section_separators ""
                                    :globalstatus true}
                          :sections {:lualine_a [:mode]
                                     :lualine_b [:diagnostics]
                                     :lualine_c [:filename]
                                     :lualine_x [#(let [dict (vim.fn.wordcount)]
                                                    (or dict.visual_words dict.words))
                                                 :encoding :fileformat :filetype]
                                     :lualine_y [:progress]
                                     :lualine_z [:location]}}}]}))

;;; ================= GENERAL SETTINGS =====================
(local opt vim.opt)

(set opt.number true)
(set opt.relativenumber true)
(set opt.timeoutlen 500)
(set opt.undofile true) ; Permanent undo history
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
(set opt.colorcolumn :80)
(set opt.showcmd false) ; Don't show me what keys I'm pressing
(set opt.showmode false) ; Statusline already shows this
(set opt.background background)
(vim.cmd.colorscheme colorscheme)

(vim.diagnostic.config {:signs {:text {vim.diagnostic.severity.ERROR "󰅚 "
                                       vim.diagnostic.severity.WARN "󰀪 "
                                       vim.diagnostic.severity.INFO "󰋽 "
                                       vim.diagnostic.severity.HINT "󰌶 "}}})

;;; =================== KEYBOARD MAPPINGS ======================

;; Center search results
(map :n "n" "nzz" {:silent true})
(map :n "N" "Nzz" {:silent true})
(map :n "*" "*zz" {:silent true})
(map :n "#" "#zz" {:silent true})
(map :n "g*" "g*zz" {:silent true})

;; Stop searching
(map :n "<Esc>" #(vim.cmd :nohlsearch))

;; Undo
(map :n "U" "<C-r>")

;; Diagnostics
(map :n "[d" vim.diagnostic.goto_prev)
(map :n "]d" vim.diagnostic.goto_next)

;; Buffers
(map :n "<Leader>q" #(vim.cmd :bd))
(map :n "<Tab>" #(vim.cmd :bn))
(map :n "<C-i>" "<C-i>") ; Make neovim differentiate <Tab> and <C-I>
(map :n "<S-Tab>" #(vim.cmd :bp))

;; Disable arrow keys
(map [:n :i] "<Up>" "<nop>")
(map [:n :i] "<Down>" "<nop>")
(map [:n :i] "<Left>" "<nop>")
(map [:n :i] "<Right>" "<nop>")

;;; ==================== USER COMMANDS ======================
; (local usercmd vim.api.nvim_create_user_command)

;;; ==================== FILETYPES =======================
(set vim.g.c_syntax_for_h true)

;;; ==================== AUTOCOMMANDS =======================
(vim.api.nvim_create_augroup :user {:clear true})
(fn autocmd [event opts]
  (tset opts :group :user) ; Augroup for my autocommands and so they can be sourced multiple times
  (vim.api.nvim_create_autocmd event opts))

;; Highlight text when yanking
(autocmd :TextYankPost {:callback #(vim.highlight.on_yank)})

;; Indentation for fennel
(autocmd :FileType
         {:pattern :fennel
          :callback #(do (set opt.lisp true)
                         (opt.lispwords:append [:fn :each :match :icollect :collect :for :while])
                         (opt.lispwords:remove [:if]))})

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
