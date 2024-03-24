{
  pkgs,
  inputs,
  username,
  editor,
  ...
}: {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = username;
  home.homeDirectory = "/home/${username}";

  imports = [
    ./firefox.nix
  ];

  programs.git = {
    enable = true;
    package = pkgs.emptyDirectory;
    userName = "timilio";
    userEmail = "42062607+timilio@users.noreply.github.com";
    ignores = [".DS_Store"];
    extraConfig = {init.defaultBranch = "main";};
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

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # rustup
    du-dust
    ghc
    typst
    temurin-bin # java
    # fennel-ls

    (pkgs.nerdfonts.override {fonts = ["NerdFontsSymbolsOnly"];})
    pkgs.jetbrains-mono

    # neovim tools
    nil
    quick-lint-js
    haskell-language-server
    ruff
    ruff-lsp
    taplo
    typst-lsp
    jdt-language-server # java

    alejandra
    biome
    djlint

    vscode-extensions.vadimcn.vscode-lldb.adapter
  ];

  programs.neovim = {
    enable = true;
    vimdiffAlias = true;
    extraLuaConfig = ''
      require('init')
      require('completion')
    '';
    # https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/editors/vim/plugins/generated.nix
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

      (nvim-treesitter.withPlugins (p: [p.bash p.c p.comment p.cpp p.css p.csv p.doxygen p.elixir p.gitignore p.fennel p.fish p.haskell p.html p.java p.javascript p.latex p.lua p.markdown p.markdown_inline p.nix p.ocaml p.ocaml_interface p.printf p.python p.rust p.sql p.toml p.typst p.vimdoc p.zig]))
      nvim-treesitter-textobjects
      rainbow-delimiters-nvim
      typst-vim
      vim-just
      haskell-tools-nvim
      nvim-jdtls # java

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

      fixwifi = "sudo sh -c 'echo 1 > /sys/bus/pci/devices/0000:01:00.0/remove; echo 1 > /sys/bus/pci/rescan'";

      e = editor;
      lg = "lazygit";
      rss = "newsboat";
      notes = "zk edit --interactive";
      docker = "podman";

      gcc = "gcc $CFLAGS";
      backup = "restic backup --exclude-file ~/.dotfiles/restic-excludes --exclude-caches ~/.dotfiles/ ~/Calibre\\ Library/ ~/Documents/ ~/Music/ ~/Pictures/ ~/Videos/ ~/Zotero/";
    };
    interactiveShellInit = ''
      fish_vi_key_bindings

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

  programs.opam = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.zk = {
    enable = true;
  };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".clang-format".source = ./clang-format;
    ".cargo/config.toml".source = ./config/cargo/config.toml;
    ".local/share/jdtls/config_linux/config.ini".source = builtins.toPath "${pkgs.jdt-language-server}/share/java/jdtls/config_linux/config.ini";
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
      "nvim/ftplugin/java.lua".text = "
-- See `:help vim.lsp.start_client` for an overview of the supported `config` options.
local config = {
  -- The command that starts the language server
  -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
  cmd = {
    '${pkgs.temurin-bin}/bin/java',

    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.protocol=true',
    '-Dlog.level=ALL',
    '-Xmx1g',
    '--add-modules=ALL-SYSTEM',
    '--add-opens', 'java.base/java.util=ALL-UNNAMED',
    '--add-opens', 'java.base/java.lang=ALL-UNNAMED',

    '-jar', vim.fn.glob('${pkgs.jdt-language-server}/share/java/jdtls/plugins/org.eclipse.equinox.launcher_*.jar'),

    '-configuration', '/home/${username}/.local/share/jdtls/config_linux',

    -- See `data directory configuration` section in the README
    '-data', '/home/${username}/.local/share/jdtls/data/' .. vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
  },

  -- This is the default if not provided, you can remove it. Or adjust as needed.
  -- One dedicated LSP server & client will be started per unique root_dir
  root_dir = require('jdtls.setup').find_root({'.git', 'mvnw', 'gradlew'}),

  -- Here you can configure eclipse.jdt.ls specific settings
  -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
  -- for a list of options
  settings = {
    java = {
    }
  },

  -- Language server `initializationOptions`
  -- You need to extend the `bundles` with paths to jar files
  -- if you want to use additional eclipse.jdt.ls plugins.
  --
  -- See https://github.com/mfussenegger/nvim-jdtls#java-debug-installation
  --
  -- If you don't plan on using the debugger or other eclipse.jdt.ls plugins you can remove this
  init_options = {
    bundles = {}
  },
}
-- This starts a new client & server,
-- or attaches to an existing client & server depending on the `root_dir`.
require('jdtls').start_or_attach(config)";
      "rustfmt".source = ./config/rustfmt;
      "zk".source = ./config/zk;
    };
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

  home.sessionVariables = {
    RUSTUP_HOME = "$XDG_DATA_HOME/rustup";
    CARGO_HOME = "$XDG_DATA_HOME/cargo";

    BROWSER = "firefox";
    EDITOR = editor;
    SUDO_EDITOR = "vi";
    SHELL = "fish";

    RESTIC_REPOSITORY = "/run/media/${username}/Samsung\ USB/";
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
