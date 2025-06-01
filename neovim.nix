{
  inputs,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    (writeShellApplication {
      name = "gdvim";
      text = ''
        cd "$(find ~/Documents/godot -mindepth 1 -maxdepth 1 -type d | fzf)" &&
        nvim --listen /tmp/godot-nvim.pipe
      '';
    })
  ];

  programs.neovim = {
    enable = true;
    package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
    defaultEditor = true;
    extraPackages = with pkgs; [
      tree-sitter

      nil # nix
      alejandra # nix formatting
      quick-lint-js # javascript
      # haskell-language-server # haskell
      python312Packages.jedi-language-server # python
      ruff # python
      taplo # toml
      tinymist # typst
      jdt-language-server # java
      fennel-ls # fennel
      neocmakelsp # cmake
      gersemi # cmake formatting

      vscode-extensions.vadimcn.vscode-lldb.adapter # dap
    ];
    # https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/editors/vim/plugins/generated.nix
    plugins = [
      pkgs.vimPlugins.lazy-nvim
    ];
    extraLuaConfig = ''
      require('init')
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
