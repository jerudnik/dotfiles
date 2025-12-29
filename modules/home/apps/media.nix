# Media viewing and management
# MPV: Powerful, cross-platform media player
# uosc: Modern on-screen controller for MPV
{
  config,
  pkgs,
  lib,
  ...
}:

{
  # ============================================================
  # MPV - Media player
  # ============================================================
  programs.mpv = {
    enable = true;

    # Scripts
    scripts = with pkgs.mpvScripts; [
      uosc # Modern, feature-rich on-screen controller
      thumbfast # High-performance thumbnail generator for uosc
    ];

    # Configuration
    config = {
      # General
      keep-open = true; # Don't close after playback
      save-position-on-quit = true; # Remember playback position

      # Video
      vo = "gpu-next"; # Modern video output
      hwdec = "auto-safe"; # Hardware decoding

      # Audio
      volume-max = 150;

      # Subtitles
      sub-auto = "fuzzy"; # Load subtitles with similar names
      sub-font-size = 40;

      # Screenshots
      screenshot-format = "png";
      screenshot-directory = "~/Pictures/Screenshots";

      # OSD (disabled since uosc handles this)
      osd-bar = false;
      border = false;
    };

    # Script options
    scriptOpts = {
      uosc = {
        # Show timeline on hover
        timeline_persistency = "paused,audio";
        # Progress bar style
        progress = "windowed";
        progress_size = 2;
        progress_line_width = 2;
      };

      thumbfast = {
        spawn_first = true;
        network = true;
      };
    };
  };
}
