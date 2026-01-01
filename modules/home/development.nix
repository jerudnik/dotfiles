# Development runtimes and tools
# Python, Node.js, Rust environments
{
  config,
  pkgs,
  lib,
  ...
}:

{
  home.packages = with pkgs; [
    # ============================================================
    # Python
    # ============================================================
    python311
    python311Packages.pip

    # ============================================================
    # Rust
    # ============================================================
    rustup

    # ============================================================
    # Build Tools
    # ============================================================
    cmake
    gnumake
  ];

  # Rust environment
  home.sessionVariables = {
    RUSTUP_HOME = "${config.home.homeDirectory}/.rustup";
    CARGO_HOME = "${config.home.homeDirectory}/.cargo";
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/.cargo/bin"
  ];
}
