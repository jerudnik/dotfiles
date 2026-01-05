# Common CLI tools and packages
# A sensible, minimal default set
{
  config,
  pkgs,
  lib,
  ...
}:

{
  home.packages = with pkgs; [
    # ============================================================
    # File & Directory Navigation
    # ============================================================
    eza # Modern ls replacement with icons and git integration
    fd # Simple, fast find alternative
    tree # Display directory structure
    zoxide # Smarter cd that learns your habits

    # ============================================================
    # Search & Filtering
    # ============================================================
    ripgrep # Fast grep alternative (rg)
    fzf # Fuzzy finder for everything

    # ============================================================
    # File Viewing & Processing
    # ============================================================
    bat # Cat with syntax highlighting and git integration
    jq # JSON processor
    yq # YAML processor

    # ============================================================
    # Development Tools
    # ============================================================
    opencode # AI coding assistant
    bun # Fast JavaScript runtime (for OpenCode custom tools)
    nodejs_20 # Provides node + npx for MCP npm servers (align with development.nix)
    direnv # Per-directory environment variables
    delta # Better git diffs with syntax highlighting
    marksman # Markdown language server (for OpenCode LSP)

    # ============================================================
    # System Monitoring
    # ============================================================
    btop # Beautiful system monitor (htop alternative)

    # ============================================================
    # Networking
    # ============================================================
    curl
    wget

    openssh # SSH client (replaces macOS built-in for consistency)

    # ============================================================
    # Security & Authentication
    # ============================================================
    bitwarden-desktop # Password manager with SSH Agent
    bitwarden-cli # Bitwarden CLI for chezmoi integration
    yubikey-manager # Yubikey management CLI (ykman) - still needed for sops-nix

    # ============================================================
    # Compression
    # ============================================================
    zip
    unzip
    p7zip

    # ============================================================
    # Nix Tools
    # ============================================================
    nix-output-monitor # Better nix build output (nom)
    nix-tree # Visualize nix derivations
    nixfmt-rfc-style # Nix formatter

    # ============================================================
    # Terminal Multiplexer
    # ============================================================
    tmux # Terminal multiplexer for persistent sessions

    # ============================================================
    # Miscellaneous
    # ============================================================
    tealdeer # Fast tldr client in Rust (simplified man pages)
    just # Modern make alternative
    chezmoi

  ];

  # Direnv integration with nix
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
