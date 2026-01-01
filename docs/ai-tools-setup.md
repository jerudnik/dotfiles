# AI Tools Setup (Yubikey + sops-nix)

Parsimony first: this is the minimal, accurate setup for OpenCode with Yubikey-backed secrets across macOS (nix-darwin) and NixOS.

## Prerequisites
- Yubikey with PIV support
- Nix flakes enabled; this repo cloned
- Dev shell: `nix develop` (provides age-plugin-yubikey, yubikey-manager, sops, age)

## One-Time Yubikey + sops Setup
1) Enter dev shell
```bash
cd ~/Projects/dotfiles
nix develop
```
2) Initialize Yubikey and save identity
```bash
age-plugin-yubikey           # run wizard
mkdir -p ~/.config/sops/age
age-plugin-yubikey --identity > ~/.config/sops/age/yubikey-identity.txt
chmod 600 ~/.config/sops/age/yubikey-identity.txt
```
3) Add public key to `.sops.yaml`
- Add the `age1yubikey...` key under `keys:` and in the `creation_rules` for `secrets.yaml`.

4) Edit encrypted secrets (touch required)
```bash
cd secrets
SOPS_AGE_KEY_FILE=~/.config/sops/age/yubikey-identity.txt sops secrets.yaml
```
Add your keys, e.g.:
```yaml
api_keys:
  opencode_zen: "op-api-key"
  github_token: "ghp-..."
```

## Declare Secrets (per host/user)
Set owner per host to match the local username.
```nix
# hosts/mac-studio/default.nix (john)
sops.secrets = {
  "api_keys/opencode_zen" = { owner = "john"; mode = "0400"; };
  "api_keys/github_token" = { owner = "john"; mode = "0400"; };
};

# hosts/just-testing/default.nix (jrudnik)
sops.secrets = {
  "api_keys/opencode_zen" = { owner = "jrudnik"; mode = "0400"; };
};
```
NixOS: declare in `modules/nixos/secrets.nix` (uses host-derived age key at `/var/lib/sops-nix/key.txt`).

## Load Into Environment
`modules/home/ai/environment.nix` loads secrets into shell on login:
```nix
programs.zsh.initExtra = ''
  if [[ -r /run/secrets/api_keys/opencode_zen ]]; then
    export OPENCODE_API_KEY="$(cat /run/secrets/api_keys/opencode_zen)"
  fi
'';
```
Aliases: `oc` (opencode), `ai` (opencode run).

## Apply Configuration
```bash
# macOS
apply  # or: sudo darwin-rebuild switch --flake .

# NixOS
sudo nixos-rebuild switch --flake .
```
Open a new terminal so env vars load.

## Verify
```bash
echo $OPENCODE_API_KEY
cat /run/secrets/api_keys/opencode_zen
which opencode
opencode --version
```

## Environment Variables (need-to-know)
- `OPENCODE_API_KEY` (secret) – from `/run/secrets/api_keys/opencode_zen`
- `GITHUB_PERSONAL_ACCESS_TOKEN` (secret) – from `/run/secrets/api_keys/github_token`
- `CONTEXT7_API_KEY` (secret) – from `/run/secrets/api_keys/context7`
- `EXA_API_KEY` (secret) – from `/run/secrets/api_keys/exa`
- `SOPS_AGE_KEY_FILE` – `~/.config/sops/age/yubikey-identity.txt`
- `OLLAMA_HOST` – e.g. `http://100.x.y.z:11434` for remote Ollama

## MCP Servers (where to configure)
- Definitions: `modules/home/ai/mcp.nix`
- Deployment strategies:
  - `remote`: Third-party hosted SSE endpoints (context7, exa)
  - `local-nix`: Stable Nix packages from nixpkgs (github-mcp-server)
  - `local-npx`: Official TypeScript MCP servers via npx (filesystem, memory, sequential-thinking)
  - `local-uvx`: Python tools via uvx (mcp-nixos, grep-mcp, serena)
- Prefer official TypeScript implementations (`@modelcontextprotocol/*`) via `npx --yes` when available
- Default memory storage: `~/Utility/mcp-memory/memory.jsonl` (directory ensured by the config)
- Clients: enable in `modules/home/ai/default.nix`

## Walkthrough (condensed)
1) `nix develop`
2) `age-plugin-yubikey` → save identity file
3) Add public key to `.sops.yaml`
4) `sops secrets.yaml` → add `api_keys/opencode_zen`
5) Declare secrets per host (owner correct)
6) Apply: `apply` (macOS) or `nixos-rebuild switch`
7) New terminal → verify env vars → run `oc`

## Troubleshooting
- **"no identity matched"**: Yubikey plugged, identity file present, `.sops.yaml` contains your key.
- **Secrets missing in /run/secrets**: verify declarations in `modules/darwin/secrets.nix` or `modules/nixos/secrets.nix`; re-apply.
- **Env var empty**: open a new terminal; confirm file ownership matches user.
- **Yubikey touch prompt absent**: ensure `IdentityAgent = "none"` per-host in `modules/home/ssh.nix`; use Nix openssh (`which ssh` → `/etc/profiles/per-user/.../ssh`).

## Notes
- Backup Yubikey: not configured here; set up later as separate task.
- This doc supersedes the old `ai-environment-variables.md` (merged).
