# SSH Configuration with FIDO2 Yubikey Authentication

This document covers the SSH server and client configuration in this dotfiles repository, including hardened settings and Yubikey-backed FIDO2 authentication.

## Overview

The SSH setup provides:
- **Hardened SSH server** with pubkey-only authentication
- **FIDO2 Yubikey support** via resident ed25519-sk keys
- **Multi-machine configuration** for Mac Studio and MacBook Air
- **Tailscale integration** with local network fallbacks
- **sops-nix secret management** for authorized keys

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                       SSH Client (laptop)                      │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Nix openssh (/etc/profiles/per-user/john/bin/ssh)     │  │
│  │  - FIDO2 support (ed25519-sk)                           │  │
│  │  - Resident key: ~/.ssh/id_ed25519_sk                  │  │
│  │  - Config: modules/home/ssh.nix                         │  │
│  └──────────────────────────────────────────────────────────┘  │
│                              │                                  │
│         Tailscale VPN         │       mDNS/Bonjour             │
│                              │                                  │
│  ┌───────────────────────────▼──────────────────────────────┐  │
│  │              SSH Server (Mac Studio)                      │  │
│  │  ┌────────────────────────────────────────────────────┐ │  │
│  │  │  macOS sshd (Remote Login)                        │ │  │
│  │  │  - Hardened config (drop-in)                      │ │  │
│  │  │  - Authorized keys from sops secret               │ │  │
│  │  │  - Module: modules/darwin/services/sshd.nix       │ │  │
│  │  └────────────────────────────────────────────────────┘ │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

## Module Structure

```
modules/
├── darwin/
│   └── services/
│       └── sshd.nix         # SSH server configuration
├── home/
│   ├── ssh.nix              # SSH client configuration
│   └── packages.nix         # openssh + yubikey-manager
secrets/
└── secrets.yaml             # SSH authorized key (encrypted)
```

## SSH Server Configuration

### Module: `modules/darwin/services/sshd.nix`

Hardened SSH server service using macOS built-in sshd with a drop-in configuration.

#### Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | boolean | `false` | Enable SSH server (Remote Login) |
| `authorizedKeysFile` | path or null | `null` | Path to authorized keys file (typically from sops secret) |
| `passwordAuthentication` | boolean | `false` | Allow password authentication (not recommended) |
| `permitRootLogin` | enum | `"no"` | Root login setting: `"yes"`, `"no"`, `"prohibit-password"`, `"forced-commands-only"` |

#### Example Configuration

```nix
# In host config (e.g., hosts/mac-studio/default.nix)
services.sshd = {
  enable = true;
  authorizedKeysFile = config.sops.secrets."ssh/authorized_key".path;
  passwordAuthentication = false;
  permitRootLogin = "no";
};
```

#### Hardening Features

- Password authentication disabled by default
- Keyboard-interactive authentication disabled
- Pubkey authentication required
- Root login disabled
- System-wide authorized keys from sops secret

#### Activation

The module:
1. Enables macOS Remote Login via `systemsetup -setremotelogin on`
2. Creates drop-in config at `/etc/ssh/sshd_config.d/100-nix-managed.conf`
3. Populates `/etc/ssh/authorized_keys.d/<user>` from sops secret

## SSH Client Configuration

### Module: `modules/home/ssh.nix`

Configures SSH client with host match blocks for multi-machine access.

#### Features

- Prioritizes Nix openssh over macOS `/usr/bin/ssh` (macOS lacks FIDO2 support)
- Pre-configured host entries for Mac Studio and MacBook Air
- Tailscale MagicDNS as primary, mDNS/Bonjour `.local` as fallback
- Automatic key management with SSH agent integration

#### Host Configurations

| Host | User | Primary | Fallback | Identity |
|------|------|---------|----------|----------|
| `seriousCallersOnly` | `john` | `seriousCallersOnly` | `seriousCallersOnly.local` | `~/.ssh/id_ed25519_sk` |
| `inOneEar` | `jrudnik` | `inOneEar` | `inOneEar.local` | `~/.ssh/id_ed25519_sk` |

#### Session Path

```nix
# modules/home/ssh.nix
home.sessionPath = [ "${pkgs.openssh}/bin" ];
```

This ensures `/etc/profiles/per-user/john/bin/ssh` is found before `/usr/bin/ssh`.

#### Usage

```bash
# Connect to Mac Studio (uses Tailscale)
ssh seriousCallersOnly

# Connect via local network (fallback)
ssh seriousCallersOnly.local

# Connect to MacBook Air
ssh inOneEar
```

## FIDO2 Yubikey SSH Keys

### Why Yubikey FIDO2?

- **Hardware-bound**: Private key never leaves the Yubikey
- **Resident key**: No key file to manage; key stored in Yubikey hardware
- **Touch requirement**: Physical touch required for each authentication
- **Phishing resistant**: Key bound to specific domains (optional)

### Package Installation

```nix
# modules/home/packages.nix
home.packages = with pkgs; [
  openssh          # SSH client with FIDO2 support
  yubikey-manager  # Yubikey management CLI (ykman)
];
```

### Key Generation

**Note**: If you already have a resident key extracted to `~/.ssh/id_ed25519_sk`, you can skip this step.

```bash
# 1. Generate a FIDO2 resident key (ed25519-sk)
ssh-keygen -t ed25519-sk -f ~/.ssh/id_ed25519_sk -C "Yubikey FIDO2 key"

# 2. When prompted, touch your Yubikey
# 3. For resident keys, the key stays in the Yubikey hardware

# 4. Extract public key
cat ~/.ssh/id_ed25519_sk.pub
# Output: sk-ssh-ed25519@openssh.com AAAAInN... user@host

# 5. Verify key is resident
ssh-keygen -l -f ~/.ssh/id_ed25519_sk.pub
# Should show "(ED25519-SK) [resident]"
```

### Adding Public Key to Secrets

```bash
# 1. Edit encrypted secrets file (requires Yubikey)
cd ~/Projects/dotfiles/secrets
SOPS_AGE_KEY_FILE=~/.config/sops/age/yubikey-identity.txt sops secrets.yaml

# 2. Add your public key
ssh:
  authorized_key: |
    sk-ssh-ed25519@openssh.com AAAAInN... your@comment

# 3. Secret is already declared in modules/darwin/secrets.nix:
# sops.secrets."ssh/authorized_key" = { mode = "0444"; };
```

### Enabling SSH Server

After adding your key to secrets:

```bash
# Apply configuration (enables SSH server with your key)
cd ~/Projects/dotfiles
sudo darwin-rebuild switch --flake .

# Verify SSH server is running
systemsetup -getremotelogin
# Should show "Remote Login: On"

# Test locally
ssh -o StrictHostKeyChecking=no localhost
# You should be prompted to touch your Yubikey
```

## Multi-Machine Setup

### Machines Configured

| Machine | Hostname | User | Tailscale Name |
|---------|----------|------|----------------|
| Mac Studio | `seriousCallersOnly` | `john` | `seriousCallersOnly` |
| MacBook Air | `inOneEar` | `jrudnik` | `inOneEar` |

### Tailscale Integration

Both machines are connected via Tailscale mesh VPN:

```bash
# Get Tailscale IP on Mac Studio
tailscale ip -4

# From MacBook Air, connect via Tailscale
ssh seriousCallersOnly

# From Mac Studio, connect via Tailscale
ssh inOneEar
```

### Local Network Fallback

If Tailscale is unavailable, mDNS/Bonjour provides local network discovery:

```bash
# Connect via local network
ssh seriousCallersOnly.local
ssh inOneEar.local
```

## Troubleshooting

### SSH server not enabled

```bash
# Check Remote Login status
systemsetup -getremotelogin

# Manually enable (should be done by module activation)
sudo systemsetup -setremotelogin on
```

### Yubikey not detected

```bash
# Verify Yubikey is detected
ykman list

# Check age plugin can access Yubikey
age-plugin-yubikey --list

# Verify identity file exists
cat ~/.config/sops/age/yubikey-identity.txt
```

### "public key: pkcs11: couldn't connect" error

This means macOS built-in SSH client is being used instead of Nix openssh:

```bash
# Check which SSH is being used
which ssh

# Should show: /etc/profiles/per-user/john/bin/ssh
# If shows /usr/bin/ssh, PATH is not configured correctly

# Verify session path
echo $PATH

# Restart shell or open new terminal after configuration apply
```

### Yubikey touch prompt doesn't appear

1. Ensure Yubikey is inserted
2. Verify key is resident: `ssh-keygen -l -f ~/.ssh/id_ed25519_sk.pub`
3. Try removing `IdentitiesOnly yes` from SSH config temporarily

### "Permission denied (publickey)" error

1. Verify authorized key is in sops secret:
   ```bash
   sudo cat /run/secrets/ssh/authorized_key
   ```

2. Check authorized_keys.d was populated:
   ```bash
   ls -la /etc/ssh/authorized_keys.d/
   cat /etc/ssh/authorized_keys.d/$(whoami)
   ```

3. Verify SSH server is using drop-in config:
   ```bash
   cat /etc/ssh/sshd_config.d/100-nix-managed.conf
   ```

### Tailscale hostname not resolving

```bash
# Verify Tailscale is connected
tailscale status

# Check MagicDNS is enabled
tailscale status --peers | grep "MagicDNS"

# Fallback to local network
ssh seriousCallersOnly.local
```

### Adding a new SSH key (additional user)

1. Generate key with Yubikey
2. Add to `secrets/secrets.yaml`:
   ```yaml
   ssh:
     authorized_key: |
       sk-ssh-ed25519@openssh.com AAAAInN... existing-user-key
       sk-ssh-ed25519@openssh.com AAAAInN... new-user-key
   ```
3. Apply configuration to update `/etc/ssh/authorized_keys.d/`
4. Both keys will work for all users

## Security Considerations

### Password Authentication

Disabled by default. To enable (not recommended):

```nix
services.sshd = {
  passwordAuthentication = true;  # ⚠️ Security risk
};
```

### Root Login

Disabled by default. Options:

| Setting | Description |
|---------|-------------|
| `"no"` | Root cannot login (default, recommended) |
| `"prohibit-password"` | Root can login with pubkey only |
| `"forced-commands-only"` | Root can login only for forced commands |
| `"yes"` | Root can login with any method (⚠️ Security risk) |

### Key Management

- Private key never leaves Yubikey hardware
- Public key is stored in encrypted sops secret
- Resident key means no `~/.ssh/id_ed25519_sk` file needed (but kept for convenience)
- Yubikey touch required for each authentication attempt

## References

- [OpenSSH FIDO2/U2F Support](https://www.openssh.com/txt/release-8.2)
- [YubiKey FIDO2 Documentation](https://developers.yubico.com/FIDO2/)
- [sops-nix Documentation](https://github.com/Mic92/sops-nix)
- [nix-darwin SSH Documentation](https://daiderd.com/nix-darwin/manual/)
