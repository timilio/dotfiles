{pkgs, ...}: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimdiffAlias = true;
    extraPackages = with pkgs; [
      tree-sitter

      nil # nix
      alejandra # nix
      biome # javascript, typescript, json
      djlint # html
      quick-lint-js # javascript
      # haskell-language-server
      python312Packages.jedi-language-server # python
      ruff # python
      taplo # toml
      typst-lsp
      jdt-language-server # java
      # fennel-ls

      vscode-extensions.vadimcn.vscode-lldb.adapter
    ];
    # https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/editors/vim/plugins/generated.nix
    plugins = [
      pkgs.vimPlugins.lazy-nvim
    ];
    extraLuaConfig = ''
      require('init')
      require('completion')
    '';
    withNodeJs = true;
  };

  # HACK: jdtls needs this
  home.file = {
    ".local/share/jdtls/config_linux/config.ini".source = builtins.toPath "${pkgs.jdt-language-server}/share/java/jdtls/config_linux/config.ini";
  };

  xdg = {
    enable = true;
    configFile = {
      "nvim/snippets".source = ./config/nvim/snippets;
      "nvim/fnl" = {
        source = ./config/nvim/fnl;
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
