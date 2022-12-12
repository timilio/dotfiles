# ---- Variables ----
set -gx XDG_CONFIG_HOME ~/.config
set -gx XDG_CACHE_HOME ~/.cache
set -gx XDG_DATA_HOME ~/.local/share
set -gx XDG_STATE_HOME ~/.local/state
set -gx XDG_BIN_HOME ~/.local/bin

set -gx SHELL (status fish-path)
set -gx EDITOR nvim
set -gx BROWSER firefox

set -gx RUSTUP_HOME $XDG_DATA_HOME/rustup
set -gx CARGO_HOME $XDG_DATA_HOME/cargo
set -gx GHCUP_USE_XDG_DIRS true
set -gx STACK_ROOT $XDG_DATA_HOME/stack
set -gx PYENV_ROOT $XDG_DATA_HOME/pyenv
set -gx RBENV_ROOT $XDG_DATA_HOME/rbenv

set -gx HISTFILE $XDG_STATE_HOME/bash/history
set -gx TEXMFHOME $XDG_DATA_HOME/texmf
set -gx TEXMFVAR $XDG_CACHE_HOME/texlive/texmf-var
set -gx TEXMFCONFIG $XDG_CONFIG_HOME/texlive/texmf-config
set -gx NPM_CONFIG_USERCONFIG $XDG_CONFIG_HOME/npm/npmrc

set -gx BAT_THEME ansi
set -gx ZK_NOTEBOOK_DIR ~/Documents/notes

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
abbr -ag lla exa -la
abbr -ag e nvim
abbr -ag lg lazygit
abbr -ag rss newsboat
abbr -ag notes zk edit --interactive
abbr -ag che chezmoi_edit
abbr -ag chg lazygit --work-tree $XDG_DATA_HOME/chezmoi
abbr -ag chv chezmoi_edit $XDG_CONFIG_HOME/nvim/init.fnl
abbr -ag chf chezmoi_edit $__fish_config_dir/config.fish
abbr -ag cht chezmoi_edit $XDG_CONFIG_HOME/kitty/kitty.conf

set -g CFLAGS -Wall -Werror -Wextra -Wpedantic \
              -Wformat=2 -Wno-unused-parameter -Wshadow \
              -Wwrite-strings -Wstrict-prototypes -Wold-style-definition \
              -Wredundant-decls -Wnested-externs -Wmissing-include-dirs \
              -Wfloat-equal -std=c99 -O2
abbr -ag gcc 'gcc $CFLAGS'

# ---- Plugins ----
fundle plugin 'decors/fish-colored-man' # Colored man pages
fundle plugin 'franciscolourenco/done' # Notify when a long process is done
fundle plugin 'PatrickF1/fzf.fish' # fzf keybindings and stuff

fundle init

# ---- Initialize ----
command -q zoxide; and zoxide init fish | source
command -q pyenv; and pyenv init - | source
command -q rbenv; and rbenv init - | source

# ---- Key bindings ----
fzf_configure_bindings --directory=\ct

fish_vi_key_bindings
set fish_cursor_default block
set fish_cursor_insert line
set fish_cursor_replace_one underscore
set fish_cursor_visual block
set fish_vi_force_cursor
