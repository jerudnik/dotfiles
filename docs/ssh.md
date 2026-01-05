# SSH Configuration

Need-to-know guide for this repo's SSH setup on macOS (nix-darwin) and NixOS.

## Overview

| Component              | macOS                       | NixOS                       |
| ---------------------- | --------------------------- | --------------------------- |
| **Interactive SSH**    | Bitwarden SSH Agent         | Regular ed25519 or Yubikey  |
| **Automated builds**   | `~/.ssh/id_ed25519_builder` | `~/.ssh/id_ed25519_builder` |
| **Secrets encryption** | sops-nix (boot-time only)   | Host age key (sops-nix)     |
| **Server**             | sshd via nix-darwin         | sshd via NixOS              |

## Key Strategy

```
┌─────────────────────────────────────────────────────────────┐
│                    SSH Key Architecture                     │
├─────────────────────────────────────────────────────────────┤
│ Interactive Use (macOS):                                    │
│   Bitwarden SSH Agent → Secure Vault → biometric unlock     │
│   - GitHub, remote hosts, git signing                       │
│   - Cloud-synced across devices                             │
│   - Each Mac gets its own key                               │
│   - Socket: ~/.bitwarden-ssh-agent.sock                     │
│                                                             │
│ Interactive Use (Linux):                                    │
│   Regular ed25519 or Yubikey FIDO2                          │
│   - Stored in ~/.ssh/id_ed25519                             │
│                                                             │
│ Automated Builds (all platforms):                           │
│   ~/.ssh/id_ed25519_builder → passphraseless                │
│   - Remote nix builds, CI, scripts                          │
│   - Same key can be copied across machines                  │
│   - IdentityAgent = none (no agent)                          │
│                                                             │
│ Secrets Encryption:                                         │
│   Boot-time only (Harmonia cache signing): sops-nix          │
│   macOS: age-plugin-yubikey → sops-nix                      │
│   NixOS: host-derived age key → sops-nix                    │
└─────────────────────────────────────────────────────────────┘
```

## First-Time Setup

An activation script runs on every `darwin-rebuild switch` to check your SSH key setup. If keys are missing, it will print setup instructions.

### macOS (Bitwarden SSH Agent)

1. **Open Bitwarden Desktop** from `/Applications`
2. **Enable SSH Agent**:
   - Settings → SSH Agent → Enable "Enable SSH Agent"
   - Set socket path to `~/.bitwarden-ssh-agent.sock`
3. **Create an SSH key in Bitwarden**:
   - Create a new item type "SSH Key" in Bitwarden
   - One key per host (e.g., "serious-callers-only SSH Key", "just-testing SSH Key")
   - Add public key to GitHub: https://github.com/settings/ssh/new (both authentication AND signing)
4. **Export public key** for remote host access:
   ```bash
   # Bitwarden SSH Agent provides keys to SSH client
   # No need to export manually - just add to secrets for authorized_keys
   ssh-add -L  # Show public keys offered by agent
   ```
5. **Add to secrets** for remote host access:
   ```bash
   ssh-add -L  # Copy the key for your host
   sops secrets/secrets.yaml  # Add to ssh/authorized_key_bitwarden_<hostname>
   ```

### macOS (Builder Key)

For automated builds (Task A):

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_builder -N "" -C "builder@$(hostname)"
```

### Linux (NixOS)

Generate a regular ed25519 key:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -C "user@hostname"
```

## Server Configuration

### macOS (nix-darwin)

Enable in host config (e.g., `hosts/serious-callers-only/default.nix`):

```nix
services.sshd = {
  enable = true;
  authorizedKeysFiles = [
    config.sops.secrets."ssh/authorized_key_bitwarden_serious-callers-only".path
    config.sops.secrets."ssh/authorized_key_bitwarden_just-testing".path
    config.sops.secrets."ssh/authorized_key_builder".path
    config.sops.secrets."ssh/authorized_key_yubikey".path
  ];
  passwordAuthentication = false;
  permitRootLogin = "no";
};
```

### NixOS

Standard NixOS sshd configuration applies.

## Client Configuration

Location: `modules/home/ssh.nix`

Key features:

- Bitwarden SSH Agent socket set via `SSH_AUTH_SOCK` environment variable
- Per-host matchBlocks for: `serious-callers-only`, `just-testing`, `sleeper-service`
- Builder-specific hosts (`*-builder`) use passphraseless key for automation
- Git signing configured via chezmoi (`chezmoi/dot_gitconfig.tmpl`)

## Secrets Structure

```yaml
# secrets/secrets.yaml
ssh:
  authorized_key_bitwarden_serious-callers-only: "ssh-ed25519 AAAA... serious-callers-only"
  authorized_key_bitwarden_just-testing: "ssh-ed25519 AAAA... just-testing"
  authorized_key_builder: "ssh-ed25519 AAAA... builder@host"
  # Note: Yubikey keys are managed separately per host
```

Declared in `modules/darwin/secrets.nix`:

```nix
sops.secrets."ssh/authorized_key_bitwarden_serious-callers-only" = { mode = "0444"; };
sops.secrets."ssh/authorized_key_bitwarden_just-testing" = { mode = "0444"; };
sops.secrets."ssh/authorized_key_builder" = { mode = "0444"; };
sops.secrets."ssh/authorized_key_yubikey" = { mode = "0444"; };
```

## Connecting

```bash
# Interactive (uses Bitwarden SSH Agent on macOS)
ssh serious-callers-only
ssh just-testing
ssh sleeper-service
ssh github.com

# Automated (uses builder key)
ssh serious-callers-only-builder
ssh just-testing-builder
```

## Troubleshooting

### SSH not using Bitwarden

```bash
# Check agent socket
echo $SSH_AUTH_SOCK
# Should be: ~/.bitwarden-ssh-agent.sock

# If wrong, restart terminal or:
export SSH_AUTH_SOCK=~/.bitwarden-ssh-agent.sock

# Verify agent has keys
ssh-add -l
```

### Permission denied (publickey)

1. Check if your public key is on GitHub / remote host
2. Verify Bitwarden SSH Agent is enabled: Settings → SSH Agent
3. Check correct key is in agent: `ssh-add -L`
4. Verify secrets deployed: `sudo cat /run/secrets/ssh/authorized_key_bitwarden_*`

### Bitwarden SSH Agent not working

```bash
# Check socket exists
ls -la ~/.bitwarden-ssh-agent.sock

# Check Bitwarden is running
ps aux | grep -i bitwarden

# Restart Bitwarden Desktop and re-enable SSH Agent
```

### Multiple Bitwarden keys

If you have multiple SSH keys in Bitwarden, check which one is being used:

```bash
# Check which keys agent is offering
ssh-add -L

# Compare fingerprints with GitHub or remote host
ssh-keygen -lf <(echo "ssh-ed25519 AAAA...")
```

### Git signing fails

```bash
# Ensure SSH_AUTH_SOCK is set to Bitwarden socket
export SSH_AUTH_SOCK=~/.bitwarden-ssh-agent.sock

# Test signing (use public key from Bitwarden agent)
ssh-add -L | head -1 > /tmp/signing-key.pub
echo "test" | ssh-keygen -Y sign -f /tmp/signing-key.pub -n git
```

## Adding a New Machine

1. Apply the configuration and set up Bitwarden SSH Agent (macOS) or SSH (Linux)
2. Follow the activation script prompts
3. Add the new public key to `secrets/secrets.yaml`
4. Add the new public key to GitHub (if needed)
5. Apply on all machines to distribute the new authorized key

## References

- Client: `modules/home/ssh.nix`
- Server: `modules/darwin/services/sshd.nix`
- Secrets: `secrets/secrets.yaml`, `modules/{darwin,nixos}/secrets.nix`
- Git signing: `modules/home/git.nix`
- Automation and builder key usage: `docs/automation.md`
- Bitwarden setup: `docs/ai-tools-setup.md`
