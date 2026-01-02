# Automation

Configuration for AI agents and CI/CD workflows.

## Passwordless darwin-rebuild

Enables unattended system configuration updates without interactive password prompts.

### Overview

| Aspect      | Detail                                                       |
| ----------- | ------------------------------------------------------------ |
| **Module**  | `modules/darwin/sudo.nix`                                    |
| **Scope**   | Only `darwin-rebuild` is passwordless (not full sudo)        |
| **Users**   | Applied to `config.system.primaryUser` (john on mac-studio, jrudnik on just-testing) |

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

## SSH Builder Key and Remote Builds

For remote builds and automation, a dedicated passphraseless SSH key is available.

See [SSH Documentation](ssh.md) for details on:
- Builder key location (`~/.ssh/id_ed25519_builder`)
- Host aliases (`<hostname>-builder`)
- Server configuration

### Remote builder options (Determinate Nix)
- `nix.linux-builder` module is blocked (Determinate Nix sets `nix.enable = false`).
- Use ad-hoc `--builders` with the builder key, or run a Linux VM (OrbStack/UTM) as SSH builder.
- Binary cache integration: see [binary-cache.md](binary-cache.md) for using Harmonia in CI/automation.

---

## References

- Sudo module: `modules/darwin/sudo.nix`
- Darwin common config: `hosts/common/darwin/default.nix`
- SSH config: `modules/home/ssh.nix`
- SSH docs: `docs/ssh.md`
