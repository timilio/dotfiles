{
  pkgs,
  inputs,
  system,
  username,
  ...
}: {
  home.sessionVariables.BROWSER = "firefox";

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
          "browser.startup.page" = 1;
          "browser.startup.homepage" = "about:newtab";
          "extensions.pocket.enabled" = false;
          "ui.key.menuAccessKey" = 0;

          "mousewheel.default.delta_multiplier_x" = 25; # sane touchpad scrolling
          "mousewheel.default.delta_multiplier_y" = 25;
          "mousewheel.default.delta_multiplier_z" = 25;

          "font.cjk_pref_fallback_order" = "ja,zh-cn,zh-hk,zh-tw,ko";
        };
      in
        arkenfox + builtins.concatStringsSep "\n" (prefsToJs overrides);
      extensions = with inputs.firefox-addons.packages.${system}; [
        ublock-origin
        yomitan
      ];
      search = {
        default = "DuckDuckGo";
        engines = {
          "Google".metaData.hidden = true;
          "Bing".metaData.hidden = true;
          "Startpage" = {
            urls = [
              {
                template = "https://www.startpage.com/sp/search";
                params = [
                  {
                    name = "prfe";
                    value = "190e1026d0debef85b4bafd4e10b30ac9974bab2b645d4f3cba7af96bce49c7e7fab0089dfdaa217ad3f149c05dbc370610bc1271d9ad81f6c511153da8c49cb5bc75e1efdf20619679b6f8f";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            definedAliases = ["@st"];
          };
          "Wiby" = {
            urls = [
              {
                template = "https://wiby.me/";
                params = [
                  {
                    name = "q";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            definedAliases = ["@w"];
          };
          "Hacker News Search" = {
            urls = [
              {
                template = "https://hn.algolia.com/";
                params = [
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            definedAliases = ["@hn"];
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
                template = "https://home-manager-options.extranix.com/";
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
          "Massif" = {
            urls = [
              {
                template = "https://massif.la/ja/search";
                params = [
                  {
                    name = "q";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            definedAliases = ["@m" "@jp"];
          };
        };
        force = true; # To make search config persistent
      };
    };
    profiles.unblocked = {
      id = 1;
      isDefault = false;
      extraConfig = let
        prefsToJs = pkgs.lib.attrsets.mapAttrsToList (
          name: value: ''user_pref("${name}", ${builtins.toJSON value});''
        );
        overrides = {
          "browser.toolbars.bookmarks.visibility" = "newtab";
          "browser.startup.page" = 1;
          "browser.startup.homepage" = "about:newtab";

          "ui.key.menuAccessKey" = 0;
          "mousewheel.default.delta_multiplier_x" = 25; # sane touchpad scrolling
          "mousewheel.default.delta_multiplier_y" = 25;
          "mousewheel.default.delta_multiplier_z" = 25;

          "font.cjk_pref_fallback_order" = "ja,zh-cn,zh-hk,zh-tw,ko";
        };
      in
        builtins.concatStringsSep "\n" (prefsToJs overrides);
    };
  };
}
