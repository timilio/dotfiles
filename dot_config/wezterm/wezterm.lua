local wezterm = require 'wezterm';

return {
    default_prog = {"/usr/local/bin/fish", "-l"},
    color_scheme = "Gruvbox Dark",
    font = wezterm.font("FiraCode Nerd Font"),
    send_composed_key_when_left_alt_is_pressed = true,
    enable_tab_bar = false,
    font_size = 18,
}
