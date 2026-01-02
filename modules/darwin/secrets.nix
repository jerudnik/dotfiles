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
    # Use primaryUser to support different users on different machines
    age = {
      keyFile = "/Users/${config.system.primaryUser}/.config/sops/age/yubikey-identity.txt";
      # Don't generate a new key - we're using Yubikey
      generateKey = false;
      # Disable SSH key paths - we only use Yubikey
      sshKeyPaths = [ ];
    };

    # Disable gnupg SSH key paths as well
    gnupg.sshKeyPaths = [ ];

    # Set environment for sops-install-secrets to find the age plugin and macOS binaries
    # Needs: hdiutil (/usr/bin), newfs_hfs (/sbin), mount (/sbin) for ramdisk secrets
    environment.PATH = lib.makeBinPath [ pkgs.age-plugin-yubikey ] + ":/usr/bin:/sbin";

    # Declare secrets to be decrypted
    secrets = {
      # OpenCode Zen API key
      # Decrypted to /run/secrets/api_keys/opencode_zen
      # Readable by primary user so it can be loaded into environment
      "api_keys/opencode_zen" = {
        owner = config.system.primaryUser;
        mode = "0400";
      };

      # GitHub Personal Access Token
      # Used by MCP github server
      # Decrypted to /run/secrets/api_keys/github_token
      "api_keys/github_token" = {
        owner = config.system.primaryUser;
        mode = "0400";
      };

      # Context7 API key (optional, for authenticated access)
      # Decrypted to /run/secrets/api_keys/context7
      "api_keys/context7" = {
        owner = config.system.primaryUser;
        mode = "0400";
      };

      # Exa API key for web search MCP server
      # Decrypted to /run/secrets/api_keys/exa
      "api_keys/exa" = {
        owner = config.system.primaryUser;
        mode = "0400";
      };

      # SSH authorized public keys
      # Decrypted to /run/secrets/ssh/
      # Used by sshd module for system-wide authorized_keys

      # Secretive key (Secure Enclave, Touch ID unlock) - interactive use
      "ssh/authorized_key_secretive" = {
        mode = "0444"; # World-readable (it's a public key)
      };

      # Builder key (passphraseless ed25519) - automated builds
      "ssh/authorized_key_builder" = {
        mode = "0444"; # World-readable (it's a public key)
      };

      # Legacy Yubikey key (kept for transition period)
      "ssh/authorized_key_yubikey" = {
        mode = "0444"; # World-readable (it's a public key)
      };
    };
  };

  # Ensure age-plugin-yubikey is available system-wide
  environment.systemPackages = with pkgs; [
    age-plugin-yubikey
  ];
}
