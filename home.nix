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
    dust
    # ghc
    typst
    temurin-bin # java
    elan # lean
    emscripten # emcc
    shader-slang # slang

    font-awesome
    nerd-fonts.symbols-only
    jetbrains-mono
  ];

  programs.git = {
    enable = true;
    package = pkgs.emptyDirectory;
    ignores = [".DS_Store" "*.aux" "*.auxlock" "*.bcf" "*.bit" "*.blg" "*.bbl" "*.fdb_latexmk" "*.fls" "*.lof" "*.log" "*.lot" "*.glo" "*.glx" "*.gxg" "*.gxs" "*.idx" "*.ilg" "*.ind" "*.md5" "*.out" "*.run.xml" "*.synctex.gz" "*.toc" "*.url"];
    includes = [
      {
        condition = "gitdir:~/Documents/uni/";
        path = "~/.gitconfig-uni";
      }
    ];
    lfs.enable = true;
    settings = {
      user = {
        name = "timilio";
        email = "42062607+timilio@users.noreply.github.com";
      };
      init.defaultBranch = "main";
      delta.syntax-theme = "Everforest Dark";
    };
  };

  programs.bat = {
    enable = true;
    config = {
      theme = "Everforest Dark";
      style = "numbers,rule,header";
    };
    themes = {everforest.src = inputs.bat-everforest;};
  };

  programs.lazygit = {
    enable = true;
    package = pkgs.emptyDirectory;
    enableFishIntegration = false; # conflicts with my functions; https://github.com/nix-community/home-manager/pull/8045
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
    font = {
      name = "Comic Code Ligatures";
      size = 12;
    };
    extraConfig = ''
      modify_font cell_height 1px
      modify_font baseline -2

      symbol_map U+e000-U+e00a,U+ea60-U+ebeb,U+e0a0-U+e0c8,U+e0ca,U+e0cc-U+e0d4,U+e200-U+e2a9,U+e300-U+e3e3,U+e5fa-U+e6b1,U+e700-U+e7c5,U+f000-U+f2e0,U+f300-U+f372,U+f400-U+f532,U+f0001-U+f1af0 Symbols Nerd Font Mono
    '';
    themeFile = "gruvbox-dark-hard";
    settings = {
      shell = "${pkgs.fish}/bin/fish -l";

      scrollback_lines = 10000;
      url_style = "straight";
      cursor_blink_interval = 0;

      remember_window_size = false;
      initial_window_width = 960;
      initial_window_height = 600;

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

  home.shell.enableFishIntegration = true;
  programs.fish = {
    enable = true;
    shellAbbrs = {
      ll = "ls -l";
      la = "ls -a";
      lla = "ls -la";
      copy = "history --max 1 | wl-copy -n";

      fixwifi = "sudo sh -c 'echo 1 > /sys/bus/pci/devices/0000:01:00.0/remove; echo 1 > /sys/bus/pci/rescan'";

      lg = "lazygit";
      rss = "newsboat";
      docker = "podman";

      gcc = "gcc $MY_CFLAGS";
      "g++" = "g++ $MY_CXXFLAGS";
      aoc = "wl-paste | ./a.out";

      backup = "restic backup --exclude-file ~/.dotfiles/restic-exclude --exclude-caches ~/.dotfiles/ ~/Calibre\\ Library/ ~/Documents/ ~/Music/ ~/Pictures/ ~/Templates/ ~/Videos/ ~/Zotero/ ~/.config/newsboat/urls ~/scripts";
    };
    shellAliases = {
      cargo = "cargo mommy";
      ls = "eza";
      mv = "mv -vi";
    };
    interactiveShellInit = ''
      fish_vi_key_bindings

      abbr -a e $EDITOR

      set -g man_standout -b yellow black

      set -gx MY_CFLAGS -g -std=c23 -Wall -Wextra -Wpedantic -Wmissing-declarations -Wmissing-prototypes -Wold-style-definition -Wformat=2 -Wno-unused-parameter -Wshadow -Wwrite-strings -Wstrict-prototypes -Wredundant-decls -Wnested-externs -Wmissing-include-dirs -Wfloat-equal
      set -gx MY_CXXFLAGS -g -std=c++23 -Wall -Wextra -Wpedantic
    '';
    plugins = [
      {
        name = "fish-colored-man";
        src = inputs.fish-colored-man;
      }
    ];
  };

  programs.fzf = {
    enable = true;
  };

  programs.broot = {
    enable = true;
    settings = {
      modal = true;
    };
  };

  programs.zoxide = {
    enable = true;
  };

  programs.man.enable = false; # otherwise apropos or whatis do not work

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".cargo/config.toml".source = ./config/cargo/config.toml;
    ".clang-format".source = ./clang-format;
    ".editorconfig".source = ./.editorconfig;
    ".infokey".source = ./infokey;
  };

  xdg = {
    enable = true;
    configFile = {
      "home-manager".source = ./.;
      "clangd".source = ./config/clangd;
      "fish/functions".source = ./config/fish/functions;
      "gdb".source = ./config/gdb;
      "mpv/mpv.conf".source = ./config/mpv/mpv.conf;
      "newsboat/config".source = ./config/newsboat/config;
      "npm".source = ./config/npm;
      "R".source = ./config/R;
      "rustfmt".source = ./config/rustfmt;
      "SuperCollider/startup.scd".source = ./config/SuperCollider/superdirt_startup.scd;
    };
  };

  home.sessionVariables = {
    # XDG_DATA_HOME does not seem to be set yet here, so hardcode instead
    ASDF_DATA_DIR = "$HOME/.local/share/asdf";
    RUSTUP_HOME = "$HOME/.local/share/rustup";
    CARGO_HOME = "$HOME/.local/share/cargo";
    GOPATH = "$HOME/.local/share/go";
    ZVM_PATH = "$HOME/.local/share/zvm";
    ZVM_INSTALL = "$HOME/.local/share/zvm/self";

    SUDO_EDITOR = "vi";
    SYSTEMD_EDITOR = "vi";
    SHELL = "fish";
    MATLAB_SHELL = "/bin/bash";

    RESTIC_REPOSITORY = "/run/media/${username}/Samsung\ USB/";
  };

  home.sessionPath = ["$HOME/scripts" "$CARGO_HOME/bin" "$GOPATH/bin" "$HOME/.juliaup/bin" "$ZVM_INSTALL" "$ZVM_PATH/bin"];

  # https://nixos.wiki/wiki/Home_Manager#Usage_on_non-NixOS_Linux
  targets.genericLinux.enable = true;

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
