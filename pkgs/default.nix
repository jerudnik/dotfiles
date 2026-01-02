# Custom packages
# Define custom packages that aren't in nixpkgs
#
# To use these packages:
# 1. Import this file in your configuration
# 2. Reference packages via pkgs.myCustomPkg
#
# Or use via overlay (see overlays/default.nix)

{ pkgs }:

{
  # ============================================================
  # Custom Packages
  # ============================================================

  phosphor-icons = pkgs.callPackage ./phosphor-icons.nix { };

  # ============================================================
  # MCP Servers
  # ============================================================

  # grep.app MCP server for GitHub code search
  grep-mcp = pkgs.callPackage ./grep-mcp.nix { };
}
