# Setup

My dotfiles managed with [chezmoi](https://www.chezmoi.io)

Install chezmoi and run `chezmoi init https://github.com/timilio/dotfiles.git`
and `chezmoi apply`.

(Actually for me `chezmoi init git@github.com:timilio/dotfiles.git` to use SSH)

Essential packages:

`fish neovim`

Useful packages:

`firefox ripgrep fd-find fzf exa bat tealdeer autojump newsboat pandoc`

Useful apps:

`obsidian anki discord zotero`

## Fish

Install your terminal emulator of choice (e.g.
[WezTerm](https://wezfurlong.org/wezterm/)) and change your shell to fish.

## Neovim

My neovim setup aims to be easy to understand and configure and is completely
written in Lua.

## Writing papers in markdown

Install `pandoc` and a $\latex$ distribution.

Use my function `pdf <markdown file>` to generate a nice looking pdf (using
pandoc).

You can include latex packages with --usepackage, include a bib file
for citations with --bibliography (citing is very easy in markdown, just
`@<citation>`) and render borders around images with --bordered-images.
