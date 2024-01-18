{
  pkgs,
  inputs,
  system,
  username,
  editor,
  ...
}: {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = username;
  home.homeDirectory = "/home/${username}";

  programs.git = {
    enable = true;
    package = pkgs.emptyDirectory;
    userName = "timilio";
    userEmail = "42062607+timilio@users.noreply.github.com";
    ignores = [".DS_Store"];
    extraConfig = {init.defaultBranch = "main";};
  };

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # rustup
    ghc
    typst
    zk

    (pkgs.nerdfonts.override {fonts = ["NerdFontsSymbolsOnly"];})
    pkgs.jetbrains-mono

    # neovim tools
    ltex-ls
    nil
    quick-lint-js
    haskell-language-server
    ruff
    ruff-lsp
    taplo
    typst-lsp

    alejandra
    biome
    nodePackages.fixjson
    djlint

    vscode-extensions.vadimcn.vscode-lldb.adapter
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

          "cookiebanners.service.mode" = 2; # experimental cookie banner dismissal

          "browser.toolbars.bookmarks.visibility" = "newtab";
          "ui.key.menuAccessKey" = 0;
          "mousewheel.default.delta_multiplier_x" = 25;
          "mousewheel.default.delta_multiplier_y" = 25;
          "mousewheel.default.delta_multiplier_z" = 25;
        };
      in
        arkenfox + builtins.concatStringsSep "\n" (prefsToJs overrides);
      extensions = with inputs.firefox-addons.packages.${system}; [
        ublock-origin
      ];
      search = {
        default = "Startpage";
        engines = {
          "Startpage" = {
            urls = [
              {
                template = "https://www.startpage.com/sp/search";
                params = [
                  {
                    name = "prfe";
                    value = "3e226c431de98dfe1230ffc9ec7b3acd327b5cb2820db80911491be8e9c11b9e9753671b5576d80b10da7482e225caba73c074d7681eb6fc4dc5b1f25cdd5ec8c7374e5256152470ea32cf01";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
          };
          "Nix Packages" = {
            urls = [
              {
                template = "https://search.nixos.org/packages";
                params = [
                  {
                    name = "type";
                    value = "packages";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            definedAliases = ["@np"];
          };
          "Home Manager Options" = {
            urls = [
              {
                template = "https://mipmip.github.io/home-manager-option-search";
                params = [
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            definedAliases = ["@hmo"];
          };
        };
        force = true; # To make search config persistent
      };
    };
  };

  programs.neovim = {
    enable = true;
    vimdiffAlias = true;
    extraLuaConfig = ''
      require('init')
      require('completion')
    '';
    plugins = with pkgs.vimPlugins; [
      everforest
      # vim-solarized8
      gruvbox-nvim
      onedarkpro-nvim

      nvim-web-devicons
      plenary-nvim

      vim-repeat
      vim-surround
      comment-nvim
      leap-nvim
      flit-nvim
      mini-nvim # align
      vim-table-mode

      fzf-lua
      dressing-nvim

      nvim-lspconfig
      none-ls-nvim
      lsp-format-nvim
      fidget-nvim
      lsp_signature-nvim

      nvim-dap
      nvim-dap-ui
      nvim-dap-python

      nvim-cmp
      nvim-snippy
      cmp-snippy
      cmp-under-comparator
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-pandoc-references
      cmp-fish

      (nvim-treesitter.withPlugins (p: [p.bash p.c p.comment p.cpp p.css p.doxygen p.elixir p.fennel p.fish p.haskell p.html p.javascript p.latex p.lua p.markdown p.markdown_inline p.nix p.python p.rust p.sql p.toml p.vimdoc p.zig]))
      nvim-treesitter-textobjects
      rainbow-delimiters-nvim
      typst-vim

      crates-nvim
      nabla-nvim
      # neorg
      # orgmode

      lualine-nvim
    ];
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
      backup = "rsync ~/Pictures ~/Videos ~/Music ~/Documents /run/media/${username}/Samsung\ USB/ -a --modify-window 1 --exclude '**/target' --exclude '**/node_modules' --exclude '**/.build' --exclude '**cache*' --exclude '**/.elixir_ls' --exclude '**/.stack-work' --exclude '**/doc' --delete-excluded -nv";
    };
    interactiveShellInit = ''
      fish_vi_key_bindings

      set -g CFLAGS -Wall -Werror -Wextra -Wpedantic -Wformat=2 -Wno-unused-parameter -Wshadow -Wwrite-strings -Wstrict-prototypes -Wold-style-definition -Wredundant-decls -Wnested-externs -Wmissing-include-dirs -Wfloat-equal -std=c99
      set -g man_standout -b yellow black
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

  programs.lazygit = {
    enable = true;
    package = pkgs.emptyDirectory;
    settings = {
      git.autoFetch = false;
    };
  };

  programs.kitty = {
    enable = true;
    package = pkgs.emptyDirectory;
    shellIntegration.enableFishIntegration = true;
    font = {
      name = "Comic Code Ligatures";
      size = 14;
    };
    extraConfig = ''
      modify_font cell_height 1px
      modify_font baseline -2
    '';
    theme = "Gruvbox Dark";
    settings = {
      shell = "fish -l";

      scrollback_lines = 1000000;
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

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".clang-format".source = ./clang-format;
    ".editorconfig".source = ./editorconfig;
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
      "nvim/fnl" = {
        source = ./config/nvim;
        onChange = ''
          rm -rf $XDG_CONFIG_HOME/nvim/lua
          mkdir $XDG_CONFIG_HOME/nvim/lua
          for file in $(find $XDG_CONFIG_HOME/nvim/fnl/ -type f)
          do ${pkgs.luajitPackages.fennel}/bin/fennel --compile $file > $(echo $file | sed 's/fnl/lua/g')
          done
        '';
      };
      "rustfmt".source = ./config/rustfmt;
      "zk".source = ./config/zk;
    };
  };

  home.sessionVariables = {
    RUSTUP_HOME = "$XDG_DATA_HOME/rustup";
    CARGO_HOME = "$XDG_DATA_HOME/cargo";

    BROWSER = "firefox";
    EDITOR = editor;
    SHELL = "fish";

    ZK_NOTEBOOK_DIR = "$HOME/Documents/notes";
  };

  home.sessionPath = ["$CARGO_HOME/bin"];

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # https://nixos.wiki/wiki/Home_Manager#Usage_on_non-NixOS_Linux
  targets.genericLinux.enable = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
