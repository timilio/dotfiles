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
set -gx NPM_CONFIG_USERCONFIG $XDG_CONFIG_HOME/npm/npmrc
set -gx GHCUP_USE_XDG_DIRS true
set -gx STACK_ROOT $XDG_DATA_HOME/stack

set -gx HISTFILE $XDG_STATE_HOME/bash/history
set -gx TEXMFHOME $XDG_DATA_HOME/texmf
set -gx TEXMFVAR $XDG_CACHE_HOME/texlive/texmf-var
set -gx TEXMFCONFIG $XDG_CONFIG_HOME/texlive/texmf-config
set -gx JUPYTER_CONFIG_DIR $XDG_CONFIG_HOME/jupyter

set -gx BAT_THEME ansi
set -gx ZK_NOTEBOOK_DIR ~/Documents/notes

# ---- Path ----
fish_add_path $XDG_BIN_HOME
fish_add_path $CARGO_HOME/bin

# ---- Abbreviations ----
abbr -ag mv mv -vi
abbr -ag ls eza
abbr -ag ll eza -l
abbr -ag la eza -a
abbr -ag lla eza -la

abbr -ag e nvim
abbr -ag lg lazygit
abbr -ag rss newsboat
abbr -ag notes zk edit --interactive

abbr -ag che chezmoi_edit
abbr -ag chg lazygit --work-tree $XDG_DATA_HOME/chezmoi
abbr -ag chv chezmoi_edit $XDG_CONFIG_HOME/nvim/init.fnl
abbr -ag chf chezmoi_edit $__fish_config_dir/config.fish
abbr -ag cht chezmoi_edit $XDG_CONFIG_HOME/kitty/kitty.conf

abbr -ag gcc 'gcc $CFLAGS'
set -g CFLAGS -Wall -Werror -Wextra -Wpedantic \
              -Wformat=2 -Wno-unused-parameter -Wshadow \
              -Wwrite-strings -Wstrict-prototypes -Wold-style-definition \
              -Wredundant-decls -Wnested-externs -Wmissing-include-dirs \
              -Wfloat-equal -std=c99

# ---- Plugins ----
fundle plugin 'decors/fish-colored-man' # Colored man pages
set -g man_standout -b yellow black

fundle plugin 'PatrickF1/fzf.fish' # fzf keybindings and stuff
fundle plugin "sentriz/fish-pipenv"
fundle plugin "ryoppippi/fish-poetry"
fundle init

# ---- Initialize ----
type -q zoxide; and zoxide init fish | source

# Kitty shell integration for better window resizing behavior
if set -q KITTY_INSTALLATION_DIR
    set -g KITTY_SHELL_INTEGRATION enabled
    source "$KITTY_INSTALLATION_DIR/shell-integration/fish/vendor_conf.d/kitty-shell-integration.fish"
    set --prepend fish_complete_path "$KITTY_INSTALLATION_DIR/shell-integration/fish/vendor_completions.d"
end

# ---- Key bindings ----
fzf_configure_bindings --directory=\ct
fish_vi_key_bindings
set fish_cursor_default block
set fish_cursor_insert line
set fish_cursor_replace_one underscore
set fish_cursor_visual block
set fish_vi_force_cursor
