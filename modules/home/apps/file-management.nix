# File management utilities
# Yazi: Blazing fast terminal file manager
{
  config,
  pkgs,
  lib,
  ...
}:

{
  # ============================================================
  # Yazi - Terminal file manager
  # ============================================================
  programs.yazi = {
    enable = true;

    # Enable shell integrations
    enableZshIntegration = true;

    # Basic settings
    settings = {
      manager = {
        show_hidden = false;
        sort_by = "mtime";
        sort_dir_first = true;
        sort_reverse = true;
      };

      preview = {
        # Max file size to preview (in bytes)
        max_size = 10485760; # 10MB
      };
    };

    # Keybindings can be customized here
    # keymap = { };

    # Theme follows system (Stylix will handle this if enabled)
  };
}
