{
  pkgs,
  username,
  ...
}: {
  home.sessionVariables.EDITOR = "nvim";

  home.packages = with pkgs; [
    nil
    quick-lint-js
    haskell-language-server
    ruff
    ruff-lsp
    taplo
    typst-lsp
    jdt-language-server # java
    # fennel-ls

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

  home.file = {
    ".local/share/jdtls/config_linux/config.ini".source = builtins.toPath "${pkgs.jdt-language-server}/share/java/jdtls/config_linux/config.ini";
  };

  xdg = {
    enable = true;
    configFile = {
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
    };
  };
}
