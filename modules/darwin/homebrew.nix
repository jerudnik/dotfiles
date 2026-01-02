# Homebrew configuration for macOS
# Manages GUI applications (casks) and formulae not in nixpkgs
{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Enable Homebrew management through nix-darwin
  homebrew = {
    enable = true;

    # Behavior on activation
    onActivation = {
      # Remove formulae/casks not listed here
      cleanup = "zap";

      # Auto-update Homebrew itself
      autoUpdate = true;

      # Upgrade outdated packages
      upgrade = true;
    };

    # Homebrew taps (repositories)
    taps = [
      "d12frosted/emacs-plus" # Enhanced Emacs for macOS
    ];

    # CLI tools installed via Homebrew
    # (Prefer nixpkgs when available, use brew if a package isn't available for macOS)
    brews = [
      # Emacs - using emacs-plus for best macOS integration
      {
        name = "d12frosted/emacs-plus/emacs-plus@30";
        args = [
          "with-xwidgets" # embedded browser/widgets
          "with-imagemagick" # build with imagemagick support
          "with-debug" # build with debug symbols and debugger friendly optimizations
          "with-liquid-glass"
        ];
      }
    ];

    # GUI applications
    casks = [
      "ghostty"
      "secretive"
      "orbstack"
      "iina"
      "raycast"
      "claude"
      "helium-browser"
      "beeper"
    ];

    # Mac App Store apps (requires `mas` CLI)
    # Uncomment and add apps as needed:
    # masApps = {
    #   "App Name" = 123456789;  # App Store ID
    # };
  };
}
