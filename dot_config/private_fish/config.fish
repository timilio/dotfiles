fish_vi_key_bindings
set fish_cursor_default block
set fish_cursor_insert line
set fish_cursor_replace_one underscore
set fish_cursor_visual block
set fish_vi_force_cursor

# Path
fish_add_path ~/.cargo/bin
fish_add_path ~/.cabal/bin
fish_add_path ~/.ghcup/bin
fish_add_path ~/.pyenv/bin
fish_add_path ~/.rbenv/bin
fish_add_path /usr/local/smlnj/bin
fish_add_path /usr/local/opt/openjdk/bin

pyenv init - | source
rbenv init - | source

# Abbreviations
abbr -a e nvim
abbr -a ls exa

# Variables
set -gx EDITOR nvim
