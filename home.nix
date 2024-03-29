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

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # rustup
    du-dust
    ghc
    typst
    temurin-bin # java

    (pkgs.nerdfonts.override {fonts = ["NerdFontsSymbolsOnly"];})
    pkgs.jetbrains-mono
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
    '';
    theme = "Gruvbox Dark";
    settings = {
      shell = "fish -l";

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
      backup = "restic backup --exclude-file ~/.dotfiles/restic-excludes --exclude-caches ~/.dotfiles/ ~/Calibre\\ Library/ ~/Documents/ ~/Music/ ~/Pictures/ ~/Videos/ ~/Zotero/";
    };
    interactiveShellInit = ''
      fish_vi_key_bindings

      abbr -a e $EDITOR

      set -g man_standout -b yellow black

      set -gx CFLAGS -Wall -Wextra -Wpedantic -Wformat=2 -Wno-unused-parameter -Wshadow -Wwrite-strings -Wstrict-prototypes -Wold-style-definition -Wredundant-decls -Wnested-externs -Wmissing-include-dirs -Wfloat-equal -std=c99
    '';
    plugins = [
      {
        name = "fish-colored-man";
        src = inputs.fish-colored-man;
      }
    ];
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.opam = {
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

      "*.{fnl,nix,typ,ml}" = {
        indent_size = 2;
      };

      "Makefile" = {
        indent_style = "tab";
      };
    };
  };

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
      "newsboat".source = ./config/newsboat;
      "nix".source = ./config/nix;
      "npm".source = ./config/npm;
      "rustfmt".source = ./config/rustfmt;
      "zk".source = ./config/zk;
    };
  };

  home.sessionVariables = {
    RUSTUP_HOME = "$XDG_DATA_HOME/rustup";
    CARGO_HOME = "$XDG_DATA_HOME/cargo";

    SUDO_EDITOR = "vi";
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
