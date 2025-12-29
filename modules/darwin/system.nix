# macOS System Preferences
# Organized to mirror System Settings panes
{
  config,
  pkgs,
  lib,
  ...
}:

{
  # ============================================================
  # NSGlobalDomain - Global macOS Settings
  # ============================================================
  system.defaults.NSGlobalDomain = {
    # --- Appearance ---
    # Appearance: Auto (follows system)
    AppleInterfaceStyleSwitchesAutomatically = true;

    # Sidebar icon size: Medium (1=small, 2=medium, 3=large)
    NSTableViewDefaultSizeMode = 2;

    # Show scroll bars: Automatic, WhenScrolling, Always
    AppleShowScrollBars = "Automatic";

    # Click in the scroll bar to: Jump to the spot that's clicked
    AppleScrollerPagingBehavior = true;

    # --- Keyboard ---
    # Key repeat rate (lower = faster, 2 is fast)
    KeyRepeat = 2;

    # Delay until repeat (lower = shorter delay, 15 is short)
    InitialKeyRepeat = 15;

    # Disable press-and-hold for keys (enables key repeat everywhere)
    ApplePressAndHoldEnabled = false;

    # --- Mouse & Trackpad ---
    # Natural scrolling (true = natural, false = traditional)
    "com.apple.swipescrolldirection" = true;

    # --- Text & Input ---
    # Disable smart quotes (annoying for coding)
    NSAutomaticQuoteSubstitutionEnabled = false;

    # Disable smart dashes (annoying for coding)
    NSAutomaticDashSubstitutionEnabled = false;

    # Disable auto-correct
    NSAutomaticSpellingCorrectionEnabled = false;

    # Disable automatic capitalization
    NSAutomaticCapitalizationEnabled = false;

    # Disable automatic period substitution
    NSAutomaticPeriodSubstitutionEnabled = false;

    # --- Panels & Dialogs ---
    # Expand save panel by default
    NSNavPanelExpandedStateForSaveMode = true;
    NSNavPanelExpandedStateForSaveMode2 = true;

    # Expand print panel by default
    PMPrintingExpandedStateForPrint = true;
    PMPrintingExpandedStateForPrint2 = true;

    # Save to disk (not iCloud) by default
    NSDocumentSaveNewDocumentsToCloud = false;

    # --- Miscellaneous ---
    # Enable subpixel font rendering on non-Apple LCDs
    AppleFontSmoothing = 1;
  };

  # ============================================================
  # Control Center
  # ============================================================
  system.defaults.controlcenter = {
    # Show battery percentage in menu bar
    BatteryShowPercentage = true;
  };

  # ============================================================
  # Desktop & Dock
  # ============================================================
  system.defaults.dock = {
    # Dock size
    tilesize = 48;

    # Magnification
    magnification = false;

    # Position on screen: bottom, left, right
    orientation = "bottom";

    # Minimize windows using: genie, scale, suck
    mineffect = "scale";

    # Minimize windows into application icon
    minimize-to-application = true;

    # Automatically hide and show the Dock
    autohide = true;

    # Auto-hide delay (0 = instant)
    autohide-delay = 0.0;

    # Auto-hide animation duration
    autohide-time-modifier = 0.4;

    # Animate opening applications
    launchanim = true;

    # Show indicators for open applications
    show-process-indicators = true;

    # Show recent applications in Dock
    show-recents = false;

    # Make Dock icons of hidden applications translucent
    showhidden = true;

    # Don't automatically rearrange Spaces based on most recent use
    mru-spaces = false;

    # Hot corners (1 = disabled)
    # Top-left
    wvous-tl-corner = 1;
    # Top-right
    wvous-tr-corner = 1;
    # Bottom-left
    wvous-bl-corner = 1;
    # Bottom-right
    wvous-br-corner = 1;
  };

  # ============================================================
  # Finder
  # ============================================================
  system.defaults.finder = {
    # Show all filename extensions
    AppleShowAllExtensions = true;

    # Show hidden files
    AppleShowAllFiles = true;

    # Show path bar at bottom
    ShowPathbar = true;

    # Show status bar at bottom
    ShowStatusBar = true;

    # Default view style: Nlsv=list, icnv=icon, clmv=column, Flwv=gallery
    FXPreferredViewStyle = "Nlsv";

    # Keep folders on top when sorting by name
    _FXSortFoldersFirst = true;

    # When performing a search: SCcf=current folder, SCev=this mac, SCsp=previous scope
    FXDefaultSearchScope = "SCcf";

    # Disable warning when changing file extension
    FXEnableExtensionChangeWarning = false;

    # Allow quitting Finder via Cmd+Q
    QuitMenuItem = true;
  };

  # ============================================================
  # Trackpad
  # ============================================================
  system.defaults.trackpad = {
    # Tap to click
    Clicking = true;

    # Three-finger drag
    TrackpadThreeFingerDrag = false;

    # Right-click with two fingers
    TrackpadRightClick = true;
  };

  # ============================================================
  # Screenshots
  # ============================================================
  system.defaults.screencapture = {
    # Save location
    location = "~/Screenshots";

    # Image format: png, jpg, gif, pdf, tiff
    type = "png";

    # Disable shadow in screenshots
    disable-shadow = true;
  };

  # ============================================================
  # Menu Bar Clock
  # ============================================================
  system.defaults.menuExtraClock = {
    # Show date in menu bar
    ShowDate = 1;

    # Show day of week
    ShowDayOfWeek = true;

    # Show seconds (0=no, 1=yes)
    ShowSeconds = false;
  };

  # ============================================================
  # Login Window
  # ============================================================
  system.defaults.loginwindow = {
    # Disable guest account
    GuestEnabled = false;

    # Show input menu in login window
    SHOWFULLNAME = false;
  };

  # ============================================================
  # Spaces
  # ============================================================
  system.defaults.spaces = {
    # Displays have separate Spaces
    spans-displays = false;
  };

  # ============================================================
  # Custom User Defaults (via defaults write)
  # ============================================================
  system.defaults.CustomUserPreferences = {
    # Finder settings
    "com.apple.finder" = {
      # Show full POSIX path in window title
      _FXShowPosixPathInTitle = true;
      # Desktop icon visibility
      ShowExternalHardDrivesOnDesktop = true;
      ShowHardDrivesOnDesktop = false;
      ShowMountedServersOnDesktop = true;
      ShowRemovableMediaOnDesktop = true;
    };

    # Disable disk image verification
    "com.apple.frameworks.diskimages" = {
      skip-verify = true;
      skip-verify-locked = true;
      skip-verify-remote = true;
    };

    # Avoid creating .DS_Store files on network or USB volumes
    "com.apple.desktopservices" = {
      DSDontWriteNetworkStores = true;
      DSDontWriteUSBStores = true;
    };

    # ============================================================
    # Keyboard Shortcuts - Disable Spotlight for Raycast
    # ============================================================
    # Disable Spotlight keyboard shortcuts to free up CMD+Space for Raycast
    # Hotkey IDs: 64 = Spotlight Search (CMD+Space), 65 = Spotlight Window
    # Reference: https://zameermanji.com/blog/2021/6/8/applying-com-apple-symbolichotkeys-changes-instantaneously/
    #
    # After changing these, Raycast should be configured:
    # 1. Open Raycast Settings > General > Raycast Hotkey > Set to CMD+Space
    # 2. Enable "Launch at Login" in Raycast Settings > General
    "com.apple.symbolichotkeys" = {
      AppleSymbolicHotKeys = {
        # Disable Spotlight Search (CMD+Space)
        "64" = {
          enabled = false;
        };
        # Disable Spotlight Window (CMD+Alt+Space)
        "65" = {
          enabled = false;
        };
      };
    };

    # Note: Safari settings removed - Safari is sandboxed and its preferences
    # cannot be modified via `defaults write`. Configure Safari manually in
    # Safari > Settings > Search > uncheck "Include search engine suggestions"
  };

  # ============================================================
  # Activation Script for Settings Not in nix-darwin
  # ============================================================
  system.activationScripts.extraActivation.text = ''
    # Create Screenshots directory if it doesn't exist
    sudo -u "$USER" mkdir -p ~/Screenshots 2>/dev/null || true
  '';

  # ============================================================
  # Post-Activation: Apply Keyboard Shortcut Changes
  # ============================================================
  # The symbolichotkeys changes require activateSettings to take effect
  # without a restart. This runs after defaults are written.
  system.activationScripts.postActivation.text = ''
    # Apply keyboard shortcut changes immediately (required for symbolichotkeys)
    # Without this, Spotlight shortcuts won't be disabled until next login
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';
}
