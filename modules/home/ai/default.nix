# AI tools configuration
# OpenCode TUI and related AI development tools
{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./mcp.nix
    ./agents.nix
    ./clients/opencode.nix
    ./environment.nix
    ./claude-desktop.nix
    ./skills.nix
  ];

  # Enable unified MCP configuration
  services.mcp.enable = true;
  services.mcp.enableClaudeDesktop = true;

  # Enable unified Agents configuration
  services.agents.enable = true;

  # Enable unified Skills configuration
  services.skills.enable = true;
  services.skills.enableOpenCode = true;
}
