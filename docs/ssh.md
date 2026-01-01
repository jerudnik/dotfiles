# SSH (Yubikey + Tailscale)

Need-to-know guide for this repo’s SSH setup on macOS (nix-darwin) and NixOS.

## What You Get
- Hardened SSH server (pubkey-only, no root login)
- FIDO2/Yubikey client keys (ed25519-sk)
- Per-host config for: `serious-callers-only`, `just-testing`, `sleeper-service` (+ `.local` fallbacks)
- Tailscale-first access; mDNS fallback
- Authorized keys managed via sops-nix

## Server (macOS)
Enable in host config:
```nix
services.sshd = {
  enable = true;
  authorizedKeysFile = config.sops.secrets."ssh/authorized_key".path;
  passwordAuthentication = false;
  permitRootLogin = "no";
};
```
Notes:
- Drop-in at `/etc/ssh/sshd_config.d/100-nix-managed.conf`
- Authorized keys populated from sops secret
- Tailscale provides primary access

## Client (all hosts)
Location: `modules/home/ssh.nix`

Key patterns:
```nix
home.sessionPath = [ "${pkgs.openssh}/bin" ];  # Use Nix openssh (FIDO2 support)

# Per-host matchBlock
"serious-callers-only" = {
  identityFile = [ "~/.ssh/id_ed25519_sk" ];
  identitiesOnly = true;
  extraOptions = { IdentityAgent = "none"; };  # CRITICAL: bypass macOS agent
};
```
- Same pattern for `.local` and other hosts
- Do NOT set `AddKeysToAgent` or `UseKeychain` with FIDO2 keys

## Key Generation (FIDO2)
```bash
ssh-keygen -t ed25519-sk -f ~/.ssh/id_ed25519_sk -C "Yubikey FIDO2 key"
# Touch when prompted
cat ~/.ssh/id_ed25519_sk.pub  # add to secrets
```
Add public key to `secrets/secrets.yaml`:
```yaml
ssh:
  authorized_key: |
    sk-ssh-ed25519@openssh.com AAAA... user@host
```
Secret is declared at darwin/nixos level:
```nix
sops.secrets."ssh/authorized_key" = { mode = "0444"; };
```
Apply with `apply` (macOS) or `sudo nixos-rebuild switch --flake .` (NixOS).

## Connecting
```bash
ssh serious-callers-only         # Tailscale
ssh serious-callers-only.local   # local fallback
ssh just-testing
ssh sleeper-service
```

## Troubleshooting (fast path)
- **No touch prompt / hangs**: ensure matchBlock has `IdentityAgent = "none"`; verify `which ssh` → `/etc/profiles/per-user/.../ssh` (not `/usr/bin/ssh`).
- **"public key: pkcs11" error**: same as above; restart shell so PATH picks Nix openssh.
- **Key not accepted**: check secret deployed:
  ```bash
  sudo cat /run/secrets/ssh/authorized_key
  ls -la /etc/ssh/authorized_keys.d/
  ```
- **Server not enabled**: `systemsetup -getremotelogin` (macOS); apply config.
- **Tailscale name not resolving**: `tailscale status`; fall back to `.local` hostnames.
- **Yubikey not detected**: `ykman list`; `age-plugin-yubikey --list`.

## References
- Client: `modules/home/ssh.nix`
- Server: `modules/darwin/services/sshd.nix`
- Secrets: `secrets/secrets.yaml`, `modules/{darwin,nixos}/secrets.nix`
