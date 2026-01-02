# Ghostty terminal configuration
# Ghostty is installed via Homebrew cask (modules/darwin/homebrew.nix)
{
  config,
  pkgs,
  lib,
  ...
}:

{
  programs.ghostty = {
    enable = true;
    package = lib.mkDefault (if pkgs.stdenv.hostPlatform.isDarwin then null else pkgs.ghostty);
    enableZshIntegration = true;
    settings = {
      font-family = "iA Writer Mono";
      font-family-bold = "iA Writer Mono";
      font-family-italic = "iA Writer Mono";
      font-family-bold-italic = "iA Writer Mono";
      font-size = 13;
      font-thicken = true;
      window-padding-x = 10;
      window-padding-y = 10;
      window-decoration = true;
      macos-titlebar-style = "tabs";
      cursor-style = "block";
      cursor-style-blink = false;
      mouse-hide-while-typing = true;
      copy-on-select = true;
      shell-integration = "zsh";
      shell-integration-features = "cursor,sudo,title";
      scrollback-limit = 100000;
      clipboard-read = "allow";
      clipboard-write = "allow";
      keybind = [
        # Split panes
        "cmd+d=new_split:right"
        "cmd+shift+d=new_split:down"
        # Navigate panes
        "cmd+alt+left=goto_split:left"
        "cmd+alt+right=goto_split:right"
        "cmd+alt+up=goto_split:up"
        "cmd+alt+down=goto_split:down"
        # Tabs (platform-neutral via ctrl for numbering)
        "cmd+t=new_tab"
        "cmd+w=close_surface"
        "cmd+shift+]=next_tab"
        "cmd+shift+[=previous_tab"
        "ctrl+one=goto_tab:1"
        "ctrl+two=goto_tab:2"
        "ctrl+three=goto_tab:3"
        # Font size
        "cmd+plus=increase_font_size:1"
        "cmd+minus=decrease_font_size:1"
        "cmd+0=reset_font_size"
        # Quick actions
        "cmd+shift+enter=toggle_fullscreen"
      ];
    };
  };
}
