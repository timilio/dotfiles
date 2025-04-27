;; Setup nvim-cmp
(local cmp (require :cmp))
(local snip (require :luasnip))
(local symbols {:Boolean ""
                :Character ""
                :Class ""
                :Color ""
                :Constant ""
                :Constructor ""
                :Enum ""
                :EnumMember ""
                :Event ""
                :Field "󰄷"
                :File ""
                :Folder ""
                :Function "󰡱"
                :Interface ""
                :Keyword ""
                :Method ""
                :Module "󰅩"
                :Number "󰎾"
                :Operator "Ψ"
                :Parameter ""
                :Property "󰙭"
                :Reference ""
                :Snippet ""
                :String ""
                :Struct "󰛡"
                :Text "󰦨"
                :TypeParameter "󰊄"
                :Unit ""
                :Value "󰎠"
                :Variable ""})
(local types (require :cmp.types))
(local map vim.keymap.set)
(fn deprio [kind]
  (fn [e1 e2]
    (if (= (e1:get_kind) kind) false
        (= (e2:get_kind) kind) true
        nil)))

(map [:i :s] "<C-k>" #(snip.expand_or_jump) {:silent true})
(map [:i :s] "<C-j>" #(snip.jump -1) {:silent true})
(map :s "<BS>" "<C-o>c" {:silent true})
(let [snip-loader (require :luasnip.loaders.from_snipmate)]
  (snip-loader.lazy_load))

(cmp.setup
  {:preselect cmp.PreselectMode.None ; Please don't preselect!!
   :snippet {:expand (fn [args] (snip.lsp_expand args.body))} ; REQUIRED - you must specify a snippet engine
   :mapping {"<Tab>" (cmp.mapping.select_next_item {:behavior cmp.SelectBehavior.Select})
             "<S-Tab>" (cmp.mapping.select_prev_item {:behavior cmp.SelectBehavior.Select})
             "<C-u>" (cmp.mapping.scroll_docs -4)
             "<C-d>" (cmp.mapping.scroll_docs 4)
             "<CR>" (cmp.mapping.confirm {:select false})} ; Only confirm explicitly selected items
   :completion {:keyword_length 2}
   :view {:entries :native} ; Native completion menu
   :sources (cmp.config.sources [{:name :nvim_lsp}
                                 {:name :luasnip}
                                 {:name :vimtex}
                                 {:name :orgmode}
                                 ; {:name "path"}
                                 {:name :crates}]
                                [{:name :buffer :keyword_length 4
                                                :option {:keyword_pattern :\k\+}}]) ; Allow chars with diacritics
   :sorting {:comparators [(deprio types.lsp.CompletionItemKind.Text)
                           (deprio types.lsp.CompletionItemKind.Snippet)
                           (deprio types.lsp.CompletionItemKind.Keyword)
                           cmp.config.compare.offset
                           cmp.config.compare.locality
                           cmp.config.compare.exact
                           cmp.config.compare.score
                           (let [comp (require "cmp-under-comparator")]
                             comp.under)
                           cmp.config.compare.kind
                           cmp.config.compare.sort_text
                           cmp.config.compare.length
                           cmp.config.compare.order]}
   :formatting {:format (fn [entry vim-item]
                          ;; This concatenates the icons with the name of the item kind
                          (set vim-item.kind (string.format "%s %s" (. symbols vim-item.kind) vim-item.kind))
                          (set vim-item.menu
                            (. {:nvim_lsp "[LSP]"
                                :buffer "[BUF]"
                                :crates "[CRATE]"
                                :vimtex (.. "[TEX]" (or vim-item.menu ""))
                                :orgmode "[ORG]"
                                :ctags "[TAG]"
                                :path "[PATH]"
                                :snippy "[SNIP]"} entry.source.name))
                          vim-item)}})

(cmp.setup.filetype [:c :cpp]
                    {:sources [{:name :nvim_lsp}
                               {:name :luasnip}]})

; -- Enable `buffer` and `buffer-lines` for `/` and `?` in the command-line
; require "cmp".setup.cmdline({ "/", "?" }, {
;     mapping = require "cmp".mapping.preset.cmdline(),
;     sources = {
;         {
;             name = "buffer",
;             option = { keyword_pattern = [[\k\+]] }
;         },
;     }
; })
