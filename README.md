# Setup

My dotfiles managed with [chezmoi](https://www.chezmoi.io)

Install chezmoi and run `chezmoi init git@github.com:timilio/dotfiles.git` and
`chezmoi apply`.

## Useful packages

`fish neovim kitty nix rustup firefox ripgrep fd-find fzf eza bat tealdeer
newsboat pandoc lazygit 1password pyenv rbenv yt-dlp zk mpv anki discord zotero
zoom spotify gimp valgrind obsidian thunderbird foliate cozy typst`

## Notes

I use [zk](https://github.com/mickael-menu/zk) for notes. Make sure it is
installed because neovim is going to set it up as an lsp-server.

## Zotero

Set the Zotero data directory to $XDG_DATA_DIR/zotero and install this
extension: [Better BibTeX](https://github.com/retorquere/zotero-better-bibtex).
Also enable urls in Better BibTeX.
