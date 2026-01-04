# SSH client configuration
# Configures SSH hosts for cross-machine access
# Uses Bitwarden SSH Agent for interactive SSH, builder key for automation
{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Ensure Nix openssh is in PATH before /usr/bin/ssh (for consistency)
  home.sessionPath = [ "${pkgs.openssh}/bin" ];

  # Allowed signers file for SSH commit signature verification
  # Format: <email> <key-type> <public-key>
  # Bitwarden SSH key for current signing, plus old keys for historical verification
  home.file.".ssh/allowed_signers".text = ''
    john.rudnik@gmail.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHUET4JHxbky06pOvg0gCE39iTt8X5aeulQPliJoq8Y6 just-testing
    john.rudnik@gmail.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBDxpgRd18pcrQEikg/tY2D9RN2ASY8SS2WBqIPkTWNEsBrN+GAPnNnxPpOweKZFZCByLEBMKH2RJRTfGtuwfVig=
    john.rudnik@gmail.com sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIHznefm6tDTtpZFjCRDhDBR+CJD9mTE5OwhTE9LMSiy3AAAABHNzaDo=
  '';

  # Export Bitwarden public key to file for git signing
  home.file.".ssh/bitwarden.pub".text = ''
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHUET4JHxbky06pOvg0gCE39iTt8X5aeulQPliJoq8Y6 just-testing
  '';

  # GitHub known host keys (prevents TOFU attacks)
  # From: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints
  # SSH uses ~/.ssh/known_hosts by default; we seed it via activation script below

  # ==========================================================================
  # SSH Key Setup Helper
  # Runs on activation to ensure SSH keys are properly configured
  # ==========================================================================
  home.activation.sshKeySetup = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    SSH_DIR="$HOME/.ssh"
    mkdir -p "$SSH_DIR"

    # Detect platform
    if [[ "$(uname)" == "Darwin" ]]; then
      # =======================================================================
      # macOS: Check for Bitwarden SSH Agent setup
      # =======================================================================
      BITWARDEN_SOCKET="$HOME/.bitwarden-ssh-agent.sock"
      
      if [[ ! -S "$BITWARDEN_SOCKET" ]]; then
        echo ""
        echo "╔══════════════════════════════════════════════════════════════════╗"
        echo "║  BITWARDEN SSH AGENT NOT RUNNING                                 ║"
        echo "╠══════════════════════════════════════════════════════════════════╣"
        echo "║  Bitwarden SSH agent socket not found.                           ║"
        echo "║                                                                  ║"
        echo "║  Please:                                                         ║"
        echo "║    1. Open Bitwarden Desktop                                     ║"
        echo "║    2. Settings > SSH Agent > Enable SSH Agent                    ║"
        echo "║    3. Add an SSH key in Bitwarden                                ║"
        echo "║    4. Unlock Bitwarden to activate the agent                     ║"
        echo "╚══════════════════════════════════════════════════════════════════╝"
        echo ""
      fi
      
      # Check for builder key (still needed for automation)
      if [[ ! -f "$SSH_DIR/id_ed25519_builder" ]]; then
        echo ""
        echo "╔══════════════════════════════════════════════════════════════════╗"
        echo "║  BUILDER KEY NOT FOUND                                           ║"
        echo "╠══════════════════════════════════════════════════════════════════╣"
        echo "║  The automated builder key is missing.                           ║"
        echo "║                                                                  ║"
        echo "║  To generate (passphraseless for automation):                    ║"
        echo "║    ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_builder -N \"\" -C \"builder@\$HOSTNAME\"" 
        echo "║                                                                  ║"
        echo "║  Then add the public key to remote hosts' authorized_keys.       ║"
        echo "╚══════════════════════════════════════════════════════════════════╝"
        echo ""
      fi
      
    else
      # =======================================================================
      # Linux: Check for SSH key setup
      # =======================================================================
      if [[ ! -f "$SSH_DIR/id_ed25519" ]] && [[ ! -f "$SSH_DIR/id_ed25519_builder" ]]; then
        echo ""
        echo "╔══════════════════════════════════════════════════════════════════╗"
        echo "║  SSH KEY SETUP REQUIRED (Linux)                                  ║"
        echo "╠══════════════════════════════════════════════════════════════════╣"
        echo "║  No SSH keys found.                                              ║"
        echo "║                                                                  ║"
        echo "║  Options:                                                        ║"
        echo "║    1. Regular key (simplest):                                    ║"
        echo "║       ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519                 ║"
        echo "║                                                                  ║"
        echo "║    2. Yubikey FIDO2 (if available):                              ║"
        echo "║       ssh-keygen -t ed25519-sk -f ~/.ssh/id_ed25519_sk           ║"
        echo "║                                                                  ║"
        echo "║  Then add the public key to:                                     ║"
        echo "║    1. GitHub (https://github.com/settings/ssh/new)               ║"
        echo "║    2. Remote hosts' authorized_keys                              ║"
        echo "╚══════════════════════════════════════════════════════════════════╝"
        echo ""
      fi
    fi
  '';

  # Seed known_hosts with GitHub keys on activation (not a symlink, so SSH can append)
  home.activation.seedKnownHosts = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        KNOWN_HOSTS="$HOME/.ssh/known_hosts"
        mkdir -p "$HOME/.ssh"
        
        # Only seed if file doesn't exist or is empty
        if [ ! -s "$KNOWN_HOSTS" ]; then
          cat > "$KNOWN_HOSTS" << 'EOF'
    github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
    github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=
    github.com ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk=
    EOF
          chmod 600 "$KNOWN_HOSTS"
        fi
  '';

  programs.ssh = {
    enable = true;

    # Disable auto-generated defaults (fixes deprecation warning)
    enableDefaultConfig = false;

    # SSH host configurations
    matchBlocks = {
      # ============================================================
      # Wildcard defaults - use Bitwarden SSH agent for all connections
      # ============================================================
      "*" = {
        extraOptions = {
          # Point to Bitwarden's SSH agent socket
          IdentityAgent = "~/.bitwarden-ssh-agent.sock";
          AddKeysToAgent = "yes";
        };
      };

      # ============================================================
      # GitHub (SSH for git operations)
      # ============================================================
      "github.com" = {
        hostname = "github.com";
        user = "git";
        # identitiesOnly requires explicit IdentityFile; use agent keys instead
      };

      # ============================================================
      # Mac Studio (serious-callers-only)
      # ============================================================

      # Primary: Tailscale MagicDNS
      "serious-callers-only" = {
        hostname = "serious-callers-only";
        user = "john";
        # Uses Bitwarden agent from wildcard
      };

      # Fallback: Local network (mDNS/Bonjour)
      "serious-callers-only.local" = {
        hostname = "serious-callers-only.local";
        user = "john";
      };

      # Builder alias: passphraseless key for automated builds (Task A)
      "serious-callers-only-builder" = {
        hostname = "serious-callers-only";
        user = "john";
        identityFile = [ "~/.ssh/id_ed25519_builder" ];
        identitiesOnly = true;
        extraOptions = {
          # Bypass Bitwarden agent for automated/non-interactive use
          IdentityAgent = "none";
        };
      };

      # ============================================================
      # MacBook Air (just-testing)
      # ============================================================

      # Primary: Tailscale MagicDNS
      "just-testing" = {
        hostname = "just-testing";
        user = "jrudnik";
      };

      # Fallback: Local network (mDNS/Bonjour)
      "just-testing.local" = {
        hostname = "just-testing.local";
        user = "jrudnik";
      };

      # Builder alias for automated builds
      "just-testing-builder" = {
        hostname = "just-testing";
        user = "jrudnik";
        identityFile = [ "~/.ssh/id_ed25519_builder" ];
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
      };

      # Fallback: Local network (mDNS/Avahi)
      "sleeper-service.local" = {
        hostname = "sleeper-service.local";
        user = "john";
      };

      # Builder alias for automated builds
      "sleeper-service-builder" = {
        hostname = "sleeper-service";
        user = "john";
        identityFile = [ "~/.ssh/id_ed25519_builder" ];
        identitiesOnly = true;
        extraOptions = {
          IdentityAgent = "none";
        };
      };
    };

    # Global SSH settings
    extraConfig = ''
      # Bitwarden Desktop handles key management via SSH Agent
      # Unlock Bitwarden to make keys available
      # Builder aliases use passphraseless keys for automation
    '';
  };
}
