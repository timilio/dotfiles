{
  pkgs,
  inputs,
  username,
  ...
}: {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = username;
  home.homeDirectory = "/home/${username}";

  imports = [
    ./firefox.nix
    ./neovim.nix
  ];

  fonts.fontconfig.enable = true;

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # rustup
    du-dust
    # ghc
    typst
    temurin-bin # java

    font-awesome
    (nerdfonts.override {fonts = ["NerdFontsSymbolsOnly"];})
    jetbrains-mono
  ];

  programs.git = {
    enable = true;
    package = pkgs.emptyDirectory;
    userName = "timilio";
    userEmail = "42062607+timilio@users.noreply.github.com";
    ignores = [".DS_Store"];
    extraConfig = {init.defaultBranch = "main";};
  };

  programs.lazygit = {
    enable = true;
    package = pkgs.emptyDirectory;
    settings = {
      git.autoFetch = false;
    };
  };

  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = "timilio";
        email = "42062607+timilio@users.noreply.github.com";
      };
    };
  };

  programs.kitty = {
    enable = true;
    package = pkgs.emptyDirectory;
    shellIntegration.enableFishIntegration = true;
    font = {
      name = "Comic Code Ligatures";
      size = 12;
    };
    extraConfig = ''
      modify_font cell_height 1px
      modify_font baseline -2

      symbol_map U+e000-U+e00a,U+ea60-U+ebeb,U+e0a0-U+e0c8,U+e0ca,U+e0cc-U+e0d4,U+e200-U+e2a9,U+e300-U+e3e3,U+e5fa-U+e6b1,U+e700-U+e7c5,U+f000-U+f2e0,U+f300-U+f372,U+f400-U+f532,U+f0001-U+f1af0 Symbols Nerd Font Mono
    '';
    theme = "Gruvbox Dark";
    settings = {
      shell = "${pkgs.fish}/bin/fish -l";

      scrollback_lines = 10000;
      url_style = "straight";
      cursor_blink_interval = 0;

      remember_window_size = false;
      update_check_interval = 0;
    };
    keybindings = let
      tabSwitchingGen = i: let
        n = toString (i + 1);
      in {
        name = "alt+${n}";
        value = "goto_tab ${n}";
      };
      tabSwitching = with builtins; listToAttrs (genList tabSwitchingGen 9);
    in
      tabSwitching // {"super+f" = "toggle_fullscreen";};
  };

  programs.fish = {
    enable = true;
    shellAbbrs = {
      mv = "mv -vi";
      ls = "eza";
      ll = "eza -l";
      la = "eza -a";
      lla = "eza -la";

      fixwifi = "sudo sh -c 'echo 1 > /sys/bus/pci/devices/0000:01:00.0/remove; echo 1 > /sys/bus/pci/rescan'";

      lg = "lazygit";
      rss = "newsboat";
      notes = "zk edit --interactive";
      docker = "podman";

      gcc = "gcc $CFLAGS";
      "g++" = "g++ $CXXFLAGS";
      aoc = "wl-paste | ./a.out";

      backup = "restic backup --exclude-file ~/.dotfiles/restic-excludes --exclude-caches ~/.dotfiles/ ~/Calibre\\ Library/ ~/Documents/ ~/Music/ ~/Pictures/ ~/Templates/ ~/Videos/ ~/Zotero/ ~/.config/newsboat/urls";
    };
    interactiveShellInit = ''
      fish_vi_key_bindings

      abbr -a e $EDITOR

      set -g man_standout -b yellow black

      set -gx CFLAGS -Wall -Wextra -Wpedantic -Wformat=2 -Wno-unused-parameter -Wshadow -Wwrite-strings -Wstrict-prototypes -Wold-style-definition -Wredundant-decls -Wnested-externs -Wmissing-include-dirs -Wfloat-equal -std=c99
      set -gx CXXFLAGS -Wall -Wextra -Wpedantic -D_GLIBCXX_ASSERTIONS -g -std=gnu++23 -O2
    '';
    plugins = [
      {
        name = "fish-colored-man";
        src = inputs.fish-colored-man;
      }
    ];
  };

  programs.broot = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      modal = true;
    };
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.zk = {
    enable = true;
  };

  editorconfig = {
    enable = true;
    settings = {
      "*" = {
        charset = "utf-8";
        end_of_line = "lf";
        indent_size = 4;
        indent_style = "space";
        insert_final_newline = true;
        trim_trailing_whitespace = true;
      };

      "*.{fnl,html,json,ml,nix,typ,xml}" = {
        indent_size = 2;
      };

      "Makefile" = {
        indent_style = "tab";
      };

      "*.spec" = {
        indent_style = "tab";
      };
    };
  };

  programs.man.enable = false; # otherwise apropos or whatis do not work

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".clang-format".source = ./clang-format;
    ".cargo/config.toml".source = ./config/cargo/config.toml;
  };

  xdg = {
    enable = true;
    configFile = {
      "clangd".source = ./config/clangd;
      "fish/functions".source = ./config/fish/functions;
      "mpv/mpv.conf".source = ./config/mpv/mpv.conf;
      "newsboat/config".source = ./config/newsboat/config;
      "npm".source = ./config/npm;
      "rustfmt".source = ./config/rustfmt;
      "zk".source = ./config/zk;
    };
  };

  home.sessionVariables = {
    # XDG_DATA_HOME does not seem to be set yet here, so hardcode instead
    RUSTUP_HOME = "$HOME/.local/share/rustup";
    CARGO_HOME = "$HOME/.local/share/cargo";

    SUDO_EDITOR = "vi";
    SYSTEMD_EDITOR = "vi";
    SHELL = "fish";

    RESTIC_REPOSITORY = "/run/media/${username}/Samsung\ USB/";
    ZK_NOTEBOOK_DIR = "$HOME/Documents/notes";
  };

  home.sessionPath = ["$CARGO_HOME/bin"];

  # https://nixos.wiki/wiki/Home_Manager#Usage_on_non-NixOS_Linux
  targets.genericLinux.enable = true;

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
