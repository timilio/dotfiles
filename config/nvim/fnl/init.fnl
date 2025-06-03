;;; =============== QUICK CONFIG =================
(local lsp-servers [:bashls :clangd :fennel_ls :gdscript :glsl_analyzer
                    :jedi_language_server :neocmake :nil_ls :quick_lint_js
                    :r_language_server :ruff :rust_analyzer :taplo :tinymist
                    :zk :zls])
(local colorscheme "everforest")
(local background "dark")

;;; =============== INTRODUCTION =================
(set vim.g.mapleader ",")
(set vim.g.maplocalleader " ")
(local map vim.keymap.set)
(local autocmd (let [group (vim.api.nvim_create_augroup :MyAugroup {})]
                 (lambda [event opts cb]
                   (set opts.group group)
                   (set opts.callback #(do (cb $...) false)) ; false = don't delete autocmd
                   (vim.api.nvim_create_autocmd event opts))))

(local on-attach
  (fn [_ bufnr]
    (let [opts {:silent true :buffer bufnr} bo (. vim.bo bufnr)]
      (map :n "gD" vim.lsp.buf.definition opts)
      (map :n "gd" vim.lsp.buf.definition opts)
      (map :n "gy" vim.lsp.buf.type_definition opts)
      (map :n "gi" vim.lsp.buf.implementation opts)
      (map :n "gr" vim.lsp.buf.references opts)
      (map [:n :v] "<Leader>a" vim.lsp.buf.code_action opts)
      (map :n "<Leader>r" vim.lsp.buf.rename opts)
      (set bo.omnifunc "v:lua.MiniCompletion.completefunc_lsp"))))
(autocmd :LspAttach {} #(on-attach (vim.lsp.get_client_by_id $1.data.client_id) $1.buf))

;;; ================= PLUGINS ====================
(let [plugins (require "lazy")]
  (plugins.setup
    {:lockfile (vim.fn.expand "$HOME/.dotfiles/lazy-lock.json")
     :rocks {:enabled false} :change_detection {:enabled false}
     :spec [
       "sainnhe/everforest" ; everforest
       ; {1 "zenbones-theme/zenbones.nvim" :dependencies ["rktjmp/lush.nvim"]}
       ; "https://gitlab.com/protesilaos/tempus-themes-vim.git"
       ; "ellisonleao/gruvbox.nvim" ; gruvbox

       {1 "echasnovski/mini.basics" :opts {:mappings {:basic false}}}

       ;; New/Better Motions and Operators
       {1 "tpope/vim-surround" :dependencies ["tpope/vim-repeat"]}
       {1 "ggandor/leap.nvim" :dependencies ["tpope/vim-repeat"]
        :config #(let [leap (require "leap")] (leap.set_default_mappings))}
       {1 "ggandor/flit.nvim" :dependencies ["ggandor/leap.nvim"] :opts {}}
       {1 "echasnovski/mini.align" :keys ["ga" "gA"] :opts {}}
       {1 "echasnovski/mini.pairs" :event :InsertEnter :opts {:mappings {"'" false}}}
       {1 "dhruvasagar/vim-table-mode" :keys [["<Leader>tm" #(vim.cmd :TableModeToggle)]]}

       ;; GUI
       {1 "j-hui/fidget.nvim" :event :LspProgress :opts {}} ; Show LSP loading
       {1 "folke/snacks.nvim" :priority 1000
        :opts {:bigfile {:enabled true} :input {:enabled true}
               :styles {:input {:keys {:i_esc {2 ["cmp_close" "<Esc>"]}}}}}} ; https://github.com/folke/snacks.nvim/issues/1841
       {1 "echasnovski/mini.icons" :opts {}}
       {1 "echasnovski/mini.statusline" :opts {}}
       ; {1 "echasnovski/mini.pick" :keys [["<Leader>h" #(vim.cmd "Pick help")]
       ;                                   ["<Leader>e" #(vim.cmd "Pick files")]
       ;                                   ["<Leader>g" #(vim.cmd "Pick grep_live")]]
       ;  :opts #(let [pick (require "mini.pick")]
       ;           (set vim.ui.select pick.ui_select) {})}

       ;; Navigation
       {1 "ibhagwan/fzf-lua" :event :VeryLazy
        :opts #(let [fzf (require "fzf-lua")] (fzf.register_ui_select)
                 {1 :fzf-native :defaults {:path_shorten true}
                  :previewers {:bat {:args "--color always"}
                               :codeaction_native {:pager "delta --width=$COLUMNS --hunk-header-style=omit --file-style=omit"}}})
        :keys [["<Leader>c" #(vim.cmd "FzfLua builtin")]
               ["<Leader>h" #(vim.cmd "FzfLua helptags")]
               ["<Leader>g" #(vim.cmd "FzfLua grep_project")]
               ["<Leader>e" #(vim.cmd "FzfLua files winopts.preview.delay=250")]]}
       {1 "stevearc/oil.nvim" :opts #(do (map :n "-" #(vim.cmd :Oil)) {})}

       ;; Linting and Formatting (LSPs)
       "neovim/nvim-lspconfig"
       {1 "stevearc/conform.nvim" :event :BufWritePre :cmd :ConformInfo
        :opts {:formatters_by_ft {:nix ["alejandra"]
                                  :cmake ["gersemi"]}
               :format_after_save {:lsp_format :fallback}}}

       ;; Debugging
       {1 "mfussenegger/nvim-dap" :dependencies ["nvim-neotest/nvim-nio" "rcarriga/nvim-dap-ui"]
        :config #(let [dap (require "dap")
                       godot [{:name "Launch scene" :type :godot :request "launch"
                               :project "${workspaceFolder}" :launch_scene true}]
                       codelldb [{:name "Launch file" :type :codelldb :request "launch"
                                  :program #(vim.fn.input "Path to executable: " (.. (vim.fn.getcwd) "/") "file")
                                  :cwd "${workspaceFolder}" :stopOnEntry false}]]
                   (set dap.adapters.codelldb {:type "server" :port "${port}"
                                               :executable {:command "codelldb"
                                                            :args ["--port" "${port}"]}})
                   (set dap.adapters.godot {:type "server" :host "127.0.0.1" :port 6006})
                   (set dap.configurations.c codelldb)
                   (set dap.configurations.cpp codelldb)
                   (set dap.configurations.gdscript godot)
                   (set dap.configurations.rust codelldb))
        :keys [["<F5>" #(vim.cmd :DapContinue)]
               ["<End>" #(vim.cmd :DapTerminate)]
               ["<F10>" #(vim.cmd :DapStepOver)]
               ["<F11>" #(vim.cmd :DapStepInto)]
               ["<F12>" #(vim.cmd :DapStepOut)]
               ["<Leader>db" #(vim.cmd :DapToggleBreakpoint)]]}
       {1 "rcarriga/nvim-dap-ui" :dependencies ["mfussenegger/nvim-dap"]
        :keys [["<Leader>dt" #(let [dapui (require "dapui")] (dapui.toggle))]]
        :opts {:layouts [{:size 40 :position "left"
                          :elements [{:id "breakpoints" :size 0.10}
                                     {:id "stacks" :size 0.25}
                                     {:id "watches" :size 0.25}
                                     {:id "scopes" :size 0.40}]}
                         {:size 10 :position "bottom"
                          :elements [{:id "repl" :size 0.55}
                                     {:id "console" :size 0.45}]}]}}

       ;; Autocompletion
       {1 "echasnovski/mini.completion"
        :opts #(let [imap #(map :i $1 $2 {:expr true})
                     pumvisible? #(not= (vim.fn.pumvisible) 0)]
                 (imap "<Tab>"   #(if (pumvisible?) "<C-n>" "<Tab>"))
                 (imap "<S-Tab>" #(if (pumvisible?) "<C-p>" "<S-Tab>"))
                 (imap "<CR>" #(if (not= (. (vim.fn.complete_info) "selected") -1) "<C-y>" (_G.MiniPairs.cr)))
                 {:source_func :omnifunc :auto_setup false
                  :fallback_action #(if (= vim.opt.filetype._value :tex)
                                        (vim.api.nvim_feedkeys (vim.keycode "<C-x><C-o>") :m false))})}
       {1 "echasnovski/mini.snippets"
        :opts #(let [mini-snippets (require "mini.snippets")]
                 {:snippets [(mini-snippets.gen_loader.from_lang)]})}

       ;; Syntax and Highlighting
       {1 "nvim-treesitter/nvim-treesitter" :branch :main :build ":TSUpdate"
        :init #(autocmd :FileType {} #(let [lang $1.match buf $1.buf
                                            bo (. vim.bo buf)
                                            ts (require "nvim-treesitter")
                                            ts-conf (require "nvim-treesitter.config")]
                                        (when (and (vim.tbl_contains (ts-conf.get_available) lang)
                                                 (not (vim.list_contains ["latex" "org"] lang)))
                                              (: (ts.install lang) :await
                                                 #(when (vim.api.nvim_buf_is_valid buf)
                                                    (set bo.indentexpr "v:lua.require'nvim-treesitter'.indentexpr()")
                                                    (vim.treesitter.start buf lang))))))}
       {1 "hiphish/rainbow-delimiters.nvim" :submodules false
        :config #(let [rainbow (require "rainbow-delimiters.setup")]
                   (rainbow.setup {:whitelist ["fennel"]})) :ft "fennel"}

       ;; Language Specific
       {1 "lervag/vimtex" :ft "tex"
        :keys [["<LocalLeader>ls" "<plug>(vimtex-compile-ss)"]]
        :init #(do (set vim.g.vimtex_quickfix_ignore_filters
                     ["Draft mode on."
                      "\\\\AtBeginDocument{\\\\RenewCommandCopy\\\\qty\\\\SI}"])
                   (set vim.g.vimtex_doc_handlers ["vimtex#doc#handlers#texdoc"]))}
       {1 "kaarmu/typst.vim" :ft "typst"}
       {1 "julian/lean.nvim" :ft "lean" :opts {:mappings true}
        :dependencies ["neovim/nvim-lspconfig" "nvim-lua/plenary.nvim"]}
       {1 "saecki/crates.nvim" :event "BufRead Cargo.toml" :tag :stable
        :opts {:lsp {:enabled true :actions true :completion true :hover true}}}
       {1 "mfussenegger/nvim-jdtls" :ft "java" :config
        #(let [home (os.getenv :HOME) nix-path (require "nix_path")
               jdtls (require "jdtls") jdtls-setup (require "jdtls.setup")
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
                            :on_attach on-attach
                            :init_options {:bundles {}}}]
           (autocmd :FileType {:pattern "java"} #(jdtls.start_or_attach java-config))
           (jdtls.start_or_attach java-config))}

       ;; Org Mode
       {1 "nvim-orgmode/orgmode" :event :VeryLazy :ft "org"
        :opts {:org_agenda_files ["~/Documents/org/**/*"]
               :org_default_notes_file "~/Documents/org/refile.org"
               :org_capture_templates {:t {:description "Task" :template "* TODO %?\n  %u"}
                                       :i {:description "Idea" :template "* %? :idea:\n  %u"}}}}
       {1 "chipsenkbeil/org-roam.nvim" :dependencies ["nvim-orgmode/orgmode"]
        :opts {:directory "~/Documents/org"} :keys "<Leader>n"}]}))

;;; =======================  LSP  ==========================
(vim.lsp.config :rust_analyzer {:settings {:rust-analyzer {:completion {:postfix {:enable false}}}}})
(vim.lsp.config :fennel_ls {:settings {:fennel-ls {:extra-globals "vim"}}})

(each [_ server (ipairs lsp-servers)] (vim.lsp.enable server))

;;; ================= GENERAL SETTINGS =====================
(set vim.opt.relativenumber true)
(set vim.opt.swapfile false)
(set vim.opt.scrolloff 4) ; Proximity in number of lines before scrolling
(set vim.opt.pumheight 10) ; Number of autocomplete suggestions displayed at once

;; Tabs expand to 4 spaces
(set vim.opt.shiftwidth 4)
(set vim.opt.softtabstop 4)
(set vim.opt.expandtab true)

;; GUI and colorscheme
(set vim.opt.cursorline false)
(set vim.opt.colorcolumn :80)
(autocmd :FileType {:pattern "rust"} #(set vim.opt.colorcolumn :100))
(set vim.opt.showcmd false) ; Don't show me what keys I'm pressing
(set vim.opt.background background)
(vim.cmd.colorscheme colorscheme)

(vim.diagnostic.config {:jump {:on_jump vim.diagnostic.open_float} ; Show diagnostic on jump (e.g. ]d)
                        :signs {:text {vim.diagnostic.severity.ERROR "󰅚 "
                                       vim.diagnostic.severity.WARN "󰀪 "
                                       vim.diagnostic.severity.INFO "󰋽 "
                                       vim.diagnostic.severity.HINT "󰌶 "}}})
(set vim.g.c_syntax_for_h true)

;;; =================== KEYBOARD MAPPINGS ======================

;; Make neovim differentiate <Tab> and <C-i>
(map :n "<C-i>" "<C-i>")
(map :n "<Tab>" "<NOP>")

(map :n "<Esc>" #(vim.cmd :nohlsearch)) ; Stop searching
(map :n "U" "<C-r>") ; Undo

;;; ==================== USER COMMANDS ======================
; (local usercmd vim.api.nvim_create_user_command)

;;; ==================== AUTOCOMMANDS ====================

;; Always exit snippet editing mode when leaving insert mode
(autocmd :User {:pattern :MiniSnippetsSessionStart}
         #(autocmd :ModeChanged {:pattern "*:n" :once true}
                   #(while (_G.MiniSnippets.session.get) (_G.MiniSnippets.session.stop))))

;; Make LSP aware of file renaming
(autocmd :User {:pattern :OilActionsPost}
         #(let [actions $1.data.actions
                on-rename _G.Snacks.rename.on_rename_file]
            (if (= actions.type "move") (on-rename actions.src_url actions.dest_url))))

;; Indentation for fennel
(autocmd :FileType {:pattern "fennel"}
         #(do (set vim.opt.lisp true)
              (vim.opt.lispwords:append [:fn :each :match :icollect :collect :for :while])
              (vim.opt.lispwords:remove [:if :do :when])))

;; Disable autocomment when opening line
(autocmd :FileType {} #(vim.opt.formatoptions:remove :o))

;; Open a file from its last left off position
(autocmd :BufReadPost {}
         #(when (and (not (: (vim.fn.expand "%:p") :match ".git"))
                     (let [mark-line (vim.fn.line "'\"")]
                       (and (> mark-line 1) (<= mark-line (vim.fn.line "$")))))
            (vim.cmd "normal! g'\"")
            (vim.cmd "normal zz")))
