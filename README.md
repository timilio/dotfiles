# Setup

To install clone this repository, install nix with home manager and run
`home-manager switch --flake . --extra-experimental-features nix-command
--extra-experimental-features flakes`.

Remember to commit changes to git before running `home-manager switch --flake .`.

## Useful packages

`fish neovim kitty nix rustup firefox ripgrep fd-find fzf eza bat tealdeer
newsboat lazygit 1password yt-dlp zk mpv anki discord zotero zoom spotify gimp
valgrind obsidian thunderbird foliate cozy typst rtx opensnitch`

## Zotero

Set the Zotero data directory to $XDG_DATA_DIR/zotero and install this
extension: [Better BibTeX](https://github.com/retorquere/zotero-better-bibtex).
Also enable urls in Better BibTeX.
