# ---- Variables ----
set -gx XDG_CONFIG_HOME ~/.config
set -gx XDG_DATA_HOME ~/.local/share

set -gx SHELL /usr/local/bin/fish
set -gx EDITOR nvim
set -gx BROWSER firefox

if test (uname) = Darwin
    set -gx BROWSER open -a firefox
end

set -gx CARGO_HOME $XDG_DATA_HOME/cargo
set -gx RUSTUP_HOME $XDG_DATA_HOME/rustup
set -gx PYENV_ROOT $XDG_DATA_HOME/pyenv
set -gx RBENV_ROOT $XDG_DATA_HOME/rbenv

# ---- Path ----
fish_add_path $CARGO_HOME/bin
fish_add_path $PYENV_ROOT/bin
fish_add_path $RBENV_ROOT/bin

# ---- Abbreviations ----
abbr -ag e nvim
abbr -ag ls exa
abbr -ag ll exa -l
abbr -ag la exa -a
abbr -ag cat bat
abbr -ag che chezmoi edit --apply
abbr -ag chv chezmoi edit --apply $XDG_CONFIG_HOME/nvim/init.lua
abbr -ag chf "chezmoi edit --apply $XDG_CONFIG_HOME/fish/config.fish; and source $XDG_CONFIG_HOME/fish/config.fish"
abbr -ag rss newsboat -r

# ---- Initialize ----
command -q rustup; or curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
command -q pyenv; and pyenv init - | source
command -q rbenv; and rbenv init - | source

[ -f /usr/local/share/autojump/autojump.fish ]; and source /usr/local/share/autojump/autojump.fish

fish_vi_key_bindings
set fish_cursor_default block
set fish_cursor_insert line
set fish_cursor_replace_one underscore
set fish_cursor_visual block
set fish_vi_force_cursor
