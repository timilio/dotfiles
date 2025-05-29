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
(local autocmd vim.api.nvim_create_autocmd)
(local map vim.keymap.set)

(local on-attach
  (fn [_ bufnr]
    (let [opts {:silent true :buffer bufnr}
          bo (. vim.bo bufnr)]
      (map :n "gD" vim.lsp.buf.definition opts)
      (map :n "gd" vim.lsp.buf.definition opts)
      (map :n "gy" vim.lsp.buf.type_definition opts)
      (map :n "gi" vim.lsp.buf.implementation opts)
      (map :n "gr" vim.lsp.buf.references opts)
      (map [:n :v] "<Leader>a" vim.lsp.buf.code_action opts)
      (map :n "<Leader>r" vim.lsp.buf.rename opts)
      (set bo.omnifunc "v:lua.MiniCompletion.completefunc_lsp")
      (set vim.wo.signcolumn :yes))))
(autocmd :LspAttach {:callback #(on-attach (vim.lsp.get_client_by_id $1.data.client_id) $1.buf)})

;;; ================= PLUGINS ====================
(let [plugins (require :lazy)]
  (plugins.setup
    {:lockfile (vim.fn.expand "$HOME/.dotfiles/lazy-lock.json")
     :rocks {:enabled false} :change_detection {:enabled false}
     :spec [
       "sainnhe/everforest" ; everforest
       ; {1 "zenbones-theme/zenbones.nvim" :dependencies ["rktjmp/lush.nvim"]}
       ; "https://gitlab.com/protesilaos/tempus-themes-vim.git"
       ; "ellisonleao/gruvbox.nvim" ; gruvbox

       ;; New/Better Motions and Operators
       {1 "tpope/vim-surround" :dependencies ["tpope/vim-repeat"]}
       {1 "ggandor/leap.nvim" :dependencies ["tpope/vim-repeat"]
        :config #(let [leap (require :leap)] (leap.set_default_mappings))}
       {1 "ggandor/flit.nvim" :dependencies ["ggandor/leap.nvim"] :opts {}}
       {1 "echasnovski/mini.align" :keys ["ga" "gA"] :opts {}}
       {1 "echasnovski/mini.comment" :opts {}}
       {1 "echasnovski/mini.pairs" :event :InsertEnter :opts {}}
       {1 "dhruvasagar/vim-table-mode" :keys [["<Leader>tm" #(vim.cmd :TableModeToggle)]]}

       ;; GUI
       {1 "folke/snacks.nvim" :priority 1000
        :opts {:bigfile {:enabled true} :input {:enabled true}
               :styles {:input {:keys {:i_esc {2 ["cmp_close" "<Esc>"]}}}}}} ; https://github.com/folke/snacks.nvim/issues/1841
       {1 "echasnovski/mini.icons" :opts {}}
       {1 "echasnovski/mini.statusline" :opts {}}
       ; {1 "echasnovski/mini.pick" :keys [["<Leader>h" #(vim.cmd "Pick help")]
       ;                                   ["<Leader>e" #(vim.cmd "Pick files")]
       ;                                   ["<Leader>g" #(vim.cmd "Pick grep_live")]]
       ;  :opts #(let [pick (require :mini.pick)]
       ;           (set vim.ui.select pick.ui_select) {})}

       ;; Navigation
       {1 "ibhagwan/fzf-lua" :event :VeryLazy
        :opts #(let [fzf (require :fzf-lua)] (fzf.register_ui_select)
                 {1 :fzf-native :previewers {:bat {:args "--color always"}}
                  :defaults {:path_shorten true}})
        :keys [["<Leader>c" #(vim.cmd "FzfLua builtin")]
               ["<Leader>h" #(vim.cmd "FzfLua helptags")]
               ["<Leader>g" #(vim.cmd "FzfLua grep_project")]
               ["<Leader>e" #(vim.cmd "FzfLua files winopts.preview.delay=250")]]}
       {1 "stevearc/oil.nvim" :opts #(do (map :n "-" #(vim.cmd :Oil)) {})}

       ;; Linting and Formatting (LSPs)
       {1 "neovim/nvim-lspconfig"
        :config #(let [req (require :lspconfig)]
                   (each [_ server (pairs lsp-servers)]
                     (let [lsp (. req server)]
                       (lsp.setup {:settings {:rust_analyzer {:completion {:postfix {:enable false}}}
                                              :fennel-ls {:extra-globals "vim"}}}))))}
       {1 "stevearc/conform.nvim" :event :BufWritePre :cmd :ConformInfo
        :opts {:formatters_by_ft {:nix [:alejandra]
                                  :cmake [:gersemi]}
               :format_after_save {:lsp_format :fallback}}}
       {1 "j-hui/fidget.nvim" :event :LspProgress :opts {}} ; Show LSP loading

       ;; Debugging
       {1 "mfussenegger/nvim-dap" :dependencies ["nvim-neotest/nvim-nio" "rcarriga/nvim-dap-ui"]
        :config #(let [dap (require :dap)
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

       {1 "rcarriga/nvim-dap-ui" :lazy true :dependencies ["mfussenegger/nvim-dap"]
        :keys [["<Leader>dt" #(let [dapui (require :dapui)] (dapui.toggle))]]
        :config #(let [dapui (require :dapui)]
                   (dapui.setup {:layouts [{:elements [{:id "breakpoints" :size 0.10}
                                                       {:id "stacks" :size 0.25}
                                                       {:id "watches" :size 0.25}
                                                       {:id "scopes" :size 0.40}]
                                            :size 40
                                            :position "left"}
                                           {:elements [{:id "repl" :size 0.55}
                                                       {:id "console" :size 0.45}]
                                            :size 10
                                            :position "bottom"}]}))}

       ;; Autocompletion
       {1 "echasnovski/mini.completion"
        :opts #(let [imap #(map :i $1 $2 {:expr true})]
                 (imap "<Tab>"   #(if (not= (vim.fn.pumvisible) 0) "<C-n>" "<Tab>"))
                 (imap "<S-Tab>" #(if (not= (vim.fn.pumvisible) 0) "<C-p>" "<S-Tab>"))
                 (imap "<CR>" #(if (not= (. (vim.fn.complete_info) "selected") -1) "<C-y>" (_G.MiniPairs.cr)))
                 {:source_func :omnifunc :auto_setup false
                  :fallback_action #(if (= vim.opt.filetype._value :tex)
                                        (vim.api.nvim_feedkeys (vim.keycode "<C-x><C-o>") :m false))})}
       {1 "echasnovski/mini.snippets"
        :opts #(let [mini-snippets (require :mini.snippets)]
                 {:snippets [(mini-snippets.gen_loader.from_lang)]})}

       ; {1 "hrsh7th/nvim-cmp" :event :InsertEnter :main :cmp
       ;  :opts #(let [cmp (require :cmp)]
       ;           {:snippet {:expand (fn [args] (_G.MiniSnippets.config.expand.insert args))}
       ;            :preselect cmp.PreselectMode.None
       ;            :mapping (cmp.mapping.preset.insert {
       ;                      "<Tab>" (cmp.mapping.select_next_item {:behavior cmp.SelectBehavior.Select})
       ;                      "<S-Tab>" (cmp.mapping.select_prev_item {:behavior cmp.SelectBehavior.Select})
       ;                      "<C-u>" (cmp.mapping.scroll_docs -4)
       ;                      "<C-d>" (cmp.mapping.scroll_docs 4)
       ;                      ; Only confirm explicitly selected items
       ;                      "<CR>" (cmp.mapping.confirm {:select false})})
       ;            :completion {:keyword_length 2}
       ;            :view {:entries :native} ; Native completion menu
       ;            :sources (cmp.config.sources [{:name :nvim_lsp}
       ;                                          {:name :mini_snippets}
       ;                                          {:name :vimtex}
       ;                                          {:name :buffer :keyword_length 4}])})
       ;  :dependencies ["abeldekat/cmp-mini-snippets"
       ;                 "hrsh7th/cmp-buffer"
       ;                 "micangl/cmp-vimtex"
       ;                 "hrsh7th/cmp-nvim-lsp"]}
       ; {1 "ray-x/lsp_signature.nvim" :opts {}}

       ;; Syntax and Highlighting
       {1 "nvim-treesitter/nvim-treesitter" :build ":TSUpdate"
        :config #(let [ts (require :nvim-treesitter.configs)]
                   (ts.setup {:highlight {:enable true}
                              :indent {:enable true}
                              :ignore_install [:latex :org]
                              :auto_install true}))}
       {1 "hiphish/rainbow-delimiters.nvim" :submodules false
        :config #(let [rainbow (require :rainbow-delimiters.setup)]
                   (rainbow.setup {:whitelist [:fennel]})) :ft :fennel}

       ;; Language Specific
       {1 "lervag/vimtex" :ft :tex
        :keys [["<LocalLeader>ls" "<plug>(vimtex-compile-ss)"]]
        :init #(do (set vim.g.vimtex_quickfix_ignore_filters
                     ["Draft mode on."
                      "\\\\AtBeginDocument{\\\\RenewCommandCopy\\\\qty\\\\SI}"])
                   (set vim.g.vimtex_doc_handlers ["vimtex#doc#handlers#texdoc"]))}
       {1 "kaarmu/typst.vim" :ft :typst}
       {1 "julian/lean.nvim" :ft :lean :opts {:mappings true}
        :dependencies ["neovim/nvim-lspconfig" "nvim-lua/plenary.nvim"]}
       {1 "saecki/crates.nvim" :event "BufRead Cargo.toml" :tag :stable
        :opts {:lsp {:enabled true :actions true :completion true :hover true}}}
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
               jdtls-start #(do (set java-config.on_attach on-attach)
                                (jdtls.start_or_attach java-config)
                                false)] ; autocmd gets removed otherwise
           (vim.api.nvim_create_autocmd :FileType {:pattern :java :callback jdtls-start})
           (jdtls-start))}

       ;; Org Mode
       {1 "nvim-orgmode/orgmode" :event :VeryLazy :ft :org
        :opts {:org_agenda_files ["~/Documents/org/**/*"]
               :org_default_notes_file "~/Documents/org/refile.org"
               :org_capture_templates {:t {:description "Task"
                                           :template "* TODO %?\n  %u"}
                                       :i {:description "Idea"
                                           :template "* %? :idea:\n  %u"}}}}
       {1 "chipsenkbeil/org-roam.nvim" :dependencies ["nvim-orgmode/orgmode"]
        :opts {:directory "~/Documents/org"} :keys "<Leader>n"}]}))

;;; ================= GENERAL SETTINGS =====================
(local opt vim.opt)

(set opt.number true)
(set opt.relativenumber true)
(set opt.undofile true) ; Permanent undo history
(set opt.swapfile false)
(set opt.scrolloff 4) ; Proximity in number of lines before scrolling
(set opt.listchars "tab:^ ,nbsp:¬,extends:»,precedes:«,trail:•")

;; Completions
(set opt.pumheight 10) ; Number of autocomplete suggestions displayed at once

;; Tabs expand to 4 spaces
(set opt.shiftwidth 4)
(set opt.softtabstop 4)
(set opt.expandtab true)

;; Better searching
(set opt.ignorecase true)
(set opt.smartcase true)

;; GUI and colorscheme
(set opt.colorcolumn :80)
(autocmd :FileType {:pattern :rust :callback #(set opt.colorcolumn :100)})
(set opt.showcmd false) ; Don't show me what keys I'm pressing
(set opt.showmode false) ; Statusline already shows this
(set opt.background background)
(vim.cmd.colorscheme colorscheme)

(vim.diagnostic.config {:jump {:on_jump vim.diagnostic.open_float} ; Show diagnostic on jump (e.g. ]d)
                        :signs {:text {vim.diagnostic.severity.ERROR "󰅚 "
                                       vim.diagnostic.severity.WARN "󰀪 "
                                       vim.diagnostic.severity.INFO "󰋽 "
                                       vim.diagnostic.severity.HINT "󰌶 "}}})

;;; =================== KEYBOARD MAPPINGS ======================

;; Make neovim differentiate <Tab> and <C-i>
(map :n "<C-i>" "<C-i>")
(map :n "<Tab>" "<NOP>")

;; Center search results
(map :n "n" "nzz" {:silent true})
(map :n "N" "Nzz" {:silent true})
(map :n "*" "*zz" {:silent true})
(map :n "#" "#zz" {:silent true})
(map :n "g*" "g*zz" {:silent true})

(map :n "<Leader>," #(vim.cmd "set invlist")) ; Toggle hidden characters
(map :n "<Esc>" #(vim.cmd :nohlsearch)) ; Stop searching
(map :n "U" "<C-r>") ; Undo

;; Disable arrow keys
(map [:n :i] "<Up>" "<nop>")
(map [:n :i] "<Down>" "<nop>")
(map [:n :i] "<Left>" "<nop>")
(map [:n :i] "<Right>" "<nop>")

;;; ==================== USER COMMANDS ======================
; (local usercmd vim.api.nvim_create_user_command)

;;; ==================== FILETYPES =======================
(set vim.g.c_syntax_for_h true)

;; Make LSP aware of file renaming
(autocmd :User {:pattern :OilActionsPost
                :callback #(let [a $1.data.actions on-rename _G.Snacks.rename.on_rename_file]
                             (if (= a.type "move") (on-rename a.src_url a.dest_url)))})

;; Indentation for fennel
(autocmd :FileType
         {:pattern :fennel
          :callback #(do (set opt.lisp true)
                         (opt.lispwords:append [:fn :each :match :icollect :collect :for :while])
                         (opt.lispwords:remove [:if :do]))})

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
