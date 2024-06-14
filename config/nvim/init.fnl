(set vim.g.mapleader ",")
;;; =============== QUICK CONFIG =================
(local lsp-servers [:zk :rust_analyzer :taplo :ruff_lsp :clangd :quick_lint_js :typst_lsp :nil_ls])
(local colorscheme "everforest")
(local background "dark")

;;; ================= PLUGINS ====================
(let [plugins (require :lazy)]
  (plugins.setup
    [
      "sainnhe/everforest" ; everforest
      ; "Iron-E/nvim-soluarized" ; soluarized
      ; "ellisonleao/gruvbox.nvim" ; gruvbox
      ; "olimorris/onedarkpro.nvim" ; onedark

      ;; New/better motions and operators
      {1 "tpope/vim-surround" :dependencies ["tpope/vim-repeat"]}
      {1 "numToStr/Comment.nvim" :config true}
      {1 "ggandor/leap.nvim" :dependencies ["tpope/vim-repeat"]
       :config #(let [leap (require :leap)] (leap.add_default_mappings))}
      {1 "ggandor/flit.nvim" :config true}
      {1 "echasnovski/mini.align" :keys "ga" :config #(let [align (require :mini.align)] (align.setup))}
      {1 "dhruvasagar/vim-table-mode" :keys [["<Leader>tm" #(vim.cmd :TableModeToggle)]]}

      ;; Fuzzy finder
      {1 "ibhagwan/fzf-lua" :dependencies ["kyazdani42/nvim-web-devicons"]
       :keys [["<Leader>f" #(vim.cmd "FzfLua builtin")]
              ["<Leader>h" #(vim.cmd "FzfLua helptags")]
              ["<Leader>g" #(vim.cmd "FzfLua grep_project")]
              ["gr"        #(vim.cmd "FzfLua lsp_references")]
              ["<Leader>d" #(vim.cmd "FzfLua lsp_workspace_diagnostics")]
              ["<Leader>e" #(vim.cmd "FzfLua files winopts.preview.delay=250")]]}
      "stevearc/dressing.nvim" ; Use fuzzy finder for vim.select and fancy lsp rename (vim.select)

      ;; Linting and formatting (language servers)
      "neovim/nvim-lspconfig"
      {1 "nvimtools/none-ls.nvim" :dependencies ["nvim-lua/plenary.nvim"]}
      {1 "lukas-reineke/lsp-format.nvim" :config true} ; Auto-formatting on save
      {1 "j-hui/fidget.nvim" :opts {:progress {:ignore_empty_message true}}} ; Lsp progress eye-candy
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
      ; {1 "mfussenegger/nvim-dap-python"
      ;  :config #(let [dap-python (require :dap-python)]
      ;             (set dap-python.test_runner :pytest)
      ;             (dap-python.setup (.. (vim.fn.stdpath :data)
      ;                                   "/mason/packages/debugpy/venv/bin/python")))
      ;  :ft :python :keys [["<Leader>dpr" #(let [dap-python (require :dap-python)]
      ;                                       (dap-python.test_method))]]
      ; :dependencies ["mfussenegger/nvim-dap" "rcarriga/nvim-dap-ui"]}
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
       :dependencies ["dcampos/nvim-snippy" "dcampos/cmp-snippy"
                      "lukas-reineke/cmp-under-comparator"
                      "hrsh7th/cmp-nvim-lsp" ; Completions sources (LSP, text from BUF, path completion)
                      "hrsh7th/cmp-buffer"
                      "hrsh7th/cmp-path"]}

      ;; Syntax and highlighting
      {1 "nvim-treesitter/nvim-treesitter" :build ":TSUpdate" :config #(let [ts (require :nvim-treesitter.configs)]
                                                                         (ts.setup {:auto_install true}))}
      "nvim-treesitter/nvim-treesitter-textobjects"
      {:url "https://gitlab.com/HiPhish/rainbow-delimiters.nvim.git" ; Rainbow parentheses for lisps
       :config #(let [rainbow (require :rainbow-delimiters.setup)]
                  (rainbow.setup {:whitelist [:fennel]})) :ft :fennel}
      {1 "kaarmu/typst.vim" :ft :typst}

      ;; Language specific stuff
      {1 "saecki/crates.nvim" :event "BufRead Cargo.toml" ; Rust crates assistance
       :dependencies ["nvim-lua/plenary.nvim"] :opts {:null_ls {:enabled true}
                                                      :src {:cmp {:enabled true}}}}
      "jbyuki/nabla.nvim" ; LaTeX math preview
      "mfussenegger/nvim-jdtls"

      ; ;; Notetaking
      ; {1 "nvim-neorg/neorg" :build ":Neorg sync-parsers"
      ;  :opts {:load {"core.defaults" {}
      ;                "core.completion" {:config {:engine :nvim-cmp}}}}
      ;  :dependencies ["nvim-lua/plenary.nvim"]}
      ; {1 "nvim-orgmode/orgmode"
      ;  :config #(let [orgmode (require :orgmode)]
      ;             (orgmode.setup_ts_grammar)
      ;             (orgmode.setup {:org_agenda_files ["~/Documents/org/*.org"]
      ;                             :org_default_notes_file "~/Documents/org/refile.org"}))}

      ;; Statusline
      {1 "nvim-lualine/lualine.nvim"
       :dependencies ["kyazdani42/nvim-web-devicons"]}]
    {:lockfile (vim.fn.expand "$HOME/.dotfiles/lazy-lock.json")}))

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
;; (set opt.cmdheight 0) ; EXPERIMENTAL
(set opt.colorcolumn :80)
(set opt.showcmd false) ; Don't show me what keys I'm pressing
(set opt.showmode false) ; Do not show vim mode, because I have statusline plugin
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

;; LaTeX math preview (or lsp hover)
(map :n "K" #(let [nabla-utils (require :nabla.utils)]
               (if (nabla-utils.in_mathzone)
                   (pcall (. (require :nabla) :popup))
                   (pcall vim.lsp.buf.hover))))

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

;; Switch buffers
(map :n "<Tab>" #(vim.cmd :bn))
(map :n "<S-Tab>" #(vim.cmd :bp))

;; Disable arrow keys
(map [:n :i] "<Up>" "<nop>")
(map [:n :i] "<Down>" "<nop>")
(map [:n :i] "<Left>" "<nop>")
(map [:n :i] "<Right>" "<nop>")

;;; ================== PLUGIN SETUP ====================

;; Lualine
(let [lualine (require :lualine)
      wordcount #(let [dict (vim.fn.wordcount)]
                   (or dict.visual_words dict.words))]
  (lualine.setup {:options {:icons_enabled true
                            :theme :auto
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
  (tree-config.setup {:highlight {:enable true}
                      :textobjects {:select {:enable true
                                             :lookahead true
                                             :keymaps {"ac" "@comment.outer"
                                                       "af" "@function.outer"
                                                       "if" "@function.inner"
                                                       "aa" "@parameter.outer"
                                                       "ia" "@parameter.inner"}}}}))

;; LspConfig
(local lspconfig
  {:on_attach (fn [client bufnr]
                (let [buf {:silent true :buffer bufnr}
                      lsp-format (require :lsp-format)
                      lsp-signature (require :lsp_signature)]
                  (lsp-format.on_attach client)
                  (lsp-signature.on_attach {:floating_window false :hint_prefix ""})
                  (map :n "gd" vim.lsp.buf.definition buf)
                  (map :n "<Leader>r" vim.lsp.buf.rename buf)
                  (map :n "<Leader>c" vim.lsp.buf.code_action buf)
                  (set vim.wo.signcolumn :yes))) ; Enable signcolumn for diagnostics in current window
   :settings {:pylsp {:plugins {:ruff {:extendSelect ["I"]}}}
              :fennel {:workspace {:library (vim.api.nvim_list_runtime_paths)}
                       :diagnostics {:globals ["vim"]}}}
   :capabilities (let [cmp-nvim-lsp (require :cmp_nvim_lsp)]
                   (cmp-nvim-lsp.default_capabilities))})

; ;; Haskell
; (set vim.g.haskell_tools {:hls {:on_attach lspconfig.on_attach}})

;; Java
(fn jdtls-setup []
  (let [home (os.getenv :HOME) nix-path (require :nix_path)
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

                           ; See `data directory configuration` section in the README
                           "-data" (.. home "/.local/share/jdtls/data/" (vim.fn.fnamemodify (vim.fn.getcwd) ":p:h:t"))]

                     ; One dedicated LSP server & client will be started per unique root_dir
                     :root_dir (jdtls-setup.find_root [".git" "mvnw" "gradlew"])

                     ; See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
                     :settings {:java {}}

                     ; See https://github.com/mfussenegger/nvim-jdtls#java-debug-installation
                     :init_options {:bundles {}}}]
        (jdtls.start_or_attach (collect [k v (pairs lspconfig) &into java-config] k v))))

;; Enable language servers
(let [req (require :lspconfig)]
  (each [_ server (pairs lsp-servers)]
    (let [lsp (. req server)]
      (lsp.setup lspconfig))))

;; Set up null-ls
(let [null-ls (require :null-ls)]
  (null-ls.setup {:on_attach (fn [client _]
                               (let [lsp-format (require :lsp-format)]
                                 (lsp-format.on_attach client)))
                  :sources [null-ls.builtins.formatting.alejandra
                            (null-ls.builtins.formatting.biome.with
                              {:extra_args ["--indent-style" "space"
                                            "--indent-width" "4"
                                            "--json-formatter-indent-width" "2"]})
                            (null-ls.builtins.formatting.djlint.with
                              {:extra_args ["--indent" "2"]})]}))

;;; ==================== USER COMMANDS ======================
(local usercmd vim.api.nvim_create_user_command)

;;; ==================== FILETYPES =======================
(set vim.g.c_syntax_for_h true)

;;; ==================== AUTOCOMMANDS =======================
(vim.api.nvim_create_augroup :user {:clear true})
(fn autocmd [event opts]
  (tset opts :group :user) ; Augroup for my autocommands and so they can be sourced multiple times
  (vim.api.nvim_create_autocmd event opts))

;; Java jdtls
(autocmd :FileType {:pattern :java :callback jdtls-setup})

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
