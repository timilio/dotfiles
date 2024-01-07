{ pkgs, inputs, system, username, editor, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = username;
  home.homeDirectory = "/home/${username}";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  programs.git = {
    enable = true;
    userName = "timilio";
    userEmail = "42062607+timilio@users.noreply.github.com";
    ignores = [ ".DS_Store" ];
  };

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # rustup
    typst
    zk

    # It is sometimes useful to fine-tune packages, for example, by applying
    # overrides. You can do that directly here, just don't forget the
    # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # fonts?
    (pkgs.nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
    pkgs.jetbrains-mono

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  programs.firefox = {
    enable = true;
    package = null;
    profiles.${username} = {
      isDefault = true;
      extraConfig = let
        arkenfox = builtins.readFile "${inputs.arkenfox}/user.js";
        prefsToJs = pkgs.lib.attrsets.mapAttrsToList (
          name: value: ''user_pref("${name}", ${builtins.toJSON value});''
        );
        overrides = {
          "browser.safebrowsing.downloads.remote.enabled" = true;
          "privacy.resistFingerprinting" = false;
          "privacy.resistFingerprinting.letterboxing" = false;

          "browser.toolbars.bookmarks.visibility" = "newtab";
        }; in arkenfox + builtins.concatStringsSep "\n" (prefsToJs overrides);
      extensions = with inputs.firefox-addons.packages.${system}; [
        ublock-origin
        # i-dont-care-about-cookies
      ];
      search = {
        default = "DuckDuckGo";
        engines = {
          "Google".metaData.alias = "@g";
          "Nix Packages" = {
            urls = [{
              template = "https://search.nixos.org/packages";
              params = [
                { name = "type"; value = "packages"; }
                { name = "query"; value = "{searchTerms}"; }
              ];
            }];
            definedAliases = [ "@np" ];
          };
          "Home Manager Options" = {
            urls = [{
              template = "https://mipmip.github.io/home-manager-option-search";
              params = [
                { name = "query"; value = "{searchTerms}"; }
              ];
            }];
            definedAliases = [ "@hmo" ];
          };
        };
        force = true; # To make search config persistent
      };
    };
  };

  programs.neovim = {
    enable = false;
    vimdiffAlias = true;
  };

  programs.fish = {
    enable = true;
    shellAbbrs = {
      mv = "mv -vi";
      ls = "eza";
      ll = "eza -l";
      la = "eza -a";
      lla = "eza -la";

      e = editor;
      lg = "lazygit";
      rss = "newsboat";
      notes = "zk edit --interactive";

      gcc = "gcc $CFLAGS";
    };
    interactiveShellInit = ''
      fish_vi_key_bindings

      set -g CFLAGS -Wall -Werror -Wextra -Wpedantic \
              -Wformat=2 -Wno-unused-parameter -Wshadow \
              -Wwrite-strings -Wstrict-prototypes -Wold-style-definition \
              -Wredundant-decls -Wnested-externs -Wmissing-include-dirs \
              -Wfloat-equal -std=c99
      set -g man_standout -b yellow black
    '';
    plugins = [{
      name = "fish-colored-man";
      src = inputs.fish-colored-man;
    }];
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.bat = {
    enable = false;
    config = { theme = "ansi"; };
  };

  programs.kitty = {
    enable = true;
    package = pkgs.emptyDirectory;
    shellIntegration.enableFishIntegration = true;
    font = {
      name = "Comic Code Ligatures";
      size = 13;
    };
    extraConfig = ''
      modify_font cell_height 1px
      modify_font baseline -2
    '';
    theme = "Gruvbox Dark";
    settings = {
      shell = "${pkgs.fish}/bin/fish -l";

      scrollback_lines = 1000000;
      url_style = "straight";
      cursor_blink_interval = 0;

      remember_window_size = false;
      update_check_interval = 0;
    };
    keybindings = let
      tabSwithingGen = i: let n = toString (i+1); in { name = "alt+${n}"; value = "goto_tab ${n}";};
      tabSwitching = with builtins; listToAttrs (genList tabSwithingGen 9);
    in tabSwitching // { "super+f" = "toggle_fullscreen"; };
  };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".clang-format".source = ./dot_clang-format;
  };

  xdg = {
    enable = true;
    userDirs = {
      # enable = true;
      # createDirectories = true;
    };
    configFile = {
      "nix/nix.conf".source = ./dot_config/nix/nix.conf;
      "clangd/config.yaml".source = ./dot_config/clangd/config.yaml;
      # "kitty/kitty.conf".source = ./dot_config/kitty/kitty.conf;
      "newsboat/config".source = ./dot_config/newsboat/config;
      "newsboat/urls".source = ./dot_config/newsboat/urls;
      "npm/npmrc".source = ./dot_config/npm/npmrc;
      "nvim/init.fnl".source = ./dot_config/nvim/init.fnl;
      "nvim/init.lua".source = ./dot_config/nvim/init.lua;
      "nvim/plugin/completion.fnl".source = ./dot_config/nvim/plugin/completion.fnl;
      # lazy-lock.json
      "fish/functions/chezmoi_edit.fish".source = ./dot_config/fish/functions/chezmoi_edit.fish;
      "fish/functions/fish_greeting.fish".source = ./dot_config/fish/functions/fish_greeting.fish;
      "fish/functions/fish_mode_prompt.fish".source = ./dot_config/fish/functions/fish_mode_prompt.fish;
      "fish/functions/fish_prompt.fish".source = ./dot_config/fish/functions/fish_prompt.fish;
      "fish/functions/fish_right_prompt.fish".source = ./dot_config/fish/functions/fish_right_prompt.fish;
      "fish/functions/loadplug.fish".source = ./dot_config/fish/functions/loadplug.fish;
      "fish/functions/ssh.fish".source = ./dot_config/fish/functions/ssh.fish;
      # "fish/config.fish".source = ./dot_config/fish/config.fish;
      "mpv/mpv.conf".source = ./dot_config/mpv/mpv.conf;
      "rustfmt/rustfmt.toml".source = ./dot_config/rustfmt/rustfmt.toml;
      "zk/config.toml".source = ./dot_config/zk/config.toml;
    };
  };

  home.sessionVariables = {
    RUSTUP_HOME = "$XDG_DATA_HOME/rustup";
    CARGO_HOME = "$XDG_DATA_HOME/cargo";

    BROWSER = "firefox";
    EDITOR = editor;
    SHELL = "${pkgs.fish}/bin/fish";

    ZK_NOTEBOOK_DIR = "$HOME/Documents/notes";
  };

  home.sessionPath = [ "$CARGO_HOME/bin" ];

  # https://nixos.wiki/wiki/Home_Manager#Usage_on_non-NixOS_Linux
  targets.genericLinux.enable = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
