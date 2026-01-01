# AI Tools Walkthrough (procedural)

Use this when you want a linear sequence. For details and rationale, see `docs/ai-tools-setup.md` (authoritative) and the MCP sections there.

## Steps (macOS + NixOS)
1) Dev shell
```bash
cd ~/Projects/dotfiles
nix develop
```

2) Initialize Yubikey + save identity
```bash
age-plugin-yubikey
mkdir -p ~/.config/sops/age
age-plugin-yubikey --identity > ~/.config/sops/age/yubikey-identity.txt
chmod 600 ~/.config/sops/age/yubikey-identity.txt
```

3) Add public key to `.sops.yaml` (keys + creation_rules for `secrets.yaml`).

4) Edit encrypted secrets (touch required)
```bash
cd secrets
SOPS_AGE_KEY_FILE=~/.config/sops/age/yubikey-identity.txt sops secrets.yaml
```
Add `api_keys/opencode_zen`, `api_keys/github_token`, etc.

5) Declare secrets per host (owner matches user)
- macOS: `hosts/mac-studio/default.nix`, `hosts/just-testing/default.nix`
- NixOS: `modules/nixos/secrets.nix` (age key at `/var/lib/sops-nix/key.txt`)

6) Apply configuration
```bash
# macOS
apply  # or: sudo darwin-rebuild switch --flake .

# NixOS
sudo nixos-rebuild switch --flake .
```
Open a new terminal after apply.

7) Verify
```bash
echo $OPENCODE_API_KEY
cat /run/secrets/api_keys/opencode_zen
which opencode
opencode --version
```

8) Run OpenCode
```bash
cd ~/Projects/any-project
oc   # or: opencode
```

## Notes
- Backup Yubikey: not configured; schedule separately.
- Remote Ollama: set `OLLAMA_HOST=http://100.x.y.z:11434`.
- Yubikey touch prompt missing: ensure `IdentityAgent = "none"` per-host in `modules/home/ssh.nix` and that `which ssh` points to `/etc/profiles/per-user/.../ssh`.
