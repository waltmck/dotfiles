{
  lib,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib) concatStringsSep escapeShellArg mapAttrsToList;
  env = {
    MOZ_WEBRENDER = 1;
    # For a better scrolling implementation and touch support.
    # Be sure to also disable "Use smooth scrolling" in about:preferences
    MOZ_USE_XINPUT2 = 1;
    # Required for hardware video decoding.
    # See https://github.com/elFarto/nvidia-vaapi-driver?tab=readme-ov-file#firefox
    MOZ_DISABLE_RDD_SANDBOX = 1;
    LIBVA_DRIVER_NAME = "nvidia";
    NVD_BACKEND = "direct";
  };
  envStr = concatStringsSep " " (mapAttrsToList (n: v: "${n}=${escapeShellArg v}") env);

  firefox-pkg =
    (pkgs.firefox.overrideAttrs (old: {
      buildCommand =
        old.buildCommand
        + ''
          substituteInPlace $out/bin/firefox \
            --replace "exec -a" ${escapeShellArg envStr}" exec -a"
        '';
    }))
    .override {
      extraPolicies = {
        AppAutoUpdate = false;

        BackgroundAppUpdate = false;
        AppUpdateURL = "";

        DisableSystemAddonUpdate = true;
        CaptivePortal = false;
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableTelemetry = true;
        DisableFirefoxAccounts = true;
        DisableFirefoxScreenshots = true;
        NoDefaultBookmarks = true;
        OfferToSaveLogins = false;
        OfferToSaveLoginsDefault = false;
        DisableFormHistory = true;
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
          Search = false;
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

        AutofillAddressEnabled = false;
        AutofillCreditCardEnabled = false;
      };
    };
in {
  environment.systemPackages = [firefox-pkg];

  # Install gnome theme
  home-manager.users.waltmck.home = {
    sessionVariables.BROWSER = "firefox";

    file."firefox-gnome-theme" = {
      target = ".mozilla/firefox/default/chrome/firefox-gnome-theme";
      source = inputs.firefox-gnome-theme;
    };
  };

  # Add shortcut using our override firefox
  home-manager.users.waltmck.wayland.windowManager.hyprland.settings.bind = ["SUPER, W, exec, systemd-run --user --slice=app.slice --no-block --collect --scope ${firefox-pkg}/bin/firefox"];

  home-manager.users.waltmck.programs.firefox = {
    enable = true;
    package = firefox-pkg;

    profiles.default = {
      id = 0;
      isDefault = true;

      extensions = with inputs.firefox-addons.packages.${pkgs.system}; [
        ublock-origin
        onepassword-password-manager
        darkreader
        kagi-search
        sponsorblock
        bypass-paywalls-clean
        i-dont-care-about-cookies
        user-agent-string-switcher
        # keepassxc
        # zotero-connector
        # mullvad
      ];

      # Hide tab bar because we have tree style tabs
      userChrome = ''
        @import "firefox-gnome-theme/userChrome.css";

        #TabsToolbar #firefox-view-button {
            display: none !important;
          }

        #star-button-box { display:none !important; }
      '';

      userContent = ''
        @import "firefox-gnome-theme/userContent.css";
      '';

      extraConfig = builtins.concatStringsSep "\n" [
        (builtins.readFile "${inputs.betterfox}/Securefox.js")
        (builtins.readFile "${inputs.betterfox}/Fastfox.js")
        (builtins.readFile "${inputs.betterfox}/Peskyfox.js")
        # Override the previous user.js (later lines get priority)
        ''
          user_pref("browser.search.suggest.enabled", true);
          user_pref("browser.search.suggest.enabled.private", true);
          user_pref("browser.urlbar.suggest.searches", true);
        ''
      ];

      settings = {
        # General
        "intl.accept_languages" = "en-US,en";
        "browser.startup.page" = 0; # Open blank page on start-up
        "browser.aboutConfig.showWarning" = false; # I sometimes know what I'm doing
        "browser.ctrlTab.sortByRecentlyUsed" = false; # (default) Who wants that?
        "browser.download.useDownloadDir" = false; # Ask where to save stuff
        "privacy.clearOnShutdown.history" = false; # We want to save history on exit
        # Hi-DPI
        "layout.css.devPixelsPerPx" = "-1";

        # Allow executing JS in the dev console
        "devtools.chrome.enabled" = true;
        # Disable browser crash reporting
        "browser.tabs.crashReporting.sendReport" = false;
        # Allow userCrome.css
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        # Why the fuck can my search window make bell sounds
        "accessibility.typeaheadfind.enablesound" = false;
        # Why the fuck can my search window make bell sounds
        "general.autoScroll" = true;

        # Hardware acceleration
        # See https://github.com/elFarto/nvidia-vaapi-driver?tab=readme-ov-file#firefox
        "gfx.webrender.all" = true;
        "media.ffmpeg.vaapi.enabled" = true;
        "media.rdd-ffmpeg.enabled" = true;
        "widget.dmabuf.force-enabled" = true;
        "media.av1.enabled" = false; # XXX: change once I've upgraded my GPU
        # XXX: what is this?
        "media.ffvpx.enabled" = false;
        "media.rdd-vpx.enabled" = false;

        # Privacy
        "privacy.donottrackheader.enabled" = true;
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "privacy.userContext.enabled" = true;
        "privacy.userContext.ui.enabled" = true;

        "browser.send_pings" = false; # (default) Don't respect <a ping=...>

        # This allows firefox devs changing options for a small amount of users to test out stuff.
        # Not with me please ...
        "app.normandy.enabled" = false;
        "app.shield.optoutstudies.enabled" = false;

        "beacon.enabled" = false; # No bluetooth location BS in my webbrowser please
        "device.sensors.enabled" = false; # This isn't a phone
        "geo.enabled" = false; # Disable geolocation alltogether

        # ESNI is deprecated ECH is recommended
        "network.dns.echconfig.enabled" = true;

        # Disable telemetry for privacy reasons
        "toolkit.telemetry.archive.enabled" = false;
        "toolkit.telemetry.enabled" = false; # enforced by nixos
        "toolkit.telemetry.server" = "";
        "toolkit.telemetry.unified" = false;
        "extensions.webcompat-reporter.enabled" = false; # don't report compability problems to mozilla
        "datareporting.policy.dataSubmissionEnabled" = false;
        "datareporting.healthreport.uploadEnabled" = false;
        "browser.ping-centre.telemetry" = false;
        "browser.urlbar.eventTelemetry.enabled" = false; # (default)

        # Disable some useless stuff
        "extensions.pocket.enabled" = false; # disable pocket, save links, send tabs
        "extensions.abuseReport.enabled" = false; # don't show 'report abuse' in extensions
        "identity.fxaccounts.enabled" = false; # disable firefox login
        "identity.fxaccounts.toolbar.enabled" = false;
        "identity.fxaccounts.pairing.enabled" = false;
        "identity.fxaccounts.commands.enabled" = false;
        "browser.contentblocking.report.lockwise.enabled" = false; # don't use firefox password manger
        "browser.uitour.enabled" = false; # no tutorial please

        # disable EME encrypted media extension (Providers can get DRM
        # through this if they include a decryption black-box program)
        "browser.eme.ui.enabled" = false;
        "media.eme.enabled" = false;

        # don't predict network requests
        # "network.predictor.enabled" = false;
        # "browser.urlbar.speculativeConnect.enabled" = false;

        # disable annoying web features
        "dom.push.enabled" = false; # no notifications, really...
        "dom.push.connection.enabled" = false;
        "dom.battery.enabled" = false; # you don't need to see my battery...

        # Gnome theme extension settings
        "gnomeTheme.hideSingleTab" = true;
        "gnomeTheme.bookmarksToolbarUnderTabs" = true;
        "gnomeTheme.normalWidthTabs" = false;
        "gnomeTheme.tabsAsHeaderbar" = false;
        "gnomeTheme.activeTabContrast" = true;
        "svg.context-properties.content.enabled" = true;

        "browser.toolbars.bookmarks.visibility" = false;
        "mousewheel.default.delta_multiplier_y" = 40;
        "mousewheel.default.delta_multiplier_x" = 20;

        "browser.sessionstore.resume_from_crash" = false; # Disable resuming from crash which requires frequent writes to disk

        # Cache to memory, disable cache to disk
        "browser.cache.memory.enable" = true;
        "browser.cache.disk.enable" = false;
        "browser.cache.disk_cache_ssl" = false;

        "browser.cache.memory.max_entry_size" = 51200;
        "browser.cache.memory.capacity" = 880640; # In kB

        "extensions.autoDisableScopes" = 0; # Don't auto disable extensions

        # REMOVE EVEN MORE CRUD

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
        "browser.urlbar.suggest.pocket" = false;
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

        browser.newtabpage.pinned = "[]";

        # OVERRIDE betterfox
        "browser.search.suggest.enabled" = true; #Enable live search suggestions
        "browser.urlbar.suggest.searches" = true;
        "services.sync.prefs.sync.browser.urlbar.showSearchSuggestionsFirst" = true;
        "browser.search.showOneOffButtons" = false;

        "browser.urlbar.autofill" = false;

        "browser.download.start_downloads_in_tmp_dir" = true;

        # Turn off auto updating since it is managed by Nix
        "extensions.update.autoUpdateDefault" = false;
        "extensions.update.enabled" = false;
        "services.sync.prefs.sync.extensions.update.enabled" = false;
        "app.update.auto" = false;
        "app.update.enabled" = false;
        "app.update.silent" = true;

        # Disable form autofill
        "signon.autofillForms" = false;
      };
    };
  };

  environment.persistence."/nix/state".users.waltmck = {
    directories = [
      ".mozilla" # Bookmarks, history, account, etc.

      # ".cache/mozilla/firefox" # Don't cache this, increase speed
    ];
  };

  home-manager.users.waltmck.xdg.mimeApps.defaultApplications = {
    "text/html" = ["firefox.desktop"];
    "text/xml" = ["firefox.desktop"];
    "x-scheme-handler/http" = ["firefox.desktop"];
    "x-scheme-handler/https" = ["firefox.desktop"];
  };
}
