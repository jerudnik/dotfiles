# Shell environment for AI tools
{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Environment variables
  home.sessionVariables = {
    # Point sops to our Yubikey identity file
    SOPS_AGE_KEY_FILE = "${config.home.homeDirectory}/.config/sops/age/yubikey-identity.txt";

    # Ollama host (local server managed by darwin service)
    OLLAMA_HOST = "localhost:11434";
  };

  # Secrets are loaded via chezmoi Bitwarden templates (local.zsh.tmpl)
  programs.zsh.initContent = "";

  # Shell aliases for AI tools
  programs.zsh.shellAliases = {
    oc = "opencode";
    ai = "opencode run";
  };

  # Ensure MCP memory directory exists (matches mcp.nix default path)
  home.file."Utility/mcp-memory/.gitkeep".text = "";
}
