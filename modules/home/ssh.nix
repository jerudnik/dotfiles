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

  # Allowed signers file for SSH commit signature verification
  # Format: <email> <key-type> <public-key>
  home.file.".ssh/allowed_signers".text = ''
    john.rudnik@gmail.com sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIHznefm6tDTtpZFjCRDhDBR+CJD9mTE5OwhTE9LMSiy3AAAABHNzaDo=
  '';

  # GitHub known host key (prevents TOFU attacks)
  # From: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints
  home.file.".ssh/known_hosts".text = ''
    github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
    github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=
    github.com ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk=
  '';

  programs.ssh = {
    enable = true;

    # SSH host configurations
    matchBlocks = {
      # ============================================================
      # GitHub (SSH for git operations)
      # ============================================================
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = [ "~/.ssh/id_ed25519_sk" ];
        identitiesOnly = true;
        # Bypass macOS agent for FIDO2 keys - it doesn't handle touch properly
        extraOptions = {
          IdentityAgent = "none";
        };
      };

      # ============================================================
      # Mac Studio (seriousCallersOnly)
      # ============================================================

      # Primary: Tailscale MagicDNS
      "seriousCallersOnly" = {
        hostname = "seriousCallersOnly";
        user = "john";
        identityFile = [ "~/.ssh/id_ed25519_sk" ];
        identitiesOnly = true;
        extraOptions = {
          IdentityAgent = "none";
        };
      };

      # Fallback: Local network (mDNS/Bonjour)
      "seriousCallersOnly.local" = {
        hostname = "seriousCallersOnly.local";
        user = "john";
        identityFile = [ "~/.ssh/id_ed25519_sk" ];
        identitiesOnly = true;
        extraOptions = {
          IdentityAgent = "none";
        };
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
        extraOptions = {
          IdentityAgent = "none";
        };
      };

      # Fallback: Local network (mDNS/Bonjour)
      "inOneEar.local" = {
        hostname = "inOneEar.local";
        user = "jrudnik";
        identityFile = [ "~/.ssh/id_ed25519_sk" ];
        identitiesOnly = true;
        extraOptions = {
          IdentityAgent = "none";
        };
      };

      # ============================================================
      # Pixelbook (sleeper-service) - NixOS
      # ============================================================

      # Primary: Tailscale MagicDNS
      "sleeper-service" = {
        hostname = "sleeper-service";
        user = "john";
        identityFile = [ "~/.ssh/id_ed25519_sk" ];
        identitiesOnly = true;
        extraOptions = {
          IdentityAgent = "none";
        };
      };

      # Fallback: Local network (mDNS/Avahi)
      "sleeper-service.local" = {
        hostname = "sleeper-service.local";
        user = "john";
        identityFile = [ "~/.ssh/id_ed25519_sk" ];
        identitiesOnly = true;
        extraOptions = {
          IdentityAgent = "none";
        };
      };
    };

    # Global SSH settings
    extraConfig = ''
      # Note: AddKeysToAgent and UseKeychain are intentionally omitted
      # FIDO2/Yubikey keys use IdentityAgent=none per-host to bypass
      # the macOS agent which doesn't handle touch prompts properly
    '';
  };
}
