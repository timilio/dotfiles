;; Setup nvim-cmp
(local cmp (require :cmp))
(local snip (require :snippy))
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

(fn deprio [kind]
  (fn [e1 e2]
    (if (= (e1:get_kind) kind) false
        (= (e2:get_kind) kind) true
        nil)))
(local types (require :cmp.types))

(cmp.setup
  {:preselect cmp.PreselectMode.None ; Please don't preselect!!
   :snippet {:expand (fn [args] (snip.expand_snippet args.body))} ; REQUIRED - you must specify a snippet engine
   :mapping {"<C-j>" (cmp.mapping (fn [fallback]
                                    (if (snip.can_expand_or_advance)
                                        (snip.expand_or_advance)
                                        (fallback))))
             "<Tab>" (cmp.mapping.select_next_item)
             "<S-Tab>" (cmp.mapping.select_prev_item)
             "<C-e>" (cmp.mapping.abort)
             "<C-d>" (cmp.mapping.scroll_docs -4)
             "<C-f>" (cmp.mapping.scroll_docs 4)
             "<CR>" (cmp.mapping.confirm {:select false})} ; Only confirm explicitly selected items
   :sources (cmp.config.sources [{:name :nvim_lsp}
                                 {:name "buffer" :keyword_length 5
                                                 :option {:keyword_pattern :\k\+}} ; Allow chars with diacritics
                                 {:name "path"}
                                 {:name "crates"}
                                 {:name "snippy"}])
   :view {:entries :native}
   :sorting {:comparators [(deprio types.lsp.CompletionItemKind.Text)
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
                                :path "[PATH]"
                                :crates "[CRATE]"
                                :snippy "[SNIP]"} entry.source.name))
                          vim-item)}})
