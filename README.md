# Setup

My dotfiles managed with [chezmoi](https://www.chezmoi.io)

Install chezmoi and run `chezmoi init https://github.com/timilio/dotfiles.git`
and `chezmoi apply`. This will install rustup, ghcup, fish with plugins, and
neovim with plugins.

(Actually for me `chezmoi init git@github.com:timilio/dotfiles.git` to use SSH)

Useful packages:

`firefox ripgrep fd-find fzf exa bat tealdeer newsboat pandoc lazygit 1password
pyenv rbenv yt-dlp zk`

Useful apps:

`anki discord zotero zoom spotify`

## Fish

Install your terminal emulator of choice (e.g.
[kitty](https://sw.kovidgoyal.net/kitty/)) and change your shell to fish.

## Neovim

I use [zk](https://github.com/mickael-menu/zk) for notes. Make sure it is installed
because neovim is going to set it up as an lsp-server.

## Writing papers in markdown

Install `pandoc` and a $\LaTeX$ distribution and finally install my fish plugin
[fish-pdf](https://github.com/timilio/fish-pdf).

## Zotero

Set the Zotero data directory to $XDG_DATA_DIR/zotero and install this
extension: [Better BibTeX](https://github.com/retorquere/zotero-better-bibtex).
Also enable urls in Better BibTeX.
