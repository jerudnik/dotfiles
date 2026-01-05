{
  config,
  lib,
  pkgs,
  ...
}:
let
  # Import modus theme for fallback when Stylix is disabled
  modusTheme = import ../../themes/modus.nix { inherit lib; };

  # Check if Stylix is enabled (handle both osConfig and direct config)
  stylixEnabled = config.stylix.enable or (config.osConfig.stylix.enable or false);

  # When Stylix enabled, use its colors; otherwise fallback to modus-vivendi
  colors = if stylixEnabled then config.lib.stylix.colors else modusTheme.vivendi;

  # Build color object with # prefix
  colorSet = builtins.listToAttrs (
    map
      (name: {
        inherit name;
        value = "#${colors.${name}}";
      })
      [
        "base00"
        "base01"
        "base02"
        "base03"
        "base04"
        "base05"
        "base06"
        "base07"
        "base08"
        "base09"
        "base0A"
        "base0B"
        "base0C"
        "base0D"
        "base0E"
        "base0F"
      ]
  );

  # Fallback font settings when Stylix is disabled
  fontSettings =
    if stylixEnabled then
      {
        monospace = config.stylix.fonts.monospace.name;
        size = config.stylix.fonts.sizes.terminal;
      }
    else
      {
        monospace = "iA Writer Mono";
        size = 14;
      };
in
{
  xdg.configFile."chezmoi/chezmoidata.json".text = builtins.toJSON {
    stylix = colorSet;
    font = fontSettings;
    hostname = config.osConfig.networking.hostName or "unknown";
    username = config.home.username;
    isLinux = pkgs.stdenv.isLinux;
    isDarwin = pkgs.stdenv.isDarwin;
    opencode_mcp_config = config.services.mcp.opencode;
    claude_config = config.services.mcp.claudeDesktopConfig;
    cursor_config = config.services.mcp.cursorConfig;
    tools = {
      git = lib.getExe pkgs.git;
      nix = lib.getExe pkgs.nix;
    };
  };
}
