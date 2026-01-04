{
  config,
  lib,
  pkgs,
  ...
}:
let
  colors = config.lib.stylix.colors;
  # Build color object manually since withHashtag returns a derivation path
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
in
{
  xdg.configFile."chezmoi/chezmoidata.json".text = builtins.toJSON {
    stylix = colorSet;
    font = {
      monospace = config.stylix.fonts.monospace.name;
      size = config.stylix.fonts.sizes.terminal;
    };
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
    secrets = {
      # Only include secrets that actually exist in secrets.nix
      opencodeZenKey = "/run/secrets/api_keys/opencode_zen";
      githubToken = "/run/secrets/api_keys/github_token";
      context7Key = "/run/secrets/api_keys/context7";
      exaKey = "/run/secrets/api_keys/exa";
      atuinKey = "/run/secrets/atuin/key";
    };
  };
}
