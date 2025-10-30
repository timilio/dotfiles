;;; =============== QUICK CONFIG =================
(local lsp-servers [:bashls :clangd :fennel_ls :gdscript :glsl_analyzer
                    :jedi_language_server :neocmake :nil_ls :quick_lint_js
                    :r_language_server :ruff :rust_analyzer :slangd :taplo
                    :tinymist :zls])
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

       {1 "echasnovski/mini.nvim" :priority 500
        :config #(let [basics (require "mini.basics")]
                   (basics.setup {:mappings {:basic false :option_toggle_prefix "<Leader>t"}}))}

       ;; New/Better Motions and Operators
       {1 "tpope/vim-surround" :dependencies ["tpope/vim-repeat"]}
       {1 "ggandor/leap.nvim" :dependencies ["tpope/vim-repeat"]}
       {1 "ggandor/flit.nvim" :dependencies ["ggandor/leap.nvim"] :opts {}}
       {1 "dhruvasagar/vim-table-mode" :keys [["<Leader>tm" #(vim.cmd :TableModeToggle)]]}

       ;; GUI
       {1 "j-hui/fidget.nvim" :event :LspProgress :opts {}} ; Show LSP loading
       {1 "folke/snacks.nvim" :priority 1000
        :opts {:bigfile {:enabled true} :input {:enabled true}}}
       {1 "jbyuki/nabla.nvim" :keys [["<Leader>p" #(let [m (require "nabla")] (m.popup))]]}

       ;; Navigation
       {1 "ibhagwan/fzf-lua" :event :VeryLazy
        :opts #(let [fzf (require "fzf-lua")] (fzf.register_ui_select)
                 {1 :fzf-native :files {:formatter "path.filename_first"}
                  :previewers {:bat {:args "--color always"}
                               :codeaction_native {:pager "delta --width=$COLUMNS --hunk-header-style=omit --file-style=omit"}}})
        :keys [["<Leader>c" #(vim.cmd "FzfLua builtin")]
               ["<Leader>h" #(vim.cmd "FzfLua helptags")]
               ["<Leader>g" #(vim.cmd "FzfLua grep_project")]
               ; ["<Leader>e" #(vim.cmd "FzfLua files winopts.preview.delay=250")]]}
               ["<Leader>e" #(_G.FzfLua.files {:cmd (.. "fd " _G.FzfLua.config.defaults.files.fd_opts
                                                        (if (= "." (vim.fn.fnamemodify (vim.fn.expand "%") ":h:.:S"))
                                                            ""
                                                            (.. " | proximity-sort " (vim.fn.shellescape (vim.fn.expand "%")))))
                                               :fzf_opts {"--scheme" "path" "--tiebreak" "index"}})]]}
       {1 "stevearc/oil.nvim" :lazy false :opts {} :keys [["-" #(vim.cmd :Oil)]]}

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
       {1 "saghen/blink.cmp" :build "cargo build --release" :event :InsertEnter
        :opts {:keymap {:preset :enter
                        :<Tab> ["select_next" "fallback"]
                        :<S-Tab> ["select_prev" "fallback"]}
               :completion {:list {:selection {:preselect false}}
                            :documentation {:auto_show true :auto_show_delay_ms 50}}
               :cmdline {:enabled false}
               :signature {:enabled true}
               :snippets {:preset :mini_snippets}
               :sources {:per_filetype {:org-roam-select {}
                                        :tex {1 "omni" :inherit_defaults true}}
                         :min_keyword_length 2}}}

       ;; Syntax and Highlighting
       {1 "nvim-treesitter/nvim-treesitter" :branch :main :build ":TSUpdate"
        :init #(autocmd :FileType {} #(let [ft $1.match buf $1.buf
                                            bo (. vim.bo buf)
                                            ts (require "nvim-treesitter")
                                            [lang] (if (vim.list_contains (ts.get_available) ft)
                                                     [ft]
                                                     (icollect [name parser (pairs (require "nvim-treesitter.parsers"))]
                                                        (when (= parser.filetype ft)
                                                          name)))]
                                        (when (and lang
                                                   (not (vim.list_contains ["latex" "org"] lang)))
                                          (: (ts.install lang) :await
                                             #(when (vim.api.nvim_buf_is_valid buf)
                                                (set bo.indentexpr "v:lua.require'nvim-treesitter'.indentexpr()")
                                                (vim.treesitter.start buf lang))))))}
       {1 "hiphish/rainbow-delimiters.nvim" :submodules false
        :config #(let [rainbow (require "rainbow-delimiters.setup")]
                   (rainbow.setup {:whitelist ["fennel"]})) :ft "fennel"}

       ;; Language Specific
       "tidalcycles/vim-tidal"
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
       {1 "nvim-orgmode/orgmode" :ft "org"
        :keys [["<Leader>oa" #(vim.cmd "Org agenda")] ["<Leader>oc" #(vim.cmd "Org capture")]]
        :opts {:org_agenda_files ["~/Documents/org/**/*"]
               :org_default_notes_file "~/Documents/org/refile.org"
               :org_capture_templates {:t {:description "Task" :template "* TODO %?\n  %u"}
                                       :r {:description "Weekly Review" :template "* %u\n  %?"
                                           :target "~/Documents/org/weekly.org"}
                                       :i {:description "Idea" :template "* %? :idea:\n  %u"}}}}
       {1 "chipsenkbeil/org-roam.nvim" :dependencies ["nvim-orgmode/orgmode"]
        :opts {:directory "~/Documents/org"} :keys "<Leader>n"}]}))

;;; ======================= Setup ==========================
(let [m (require "mini.align")] (m.setup {}))
(let [m (require "mini.icons")] (m.setup {}))
(let [m (require "mini.statusline")] (m.setup {}))
(let [m (require "mini.misc")] (m.setup {})
  (m.setup_restore_cursor {:ignore_filetype [:gitcommit :gitrebase :org]}))
(let [m (require "mini.snippets")]
  (m.setup {:snippets [(m.gen_loader.from_lang)]}))

(autocmd :InsertEnter {:once true}
  #(let [m (require "mini.pairs")] (m.setup {:mappings {"'" false}})))

;;; =======================  LSP  ==========================
(vim.lsp.config :rust_analyzer {:settings {:rust-analyzer {:completion {:postfix {:enable false}}}}})
(vim.lsp.enable lsp-servers)

(local spell-filetypes ["tex" "latex" "markdown" "typst" "org"])
(autocmd :FileType {:pattern spell-filetypes}
  #(map [:n] "<Leader>ts"
        #(let [langs ["en-US" "fr" "ja-JP" "sl-SI" "sv"]
               dict-add (fn [{:arguments {1 {: words}}} {: client_id}]
                          (let [client (vim.lsp.get_client_by_id client_id)]
                            (each [l ws (pairs words)]
                              (vim.list_extend (. client.config.settings.ltex.dictionary l) ws)
                              (client:notify "workspace/didChangeConfiguration" client.config.settings))))
               start-ltex #(vim.ui.select langs {:prompt "LTeX language:"}
                             #(vim.lsp.start {:name "ltex"
                                              :cmd ["ltex-ls-plus"]
                                              :root_dir (vim.fs.root 0 [".git" "main.tex"])
                                              :commands {"_ltex.addToDictionary" dict-add}
                                              :settings {:ltex {:enabled spell-filetypes
                                              :language $1
                                              :dictionary (collect [_ v (pairs langs)] (values v []))
                                              :checkFrequency :save}}}))
               clients (vim.lsp.get_clients {:name "ltex"})]
           (if (vim.tbl_isempty clients)
               (start-ltex)
               (vim.lsp.stop_client clients)))))

;;; ================= GENERAL SETTINGS =====================
(set vim.opt.relativenumber true)
(set vim.opt.swapfile false)
(set vim.opt.scrolloff 4) ; Proximity in number of lines before scrolling
(set vim.opt.textwidth 80)
(autocmd :FileType {:pattern ["rust" "lean"]} #(set vim.opt.textwidth 100))

;; Tabs expand to 4 spaces
(set vim.opt.shiftwidth 4)
(set vim.opt.softtabstop 4)
(set vim.opt.expandtab true)

;; GUI and colorscheme
(set vim.opt.pumheight 10) ; Number of autocomplete suggestions displayed at once
(set vim.opt.list true) ; Show hidden characters as defined below
(set vim.opt.listchars "tab:^ ,nbsp:~,extends:»,precedes:«,trail:-")
(set vim.opt.cursorline false)
(set vim.opt.colorcolumn "+0")
(set vim.opt.wrap true)
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

(map [:n :x :o] "s" "<Plug>(leap)")
(map :n "S" "<Plug>(leap-from-window)")

;; Make neovim differentiate <Tab> and <C-i>
(map :n "<C-i>" "<C-i>")
(map :n "<Tab>" "<NOP>")

(map :i "<C-BS>" "<C-w>") ; Delete previous word

(map :n "<Esc>" #(if (and _G.MiniSnippets (_G.MiniSnippets.session.get))
                     (_G.MiniSnippets.session.stop)
                     (vim.cmd :nohlsearch))) ; Stop searching
(map :n "U" "<C-r>") ; Undo

;;; ==================== USER COMMANDS ======================
; (local usercmd vim.api.nvim_create_user_command)

;;; ==================== AUTOCOMMANDS ====================

;; Make LSP aware of file renaming
(autocmd :User {:pattern :OilActionsPost}
  #(let [actions $1.data.actions
         on-rename _G.Snacks.rename.on_rename_file]
     (when (= actions.type "move")
       (on-rename actions.src_url actions.dest_url))))

;; Proper Fennel indentation
(autocmd :FileType {:pattern "fennel"} #(vim.opt.lispwords:remove [:do :if]))

;; Disable autocomment when opening line
(autocmd :FileType {} #(vim.opt.formatoptions:remove :o))
