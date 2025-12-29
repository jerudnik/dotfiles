# WezTerm terminal configuration
# GPU-accelerated, cross-platform terminal emulator
{
  config,
  pkgs,
  lib,
  ...
}:

{
  programs.wezterm = {
    enable = true;

    enableZshIntegration = true;

    # Lua configuration
    extraConfig = ''
      local wezterm = require("wezterm")
      local config = wezterm.config_builder()

      -- ============================================================
      -- Appearance
      -- ============================================================
      config.window_padding = {
        left = 10,
        right = 10,
        top = 10,
        bottom = 10,
      }

      config.window_decorations = "RESIZE"
      config.hide_tab_bar_if_only_one_tab = true
      config.use_fancy_tab_bar = false

      -- macOS-specific settings
      if wezterm.target_triple:find("darwin") then
        config.window_decorations = "RESIZE|MACOS_FORCE_ENABLE_SHADOW"
        config.macos_window_background_blur = 20
      end

      -- ============================================================
      -- Cursor
      -- ============================================================
      config.default_cursor_style = "SteadyBlock"
      config.cursor_blink_rate = 0

      -- ============================================================
      -- Scrollback
      -- ============================================================
      config.scrollback_lines = 100000

      -- ============================================================
      -- Key bindings (similar to Ghostty for consistency)
      -- ============================================================
      local act = wezterm.action

      config.keys = {
        -- Split panes
        { key = "d", mods = "CMD", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
        { key = "d", mods = "CMD|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

        -- Navigate panes
        { key = "LeftArrow", mods = "CMD|ALT", action = act.ActivatePaneDirection("Left") },
        { key = "RightArrow", mods = "CMD|ALT", action = act.ActivatePaneDirection("Right") },
        { key = "UpArrow", mods = "CMD|ALT", action = act.ActivatePaneDirection("Up") },
        { key = "DownArrow", mods = "CMD|ALT", action = act.ActivatePaneDirection("Down") },

        -- Tabs
        { key = "t", mods = "CMD", action = act.SpawnTab("CurrentPaneDomain") },
        { key = "w", mods = "CMD", action = act.CloseCurrentPane({ confirm = true }) },
        { key = "]", mods = "CMD|SHIFT", action = act.ActivateTabRelative(1) },
        { key = "[", mods = "CMD|SHIFT", action = act.ActivateTabRelative(-1) },

        -- Font size
        { key = "+", mods = "CMD", action = act.IncreaseFontSize },
        { key = "-", mods = "CMD", action = act.DecreaseFontSize },
        { key = "0", mods = "CMD", action = act.ResetFontSize },

        -- Fullscreen
        { key = "Enter", mods = "CMD|SHIFT", action = act.ToggleFullScreen },
      }

      -- ============================================================
      -- Mouse
      -- ============================================================
      config.hide_mouse_cursor_when_typing = true

      return config
    '';
  };
}
