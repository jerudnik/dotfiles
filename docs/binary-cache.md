# Harmonia Binary Cache

Private Nix binary cache for faster builds across all machines in the network.

## Overview

Harmonia serves cached Nix derivations from `serious-callers-only` (Mac Studio), avoiding redundant builds across macOS and NixOS machines connected via Tailscale. Chosen over nix-serve-ng/attic for simplicity and reliable signing; priority 30 ensures it is preferred over cache.nixos.org (40).

```
┌─────────────────────────────────────────────────────────────────┐
│                    Binary Cache Architecture                     │
├─────────────────────────────────────────────────────────────────┤
│  Server (serious-callers-only, port 5000):                      │
│    Harmonia → serves cached .nar.xz files                       │
│    Signs with private key → validates authenticity               │
│    Stores in /nix/var/nix/profiles/per-user/root/harmonia-store │
│                                                                 │
│  Clients (all machines):                                        │
│    Query cache before building → download if available          │
│    Fallback to cache.nixos.org for missing derivations          │
│    Cache priority: 30 (lower = higher than cache.nixos.org)     │
│                                                                 │
│  Transport:                                                     │
│    Tailscale mesh network → resolves serious-callers-only       │
│    HTTP → no TLS on private network                             │
└─────────────────────────────────────────────────────────────────┘
```

## Configuration

### Server (serious-callers-only)

Location: `hosts/serious-callers-only/default.nix`

```nix
services.harmonia = {
  enable = true;
  signKeyPath = config.sops.secrets."harmonia/signing_key".path;
};
```

Options (defaults in `modules/darwin/services/harmonia.nix`):

| Option              | Type   | Default        | Description                                |
| ------------------- | ------ | -------------- | ------------------------------------------ |
| `bind`              | string | `0.0.0.0:5000` | Address and port                           |
| `workers`           | int    | `4`            | Worker threads                             |
| `priority`          | int    | `30`           | Cache priority (lower = preferred)         |
| `maxConnectionRate` | int    | `256`          | Max connections per worker                 |
| `enableCompression` | bool   | `false`        | zstd compression (can cause resume issues) |

**Critical**: The signing key is required and managed via sops.

### Clients (Darwin)

Location: `hosts/common/darwin/default.nix`

```nix
determinate-nix.customSettings = {
  extra-substituters = [ "http://serious-callers-only:5000" ];
  extra-trusted-public-keys = [
    "serious-callers-only-1:QrBHwuZWNAmIevJ1ER2JPE6I+2AuRlsD/UhrEXHQOFE="
  ];
};
```

### Clients (NixOS)

Location: `hosts/common/nixos/default.nix`

```nix
nix.settings = {
  extra-substituters = [ "http://serious-callers-only:5000" ];
  extra-trusted-public-keys = [
    "serious-callers-only-1:QrBHwuZWNAmIevJ1ER2JPE6I+2AuRlsD/UhrEXHQOFE="
  ];
};
```

## Verification

### Check cache endpoint

From any machine on the Tailscale network:

```bash
curl http://serious-callers-only:5000/nix-cache-info
```

Expected output:

```
StoreDir: /nix/store
WantMassQuery: 1
Priority: 30
```

### Check service status (server)

```bash
# Launchd status
sudo launchctl list | grep harmonia

# Logs
tail -f /var/log/harmonia.log
tail -f /var/log/harmonia.error.log

# Metrics endpoint
curl http://serious-callers-only:5000/metrics
```

### Verify a build used the cache

When building, Nix outputs paths with `(built <time>)` for local builds or `(fetched <time>)` for cache hits.

```bash
# Example: fetch from cache
# copying 1 paths...
# copying path '/nix/store/abc...-example-1.0' from 'http://serious-callers-only:5000'...
```

## Troubleshooting

### Service not running

```bash
# Check if service is loaded
sudo launchctl list | grep org.nixos.harmonia

# Check for errors
sudo launchctl print system/org.nixos.harmonia

# Restart service
sudo launchctl kickstart -k system/org.nixos.harmonia
```

### DNS resolution fails

Ensure Tailscale is connected and the host is reachable:

```bash
# Check Tailscale status
tailscale status

# Ping the host
ping serious-callers-only

# Check if port is open
nc -zv serious-callers-only 5000
```

### Signature verification failures

If Nix refuses to fetch from the cache:

```bash
# Check if public key is configured
echo $NIX_CONFIG | grep serious-callers-only

# Manually test fetch
nix store ping --store http://serious-callers-only:5000
```

### Cache not being used

Verify cache priority and substituter order:

```bash
# Show current Nix configuration
nix show-config | grep substituters
nix show-config | grep trusted-public-keys
```

The Harmonia cache (priority 30) should appear before cache.nixos.org (priority 40).

## Key Rotation

### Generate new signing key

```bash
# On the server, generate new key pair
nix-store --generate-binary-cache-key serious-callers-only-1 /tmp/harmonia.secret /tmp/harmonia.pub

# View the keys
cat /tmp/harmonia.secret  # Private key for sops
cat /tmp/harmonia.pub     # Public key for client configs
```

**Note**: `nix-serve --generate-secret-key` is broken in nixpkgs; use `nix-store --generate-binary-cache-key` instead.

### Update configuration

1. Add new secret to sops:

   ```bash
   sops secrets/secrets.yaml
   # Add: harmonia/signing_key_v2: <private-key-content>
   ```

2. Update server config to use new key:

   ```nix
   # hosts/serious-callers-only/default.nix
   services.harmonia.signKeyPath = config.sops.secrets."harmonia/signing_key_v2".path;
   ```

3. Add new public key to all clients (both Darwin and NixOS common configs):

   ```nix
   extra-trusted-public-keys = [
     "serious-callers-only-1:..."  # Keep old key for validation
     "serious-callers-only-2:..."  # Add new key
   ];
   ```

4. Apply changes:

   ```bash
   # On server
   sudo darwin-rebuild switch && chezmoi apply

   # On all clients
   sudo darwin-rebuild switch && chezmoi apply  # or sudo nixos-rebuild switch && chezmoi apply
   ```

5. Wait for cache to repopulate (new builds will be signed with new key)

6. After a grace period (e.g., 1 week), remove the old public key from client configs

## Secrets Structure

```yaml
# secrets/secrets.yaml
harmonia:
  signing_key: |
    -----BEGIN AGE ENCRYPTED FILE-----
    ...
    -----END AGE ENCRYPTED FILE-----
```

Declared in `modules/darwin/secrets.nix`:

```nix
sops.secrets."harmonia/signing_key" = {
  owner = "root";
  group = "wheel";
  mode = "0400";  # Read-only for root
};


## Known Issues

### Public Key Mismatch (Bug)

Darwin and NixOS clients currently use different public keys:

| Platform | Key (truncated)                      | Location                          |
| -------- | ------------------------------------ | --------------------------------- |
| Darwin   | `...QrBHwuZWNAmIevJ1ER2JPE6I+2Aul...`  | `hosts/common/darwin/default.nix` |
| NixOS    | `...J/+Orh0qfTKuVEm//2bA0bXKnTmX...` | `hosts/common/nixos/default.nix`  |

**Expected**: All platforms should use the same public key matching the Harmonia signing key in `secrets/secrets.yaml`.

**Impact**: Cache hits may fail on one platform if the signing key was rotated and only one client config was updated.

**Fix**: Verify which key matches the current signing secret, then update the incorrect client configuration. See GitHub issue for tracking.

## References

- Server module: `modules/darwin/services/harmonia.nix`
- Server config: `hosts/serious-callers-only/default.nix`
- Client config (Darwin): `hosts/common/darwin/default.nix`
- Client config (NixOS): `hosts/common/nixos/default.nix`
- Public key: `secrets/public-keys/harmonia.pub`
```
