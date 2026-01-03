# SSH Configuration

Need-to-know guide for this repo's SSH setup on macOS (nix-darwin) and NixOS.

## Overview

| Component | macOS | NixOS |
|-----------|-------|-------|
| **Interactive SSH** | Secretive (Secure Enclave) | Regular ed25519 or Yubikey |
| **Automated builds** | `~/.ssh/id_ed25519_builder` | `~/.ssh/id_ed25519_builder` |
| **Secrets encryption** | age-plugin-yubikey (sops-nix) | Host age key (sops-nix) |
| **Server** | sshd via nix-darwin | sshd via NixOS |

## Key Strategy

```
┌─────────────────────────────────────────────────────────────┐
│                    SSH Key Architecture                     │
├─────────────────────────────────────────────────────────────┤
│ Interactive Use (macOS):                                    │
│   Secretive → Secure Enclave → password unlock              │
│   - GitHub, remote hosts, git signing                       │
│   - Hardware-bound, cannot be exported                      │
│   - Each Mac needs its own key                              │
│                                                             │
│ Interactive Use (Linux):                                    │
│   Regular ed25519 or Yubikey FIDO2                          │
│   - Stored in ~/.ssh/id_ed25519                             │
│                                                             │
│ Automated Builds (all platforms):                           │
│   ~/.ssh/id_ed25519_builder → passphraseless                │
│   - Remote nix builds, CI, scripts                          │
│   - Same key can be copied across machines                  │
│                                                             │
│ Secrets Encryption:                                         │
│   macOS: age-plugin-yubikey → sops-nix                      │
│   NixOS: host-derived age key → sops-nix                    │
└─────────────────────────────────────────────────────────────┘
```

## First-Time Setup

An activation script runs on every `darwin-rebuild switch` or `home-manager switch` to check your SSH key setup. If keys are missing, it will print setup instructions.

### macOS (Secretive)

1. **Open Secretive.app** from `/Applications`
2. **Create a new key** in Secure Enclave
3. **Create the symlink** (one time, persists across rebuilds):
   ```bash
   # Find your key hash
   ls ~/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/PublicKeys/
   
   # Create symlink (replace HASH with your key's hash)
   ln -sf ~/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/PublicKeys/HASH.pub ~/.ssh/secretive.pub
   ```
4. **Add to GitHub**: https://github.com/settings/ssh/new (both authentication AND signing)
5. **Add to secrets** for remote host access:
   ```bash
   cat ~/.ssh/secretive.pub  # copy this
   sops secrets/secrets.yaml  # add to ssh/authorized_key_secretive
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
    config.sops.secrets."ssh/authorized_key_secretive".path
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
- Secretive agent socket set via `SSH_AUTH_SOCK` environment variable
- Per-host matchBlocks for: `serious-callers-only`, `just-testing`, `sleeper-service`
- Builder-specific hosts (`*-builder`) use passphraseless key for automation
- Git signing configured via `modules/home/git.nix`

## Secrets Structure

```yaml
# secrets/secrets.yaml
ssh:
  authorized_key_secretive: 'ecdsa-sha2-nistp256 AAAA... user@host'
  authorized_key_builder: 'ssh-ed25519 AAAA... builder@host'
  authorized_key_yubikey: 'sk-ssh-ed25519@openssh.com AAAA... user@host'
```

Declared in `modules/darwin/secrets.nix`:
```nix
sops.secrets."ssh/authorized_key_secretive" = { mode = "0444"; };
sops.secrets."ssh/authorized_key_builder" = { mode = "0444"; };
sops.secrets."ssh/authorized_key_yubikey" = { mode = "0444"; };
```

## Connecting

```bash
# Interactive (uses Secretive on macOS)
ssh serious-callers-only
ssh just-testing
ssh sleeper-service
ssh github.com

# Automated (uses builder key)
ssh serious-callers-only-builder
ssh just-testing-builder
```

## Troubleshooting

### SSH not using Secretive
```bash
# Check agent socket
echo $SSH_AUTH_SOCK
# Should be: ~/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh

# If wrong, restart terminal or:
export SSH_AUTH_SOCK=~/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh

# Verify agent has keys
ssh-add -l
```

### Permission denied (publickey)
1. Check if your public key is on GitHub / remote host
2. Verify symlink exists: `ls -la ~/.ssh/secretive.pub`
3. Check correct key is in agent: `ssh-add -L`
4. Verify secrets deployed: `sudo cat /run/secrets/ssh/authorized_key_secretive`

### Secretive not in Applications
Secretive must be in `/Applications` to access Secure Enclave. It's installed via Homebrew cask, not nixpkgs.

### Multiple Secretive keys
If you have multiple keys, ensure the symlink points to the correct one:
```bash
# List all keys
ls ~/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/PublicKeys/

# Check which key agent is offering
ssh-add -L

# Compare fingerprints
ssh-keygen -lf ~/.ssh/secretive.pub
```

### Git signing fails
```bash
# Ensure SSH_AUTH_SOCK is set
export SSH_AUTH_SOCK=~/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh

# Test signing
echo "test" | ssh-keygen -Y sign -f ~/.ssh/secretive.pub -n git
```

## Adding a New Machine

1. Apply the configuration to install Secretive (macOS) or SSH (Linux)
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
