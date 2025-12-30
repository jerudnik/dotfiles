# SSH client configuration
# Configures SSH hosts for cross-machine access
# Uses Yubikey-backed ed25519-sk keys for authentication
{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Ensure Nix openssh is in PATH before /usr/bin/ssh (macOS built-in lacks FIDO2)
  home.sessionPath = [ "${pkgs.openssh}/bin" ];

  programs.ssh = {
    enable = true;

    # SSH host configurations
    matchBlocks = {
      # ============================================================
      # Mac Studio (seriousCallersOnly)
      # ============================================================

      # Primary: Tailscale MagicDNS
      "seriousCallersOnly" = {
        hostname = "seriousCallersOnly";
        user = "john";
        identityFile = [ "~/.ssh/id_ed25519_sk" ];
        identitiesOnly = true;
      };

      # Fallback: Local network (mDNS/Bonjour)
      "seriousCallersOnly.local" = {
        hostname = "seriousCallersOnly.local";
        user = "john";
        identityFile = [ "~/.ssh/id_ed25519_sk" ];
        identitiesOnly = true;
      };

      # ============================================================
      # MacBook Air (inOneEar)
      # ============================================================

      # Primary: Tailscale MagicDNS
      "inOneEar" = {
        hostname = "inOneEar";
        user = "jrudnik";
        identityFile = [ "~/.ssh/id_ed25519_sk" ];
        identitiesOnly = true;
      };

      # Fallback: Local network (mDNS/Bonjour)
      "inOneEar.local" = {
        hostname = "inOneEar.local";
        user = "jrudnik";
        identityFile = [ "~/.ssh/id_ed25519_sk" ];
        identitiesOnly = true;
      };
    };

    # Global SSH settings
    extraConfig = ''
      # Add keys to agent automatically
      AddKeysToAgent yes

      # Use Keychain on macOS for passphrase storage
      IgnoreUnknown UseKeychain
      UseKeychain yes
    '';
  };
}
