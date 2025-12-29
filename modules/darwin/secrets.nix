# sops-nix secrets configuration
# Secrets are decrypted at system activation and placed in /run/secrets/
# Uses Yubikey-backed age keys via age-plugin-yubikey
{
  config,
  pkgs,
  lib,
  ...
}:

{
  # sops-nix configuration
  sops = {
    # Default encrypted secrets file
    defaultSopsFile = ../../secrets/secrets.yaml;

    # Age key configuration - Yubikey identity file
    age = {
      keyFile = "/Users/john/.config/sops/age/yubikey-identity.txt";
      # Don't generate a new key - we're using Yubikey
      generateKey = false;
      # Disable SSH key paths - we only use Yubikey
      sshKeyPaths = [ ];
    };

    # Disable gnupg SSH key paths as well
    gnupg.sshKeyPaths = [ ];

    # Set environment for sops-install-secrets to find the age plugin
    environment.PATH = lib.makeBinPath [ pkgs.age-plugin-yubikey ];

    # Declare secrets to be decrypted
    secrets = {
      # OpenCode Zen API key
      # Decrypted to /run/secrets/api_keys/opencode_zen
      # Readable by john so it can be loaded into environment
      "api_keys/opencode_zen" = {
        owner = "john";
        mode = "0400";
      };

      # GitHub Personal Access Token
      # Used by MCP github server
      # Decrypted to /run/secrets/api_keys/github_token
      "api_keys/github_token" = {
        owner = "john";
        mode = "0400";
      };

      # Context7 API key (optional, for authenticated access)
      # Decrypted to /run/secrets/api_keys/context7
      "api_keys/context7" = {
        owner = "john";
        mode = "0400";
      };

      # Exa API key for web search MCP server
      # Decrypted to /run/secrets/api_keys/exa
      "api_keys/exa" = {
        owner = "john";
        mode = "0400";
      };
    };
  };

  # Ensure age-plugin-yubikey is available system-wide
  environment.systemPackages = with pkgs; [
    age-plugin-yubikey
  ];
}
