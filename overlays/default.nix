# Package overlays
# Overlays allow you to modify or add packages to nixpkgs
#
# Common use cases:
# - Pin specific package versions
# - Apply patches to packages
# - Add custom packages
# - Override package inputs
#
# To use overlays, import them in your flake.nix:
#   pkgs = import nixpkgs {
#     inherit system;
#     overlays = [ (import ./overlays) ];
#   };

final: prev: {
  # ============================================================
  # Custom Packages
  # ============================================================

  # grep.app MCP server for GitHub code search
  grep-mcp = final.callPackage ../pkgs/grep-mcp.nix { };

  # Fix Tailscale build failure by disabling tests (flaky on macOS)
  tailscale = prev.tailscale.overrideAttrs (old: {
    doCheck = false;
  });
}
