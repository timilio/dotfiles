# Setup

Install nix. If using a [pre-built rpm](https://github.com/nix-community/nix-installers), you might have to run
```sh
nix-channel --add https://nixos.org/channels/nixpkgs-unstable
nix-channel --update
groupadd -r nixbld
for n in $(seq 1 10); do
    useradd -c "Nix build user $n" \
    -d /var/empty -g nixbld -G nixbld -M -N -r -s "$(which nologin)" \
    nixbld$n
done
```
Then run `just install`.

Remember to commit changes to git before running `just`.

## Useful packages

`ripgrep fd-find fzf eza bat tealdeer yt-dlp zk mpv anki valgrind foliate cozy
opensnitch`

## Zotero

Set the Zotero data directory to $XDG_DATA_DIR/zotero and install this
extension: [Better BibTeX](https://github.com/retorquere/zotero-better-bibtex).
Also enable urls in Better BibTeX.
