-- Setup nvim-cmp
local cmp = require('cmp')
local luasnip = require('luasnip')
local symbol_map = {
    Boolean = '',
    Character = '',
    Class = '',
    Color = '',
    Constant = '',
    Constructor = '',
    Enum = '',
    EnumMember = '',
    Event = 'ﳅ',
    Field = '',
    File = '',
    Folder = 'ﱮ',
    Function = 'ﬦ',
    Interface = '',
    Keyword = '',
    Method = '',
    Module = '',
    Number = '',
    Operator = 'Ψ',
    Parameter = '',
    Property = 'ﭬ',
    Reference = '',
    Snippet = '',
    String = '',
    Struct = 'ﯟ',
    Text = '',
    TypeParameter = '',
    Unit = '',
    Value = '',
    Variable = 'ﳛ',
}

cmp.setup({
    preselect = cmp.PreselectMode.None, -- Please don't preselect!!
    snippet = {
        -- REQUIRED - you must specify a snippet engine
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },
    mapping = {
        ['<C-j>'] = cmp.mapping(function(fallback)
            if luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end),
        ['<Tab>'] = cmp.mapping.select_next_item(),
        ['<S-Tab>'] = cmp.mapping.select_prev_item(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = false }), -- Only confirm explicitly selected items
    },
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'buffer', keyword_length = 5 },
        { name = 'path' },
        { name = 'emoji' },
        { name = 'pandoc_references' },
        { name = 'latex_symbols' },
        { name = 'fish' },
        { name = 'crates' },
        { name = 'luasnip' },
    }),
    formatting = {
        format = function(entry, vim_item)
            -- This concatonates the icons with the name of the item kind
            vim_item.kind = string.format('%s %s', symbol_map[vim_item.kind], vim_item.kind)
            vim_item.menu = ({
                nvim_lsp = '[LSP]',
                buffer = '[BUF]',
                path = '[PATH]',
                emoji = '[EMOJI]',
                pandoc_references = '[REF]',
                latex_symbols = '[TeX]',
                fish = '[FISH]',
                crates = '[CRATE]',
                luasnip = '[SNIP]',
            })[entry.source.name]
            return vim_item
        end,
    },
})
