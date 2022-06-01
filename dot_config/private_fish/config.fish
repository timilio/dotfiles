# ---- Variables ----
set -gx XDG_CONFIG_HOME ~/.config
set -gx XDG_DATA_HOME ~/.local/share
set -gx XDG_BIN_HOME ~/.local/bin

set -gx SHELL (status fish-path)
set -gx EDITOR nvim
set -gx BROWSER firefox

if test (uname) = Darwin
    set -gx BROWSER open -a $BROWSER
end

set -gx RUSTUP_HOME $XDG_DATA_HOME/rustup
set -gx CARGO_HOME $XDG_DATA_HOME/cargo
set -gx GHCUP_USE_XDG_DIRS true
set -gx STACK_ROOT $XDG_DATA_HOME/stack
set -gx PYENV_ROOT $XDG_DATA_HOME/pyenv
set -gx RBENV_ROOT $XDG_DATA_HOME/rbenv

# ---- Path ----
fish_add_path $XDG_BIN_HOME
fish_add_path $CARGO_HOME/bin
fish_add_path $PYENV_ROOT/bin
fish_add_path $RBENV_ROOT/bin

# ---- Abbreviations ----
abbr -ag mv mv -vi
abbr -ag ls exa
abbr -ag ll exa -l
abbr -ag la exa -a
abbr -ag cat bat
abbr -ag e nvim
abbr -ag rss newsboat -r
abbr -ag che chezmoi edit --apply
abbr -ag chv chezmoi edit --apply $XDG_CONFIG_HOME/nvim/init.lua
abbr -ag chf "chezmoi edit --apply $XDG_CONFIG_HOME/fish/config.fish; and source $XDG_CONFIG_HOME/fish/config.fish"
abbr -ag cht chezmoi edit --apply $XDG_CONFIG_HOME/kitty/kitty.conf
abbr -ag churls chezmoi edit --apply $XDG_CONFIG_HOME/newsboat/urls

# ---- Plugins ----
fundle plugin 'jethrokuan/z' # Autojump
fundle plugin 'PatrickF1/fzf.fish' # fzf keybindings and stuff
fundle plugin 'PatrickF1/colored_man_pages.fish' # Colored man pages
fundle plugin 'laughedelic/fish_logo' # 'fish_logo' ASCII-art
fundle plugin 'franciscolourenco/done' # Notify when a long process is done
fundle init

# ---- Initialize ----
command -q pyenv; and pyenv init - | source
command -q rbenv; and rbenv init - | source

fish_vi_key_bindings
set fish_cursor_default block
set fish_cursor_insert line
set fish_cursor_replace_one underscore
set fish_cursor_visual block
set fish_vi_force_cursor
