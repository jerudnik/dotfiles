# Automation

Configuration for AI agents and CI/CD workflows.

## Passwordless darwin-rebuild

Enables unattended system configuration updates without interactive password prompts.

### Overview

| Aspect     | Detail                                                                                         |
| ---------- | ---------------------------------------------------------------------------------------------- |
| **Module** | `modules/darwin/sudo.nix`                                                                      |
| **Scope**  | Only `darwin-rebuild` is passwordless (not full sudo)                                          |
| **Users**  | Applied to `config.system.primaryUser` (john on serious-callers-only, jrudnik on just-testing) |

### What This Enables

- AI agent-driven system updates (`sudo darwin-rebuild switch --flake .`)
- CI/CD pipelines for infrastructure-as-code
- Automated validation (`sudo darwin-rebuild build --flake .`)

### Security Considerations

The sudo rule is strictly scoped:

```
<user> ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/darwin-rebuild *
```

- Full sudo still requires password for other commands
- Only allows darwin-rebuild execution (no root shell)
- Full command path required (prevents alias tricks)

### Verification

```bash
# Should run without password prompt
sudo -n darwin-rebuild build --flake .

# Check exit code (0 = success)
echo $?
```

### Rollback

To disable, comment out the import in `modules/darwin/default.nix`:

```nix
imports = [
  # ./sudo.nix  # Disable passwordless darwin-rebuild
];
```

Then apply (password required for this final time):

```bash
sudo darwin-rebuild switch --flake .
```

### Alternative: Touch ID

For interactive use with biometric authentication, nix-darwin supports:

```nix
security.pam.enableSudoTouchIdAuth = true;
```

Touch ID is better for interactive sessions but doesn't help automated agents.

---

## Formatting (treefmt)

- `nix fmt` now uses treefmt (wrapper) with nixfmt-rfc-style for Nix and prettier for md/yaml/json.
- Config: `treefmt.nix` at repo root; flake formatter wraps treefmt via `treefmt-nix` input.
- Run before commits: `nix fmt` and `nix flake check`.
- Dev shell still provides `nix fmt` alias (wrapper).

## Parallel Evaluation (Determinate Nix)

Speeds up Nix operations by using multiple CPU cores during evaluation.

### Configuration

Located in `hosts/common/darwin/default.nix`:

```nix
determinate-nix.customSettings = {
  eval-cores = 0;  # Use all available cores (0 = auto-detect)
  extra-experimental-features = [
    "build-time-fetch-tree"
    "parallel-eval"
  ];
};
```

**Note**: Uses `determinate-nix.customSettings`, not `nix.settings` (Determinate Nix manages Nix configuration directly).

### Performance

Expected speedup: **2-3.7x** on evaluation-heavy operations:

- `nix flake check`
- `nix search`
- `nix eval`

### Verification

```bash
nix show-config | grep eval-cores
# Should show: eval-cores = 0
```

### Disabling

If issues occur, set to single-core:

```nix
determinate-nix.customSettings = {
  eval-cores = 1;  # Disable parallel evaluation
};
```

Then apply: `sudo darwin-rebuild switch --flake .`

---

## Native Linux Builder (Determinate Nix)

Determinate Nix provides a native Linux builder via the `determinate-nixd` daemon, configured automatically in `/etc/nix/nix.conf`.

### How It Works

- Uses `determinate-nixd` daemon as external builder
- **NO SSH required** - daemon handles authentication internally
- Supports both `aarch64-linux` and `x86_64-linux` builds
- Configured automatically when Determinate Nix is installed

### Usage

```bash
# Build for Linux (aarch64)
nix build --impure --expr '(import <nixpkgs> { system = "aarch64-linux"; }).hello'

# Build for Linux (x86_64)
nix build --impure --expr '(import <nixpkgs> { system = "x86_64-linux"; }).hello'
```

### Verification

```bash
# Check nix.conf for external-builders
cat /etc/nix/nix.conf | grep external-builders

# Should show something like:
# external-builders = [{"args":["builder"],"program":"/usr/local/bin/determinate-nixd","systems":["aarch64-linux","x86_64-linux"]}]
```

### Known Limitations

- **Network access**: Derivations requiring network access during build may fail due to DNS issues (GitHub issue #294)
- **Workaround**: Use remote SSH builders with the builder key for network-dependent builds

### SSH Builder Key (Backup)

For builds requiring network access or remote builders, a dedicated passphraseless SSH key is available:

- Location: `~/.ssh/id_ed25519_builder`
- Host aliases: `<hostname>-builder` (e.g., `serious-callers-only-builder`)
- Configured in `modules/home/ssh.nix` with `IdentityAgent = none`

Use ad-hoc `--builders` with this key for remote Linux VMs or CI.

---

## Secrets Encryption (sops-nix)

For boot-time secrets that must be available before user login, sops-nix is still used.

### Scope

sops-nix is **only** used for:

- Harmonia cache signing key (boot-time requirement)

### Not Used For

- API keys → Bitwarden + chezmoi (see `docs/ai-tools-setup.md`)
- SSH keys → Bitwarden SSH Agent (see `docs/ssh.md`)
- Atuin sync key → Bitwarden + chezmoi (see `docs/ai-tools-setup.md`)

### Encryption

- **macOS**: age-plugin-yubikey → sops-nix
- **NixOS**: Host-derived age key → sops-nix

---

## References

- Sudo module: `modules/darwin/sudo.nix`
- Darwin common config: `hosts/common/darwin/default.nix`
- SSH config: `modules/home/ssh.nix`
- SSH docs: `docs/ssh.md`
- Bitwarden setup: `docs/ai-tools-setup.md`
- Harmonia cache: `docs/binary-cache.md`
