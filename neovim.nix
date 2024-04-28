{pkgs, ...}: {
  home.sessionVariables.EDITOR = "nvim";

  home.packages = with pkgs; [
    nil
    quick-lint-js
    # haskell-language-server
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

      (nvim-treesitter.withPlugins (p: [p.bash p.c p.comment p.cpp p.css p.csv p.doxygen p.elixir p.gitignore p.fennel p.fish p.haskell p.html p.java p.javascript p.latex p.lua p.markdown p.markdown_inline p.nix p.ocaml p.ocaml_interface p.printf p.python p.rust p.sql p.toml p.typst p.vimdoc p.xml p.zig]))
      nvim-treesitter-textobjects
      rainbow-delimiters-nvim
      typst-vim
      vim-just
      # haskell-tools-nvim
      nvim-jdtls # java

      crates-nvim
      nabla-nvim
      # neorg
      # orgmode

      lualine-nvim
    ];
  };

  # HACK: jdtls needs this
  home.file = {
    ".local/share/jdtls/config_linux/config.ini".source = builtins.toPath "${pkgs.jdt-language-server}/share/java/jdtls/config_linux/config.ini";
  };

  xdg = {
    enable = true;
    configFile = {
      "nvim/fnl" = {
        source = ./config/nvim;
        recursive = true; # so we can insert nix_path.fnl
        onChange = ''
          rm -rf $XDG_CONFIG_HOME/nvim/lua
          mkdir -p $XDG_CONFIG_HOME/nvim/lua
          for file in $(find $XDG_CONFIG_HOME/nvim/fnl/ -type f -follow); do
            ${pkgs.luajitPackages.fennel}/bin/fennel --globals vim --compile $file > $(echo $file | sed 's/fnl/lua/g')
          done
        '';
      };
      "nvim/fnl/nix_path.fnl".text = ''
        {:java "${pkgs.temurin-bin}"
         :jdtls "${pkgs.jdt-language-server}"}
      '';
    };
  };
}
