;; Setup nvim-cmp
(local cmp (require :cmp))
(local snip (require :snippy))
(local symbols {:Boolean ""
                :Character ""
                :Class ""
                :Color ""
                :Constant ""
                :Constructor ""
                :Enum ""
                :EnumMember ""
                :Event "ﳅ"
                :Field ""
                :File ""
                :Folder "ﱮ"
                :Function "ﬦ"
                :Interface ""
                :Keyword ""
                :Method ""
                :Module ""
                :Number ""
                :Operator "Ψ"
                :Parameter ""
                :Property "ﭬ"
                :Reference ""
                :Snippet ""
                :String ""
                :Struct "ﯟ"
                :Text ""
                :TypeParameter ""
                :Unit ""
                :Value ""
                :Variable "ﳛ"})

(cmp.setup
  {:preselect cmp.PreselectMode.None ; Please don't preselect!!
   :snippet {:expand (fn [args] (snip.expand_snippet args.body))} ; REQUIRED - you must specify a snippet engine
   :mapping {"<C-j>" (cmp.mapping (fn [fallback]
                                    (if (snip.expand_or_jumpable)
                                        (snip.expand_or_jump)
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
                                 {:name "pandoc_references"}
                                 {:name "orgmode"}
                                 {:name "fish"}
                                 {:name "crates"}
                                 {:name "snippy"}])
   :sorting {:comparators [(fn [fst snd]
                             (let [lsp_types (. (require :cmp.types) :lsp)
                                   kind1 (. lsp_types.CompletionItemKind (fst:get_kind))
                                   kind2 (. lsp_types.CompletionItemKind (snd:get_kind))]
                               (if (= kind1 :Snippet) false ; Put snippets at the bottom of the completion list
                                   (= kind2 :Snippet) true
                                   nil)))]}
   :formatting {:format (fn [entry vim-item]
                          ;; This concatonates the icons with the name of the item kind
                          (set vim-item.kind (string.format "%s %s" (. symbols vim-item.kind) vim-item.kind))
                          (set vim-item.menu
                            (. {:nvim_lsp "[LSP]"
                                :buffer "[BUF]"
                                :path "[PATH]"
                                :pandoc_references "[REF]"
                                :orgmode "[ORG]"
                                :fish "[FISH]"
                                :crates "[CRATE]"
                                :snippy "[SNIP]"} entry.source.name))
                          vim-item)}})
