{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = ["${inputs.home-manager}/nixos"];

  # environment.systemPackages = [pkgs.firefox];

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
      profiles.default = {
        name = "Default";
        settings = {
          "browser.tabs.loadInBackground" = true;
          "widget.gtk.rounded-bottom-corners.enabled" = true;
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          "svg.context-properties.content.enabled" = true;
          "gnomeTheme.hideSingleTab" = true;
          "gnomeTheme.bookmarksToolbarUnderTabs" = true;
          "gnomeTheme.normalWidthTabs" = false;
          "gnomeTheme.tabsAsHeaderbar" = false;
          "gnomeTheme.activeTabContrast" = true;
          "browser.toolbars.bookmarks.visibility" = false;
          "mousewheel.default.delta_multiplier_y" = 60;
          "mousewheel.default.delta_multiplier_x" = 30;
          "browser.formfill.enable" = false;
          "extensions.formautofill.creditCards.enabled" = false;
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
