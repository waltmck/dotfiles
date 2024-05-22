{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  home-manager.users.waltmck = {
    home = {
      sessionVariables.BROWSER = "firefox";

      file."firefox-gnome-theme" = {
        target = ".mozilla/firefox/default/chrome/firefox-gnome-theme";
        source = inputs.firefox-gnome-theme;
      };
    };

    programs.firefox = {
      enable = true;

      package = pkgs.firefox.override {
        extraPolicies = {
          AppAutoUpdate = false;
          /*
          BackgroundAppUpdate = false;
          CaptivePortal = false;
          DisableFirefoxStudies = true;
          DisablePocket = true;
          DisableTelemetry = true;
          DisableFirefoxAccounts = true;
          DisableFirefoxScreenshots = true;
          NoDefaultBookmarks = true;
          OfferToSaveLogins = false;
          OfferToSaveLoginsDefault = false;
          PasswordManagerEnabled = false;
          UserMessaging = {
            ExtensionRecommendations = false;
            SkipOnboarding = true;
            WhatsNew = false; # Remove the “What’s New” icon and menuitem
            FeatureRecommendations = false; # Don’t recommend browser features
            MoreFromMozilla = false; # Don’t show the “More from Mozilla” section in Preferences
            Locked = true;
          };
          FirefoxHome = {
            Search = true;
            TopSites = false;
            SponsoredTopSites = false;
            Highlights = false;
            Pocket = false;
            SponsoredPocket = false;
            Snippets = false;
            Locked = true;
          };
          FirefoxSuggest = {
            WebSuggestions = false;
            SponsoredSuggestions = false;
            ImproveSuggest = false;
            Locked = true;
          };

          DisplayBookmarksToolbar = "never"; # alternatives: "always" or "newtab"
          DisplayMenuBar = "default-off"; # alternatives: "always", "never" or "default-on"
          # SearchBar = "unified"; # alternative: "separate"

          ExtensionSettings = {
            "*".installation_mode = "blocked"; # blocks all addons except the ones specified below
            # uBlock Origin:
            "uBlock0@raymondhill.net" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
              installation_mode = "force_installed";
            };
            # 1Password:
            "{d634138d-c276-4fc8-924b-40a0ea21d284}" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/1password-x-password-manager/latest.xpi";
              installation_mode = "force_installed";
            };
            # BypassPaywallsClean
            "magnolia@12.34" = {
              install_url = "https://github.com/bpc-clone/bpc_updates/releases/download/latest/bypass_paywalls_clean-latest.xpi";
              installation_mode = "force_installed";
            };
          };

          Preferences = {
            "browser.tabs.loadInBackground" = true;
            "widget.gtk.rounded-bottom-corners.enabled" = true;
            "svg.context-properties.content.enabled" = true;
            "browser.toolbars.bookmarks.visibility" = false;
            "mousewheel.default.delta_multiplier_y" = 60;
            "mousewheel.default.delta_multiplier_x" = 30;
            "browser.formfill.enable" = false;
            "extensions.formautofill.creditCards.enabled" = false;
            "browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts.searchEngines" = "";
            "services.sync.prefs.sync-seen.browser.urlbar.suggest.engines" = false;
            "services.sync.prefs.sync.browser.urlbar.suggest.engines" = false;
            "services.sync.prefs.sync-seen.services.sync.prefs.sync.browser.urlbar.suggest.engines" = false;
            "browser.urlbar.quicksuggest.enabled" = false;
            "browser.urlbar.suggest.addons" = false;
            "browser.urlbar.suggest.bookmark" = false;
            "browser.urlbar.suggest.calculator" = false;
            "browser.urlbar.suggest.clipboard" = false;
            "browser.urlbar.suggest.engines" = false;
            "browser.urlbar.suggest.mdn" = false;
            "browser.urlbar.suggest.openpage" = false;
            "browser.urlbar.quicksuggest.sponsored" = false;
            "browser.urlbar.quicksuggest.nonsponsored" = false;
            "browser.urlbar.suggest.topsites" = false;
            "browser.urlbar.suggest.trending" = false;
            "browser.urlbar.suggest.weather" = false;

            "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
            "browser.newtabpage.activity-stream.feeds.snippets" = false;
            "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
            "browser.newtabpage.activity-stream.section.highlights.includeBookmarks" = false;
            "browser.newtabpage.activity-stream.section.highlights.includeDownloads" = true;
            "browser.newtabpage.activity-stream.section.highlights.includeVisited" = false;
            "browser.newtabpage.activity-stream.showSponsored" = false;
            "browser.newtabpage.activity-stream.system.showSponsored" = false;
            "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
          };
          */
        };
      };

      profiles.default = {
        /*
          extensions = with inputs.firefox-addons.packages.${pkgs.system}; [
          ublock-origin
          onepassword-password-manager
          darkreader
          kagi-search
        ];
        */
        name = "Default";

        settings = {
          "gnomeTheme.hideSingleTab" = true;
          "gnomeTheme.bookmarksToolbarUnderTabs" = true;
          "gnomeTheme.normalWidthTabs" = false;
          "gnomeTheme.tabsAsHeaderbar" = false;
          "gnomeTheme.activeTabContrast" = true;
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          "widget.gtk.rounded-bottom-corners.enabled" = true;
          "svg.context-properties.content.enabled" = true;
        };
        userChrome = ''
          @import "firefox-gnome-theme/userChrome.css";
        '';
        userContent = ''
          @import "firefox-gnome-theme/userContent.css";
        '';
      };
    };
  };

  environment.persistence."/nix/state".users.waltmck = {
    directories = [
      ".mozilla" # Bookmarks, history, account, etc.
      ".cache/mozilla/firefox" # Cache for faster start time
    ];
  };
}
