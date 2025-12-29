# Python development and AI tools
# Package managers and environment tools
{
  config,
  pkgs,
  lib,
  ...
}:

{
  home.packages = with pkgs; [
    # ============================================================
    # Package Managers
    # ============================================================
    pipx
    uv
    poetry

    # ============================================================
    # Code Quality
    # ============================================================
    ruff
    black
  ];

  # Ensure pipx binaries are in PATH
  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin"
  ];
}
