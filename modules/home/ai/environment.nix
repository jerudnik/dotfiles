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

  # Load secrets into environment at shell startup
  programs.zsh.initContent = ''
    # Load OpenCode API key from sops-decrypted secret
    if [[ -r /run/secrets/api_keys/opencode_zen ]]; then
      export OPENCODE_API_KEY="$(cat /run/secrets/api_keys/opencode_zen)"
    fi

    # Load GitHub Personal Access Token for MCP github server
    if [[ -r /run/secrets/api_keys/github_token ]]; then
      export GITHUB_PERSONAL_ACCESS_TOKEN="$(cat /run/secrets/api_keys/github_token)"
    fi

    # Load Context7 API key (optional, for authenticated access)
    if [[ -r /run/secrets/api_keys/context7 ]]; then
      export CONTEXT7_API_KEY="$(cat /run/secrets/api_keys/context7)"
    fi

    # Load Exa API key for web search MCP server
    if [[ -r /run/secrets/api_keys/exa ]]; then
      export EXA_API_KEY="$(cat /run/secrets/api_keys/exa)"
    fi
  '';

  # Shell aliases for AI tools
  programs.zsh.shellAliases = {
    oc = "opencode";
    ai = "opencode run";
  };

  # Ensure MCP memory directory exists
  home.file."Projects/mcp-memory/.gitkeep".text = "";
}
