# Claude Desktop preferences configuration
{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.services.claudeDesktop;
in
{
  options.services.claudeDesktop = {
    preferences = {
      menuBarEnabled = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Claude Desktop menu bar";
      };

      quickEntryShortcut = lib.mkOption {
        type = lib.types.str;
        default = "off";
        description = "Keyboard shortcut for quick entry (e.g., 'cmd+shift+c' or 'off')";
      };
    };
  };
}
