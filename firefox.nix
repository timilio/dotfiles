{
  lib,
  inputs,
  settings,
  ...
}: let
  prefsToJs = prefs:
    builtins.concatStringsSep "\n" (
      lib.mapAttrsToList (
        name: value: ''user_pref("${name}", ${builtins.toJSON value});''
      )
      prefs
    );
  basicOverrides =
    {
      "browser.toolbars.bookmarks.visibility" = "newtab";
      "browser.startup.page" = 1;
      "browser.startup.homepage" = "about:newtab";
      "ui.key.menuAccessKey" = 0;

      "font.cjk_pref_fallback_order" = "ja,zh-cn,zh-hk,zh-tw,ko";
    }
    // lib.optionalAttrs settings.isLaptop {
      # sane touchpad scrolling
      "mousewheel.default.delta_multiplier_x" = 25;
      "mousewheel.default.delta_multiplier_y" = 25;
      "mousewheel.default.delta_multiplier_z" = 25;
    };
  extraOverrides = {
    "browser.safebrowsing.downloads.remote.enabled" = true;
    "privacy.resistFingerprinting" = false;
    "privacy.resistFingerprinting.letterboxing" = false;
    "privacy.clearOnShutdown_v2.browsingHistoryAndDownloads" = true;
    "webgl.disabled" = false;
  };
in {
  home.sessionVariables.BROWSER = "firefox";

  programs.firefox = {
    enable = true;
    package = null;
    profileVersion = null; # broken otherwise (take care: internal!)
    profiles.${settings.username} = {
      isDefault = true;
      extraConfig = let
        arkenfox = builtins.readFile "${inputs.arkenfox}/user.js";
      in
        arkenfox + prefsToJs (basicOverrides // extraOverrides);
      search = {
        default = "duckduckgo";
        engines = {
          "ddg".metaData.hidden = true;
          "google".metaData.hidden = true;
          "bing".metaData.hidden = true;
          "duckduckgo" = {
            urls = [
              {
                template = "https://noai.duckduckgo.com";
                params = [
                  {
                    name = "q";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
          };
          "youtube" = {
            urls = [
              {
                template = "https://www.youtube.com/results";
                params = [
                  {
                    name = "search_query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            definedAliases = ["@you"];
          };
          "Kagi" = {
            urls = [
              {
                template = "https://kagi.com/search";
                params = [
                  {
                    name = "q";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            definedAliases = ["@k"];
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
                    name = "channel";
                    value = "unstable";
                  }
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
                  {
                    name = "release";
                    value = "master";
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
          "cppreference" = {
            urls = [
              {
                template = "https://duckduckgo.com/";
                params = [
                  {
                    name = "sites";
                    value = "www.cppreference.com/w/cpp";
                  }
                  {
                    name = "q";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            definedAliases = ["@cpp"];
          };
          "creference" = {
            urls = [
              {
                template = "https://duckduckgo.com/";
                params = [
                  {
                    name = "sites";
                    value = "www.cppreference.com/w/c";
                  }
                  {
                    name = "q";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            definedAliases = ["@c"];
          };
          "Python Docs" = {
            urls = [
              {
                template = "https://docs.python.org/3/search.html";
                params = [
                  {
                    name = "q";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            definedAliases = ["@py"];
          };
          "Hoogle" = {
            urls = [
              {
                template = "https://hoogle.haskell.org/";
                params = [
                  {
                    name = "hoogle";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            definedAliases = ["@hoogle"];
          };
          "Loogle" = {
            urls = [
              {
                template = "https://loogle.lean-lang.org/";
                params = [
                  {
                    name = "q";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            definedAliases = ["@loogle"];
          };
          "Noogle" = {
            urls = [
              {
                template = "https://noogle.dev/q/";
                params = [
                  {
                    name = "term";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            definedAliases = ["@noogle"];
          };
        };
        force = true; # To make search config persistent
      };
    };
    profiles.unblocked = {
      id = 1;
      isDefault = false;
      extraConfig = prefsToJs basicOverrides;
    };
  };
}
