# sops-nix secrets configuration for NixOS
# Secrets are decrypted at system activation and placed in /run/secrets/
# Uses age keys derived from SSH host keys (Yubikey not always available on NixOS)
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

    # Age key configuration
    # On NixOS, use SSH host key converted to age (doesn't require Yubikey)
    # Generate with: sudo cat /etc/ssh/ssh_host_ed25519_key | ssh-to-age
    age = {
      # Use system age key derived from SSH host key
      keyFile = "/var/lib/sops-nix/key.txt";
      # Don't generate a new key - admin must set up manually
      generateKey = false;
      # Optionally derive from SSH host key if keyFile doesn't exist
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    };

    # Disable gnupg
    gnupg.sshKeyPaths = [ ];

    # Declare secrets to be decrypted
    secrets = {
      # OpenCode Zen API key
      # Decrypted to /run/secrets/api_keys/opencode_zen
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

      # SSH authorized public key (Yubikey ed25519-sk)
      # Decrypted to /run/secrets/ssh/authorized_key
      # Used by sshd for authorized_keys
      "ssh/authorized_key" = {
        mode = "0444"; # World-readable (it's a public key)
      };
    };
  };

  # Ensure age and ssh-to-age are available for key management
  environment.systemPackages = with pkgs; [
    age
    ssh-to-age
    sops
  ];
}
