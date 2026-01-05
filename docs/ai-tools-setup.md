# AI Tools Setup (Bitwarden + chezmoi)

Parsimony first: this is the minimal, accurate setup for OpenCode with Bitwarden-managed secrets across macOS (nix-darwin) and NixOS.

## Quick Start (checklist)

1. Install Bitwarden Desktop (via homebrew cask) and log in
2. Enable SSH Agent in Bitwarden settings
3. Create "API Keys" secure note with custom fields: `opencode_zen`, `github_token`, `context7`, `exa`
4. Create "Local Keys" secure note with custom field: `atuin_key`
5. `nix develop` → `apply` (or `sudo nixos-rebuild switch --flake .`)
6. Unlock Bitwarden CLI: `bw unlock --session` (or unlock in Desktop app)
7. Apply chezmoi: `chezmoi apply` (pulls secrets from Bitwarden)
8. New terminal → verify `OPENCODE_API_KEY` and `opencode --version`

## Prerequisites

- Bitwarden Desktop installed and logged in
- Bitwarden CLI (`bw`) installed (via nixpkgs or homebrew)
- Nix flakes enabled; this repo cloned
- Dev shell: `nix develop` (provides chezmoi, bitwarden-cli)

## One-Time Bitwarden Setup

1. Install Bitwarden Desktop (if not already installed)

Bitwarden is installed via homebrew cask (see `modules/darwin/homebrew.nix`).

2. Enable SSH Agent in Bitwarden

- Open Bitwarden Desktop
- Go to Settings → SSH Agent
- Enable "Enable SSH Agent"
- Set socket path to `~/.bitwarden-ssh-agent.sock`

3. Create API Keys secure note

In Bitwarden Desktop, create a new secure note called "API Keys":

- Add custom fields:
  - `opencode_zen` - Your OpenCode API key
  - `github_token` - GitHub personal access token
  - `context7` - Context7 API key
  - `exa` - Exa AI search API key

4. Create Local Keys secure note

Create another secure note called "Local Keys":

- Add custom field: `atuin_key` - Your Atuin sync key

## Chezmoi Template Integration

Chezmoi templates pull secrets from Bitwarden during `chezmoi apply`:

- Templates reference: `chezmoi/dot_config/opencode/`, `chezmoi/private_Library/...`
- Template syntax: `{{ (bitwardenFields "item" "API Keys").opencode_zen.value }}`
- Requires Bitwarden CLI unlocked before running chezmoi

## Load Into Environment

`modules/home/ai/environment.nix` loads secrets from chezmoi-managed config files:

```nix
# Chezmoi writes to ~/.config/opencode/.env
programs.zsh.initExtra = ''
  if [[ -f ~/.config/opencode/.env ]]; then
    source ~/.config/opencode/.env
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

## Apply Chezmoi (Secrets Deployment)

After Nix config is applied, deploy secrets from Bitwarden:

```bash
# Unlock Bitwarden CLI (or unlock in Desktop app)
bw unlock --session

# Apply chezmoi templates (pulls secrets from Bitwarden)
chezmoi apply
```

Open a new terminal so env vars load.

## Verify

```bash
echo $OPENCODE_API_KEY
which opencode
opencode --version

# Check chezmoi managed files
cat ~/.config/opencode/.env
```

## Environment Variables (need-to-know)

- `OPENCODE_API_KEY` (secret) – sourced from `~/.config/opencode/.env` (chezmoi managed)
- `GITHUB_PERSONAL_ACCESS_TOKEN` (secret) – sourced from `~/.config/opencode/.env`
- `CONTEXT7_API_KEY` (secret) – sourced from `~/.config/opencode/.env`
- `EXA_API_KEY` (secret) – sourced from `~/.config/opencode/.env`
- `OLLAMA_HOST` – e.g. `http://100.x.y.z:11434` for remote Ollama (see `docs/ai-server.md`)

## MCP Servers (where to configure)

- Definitions: `modules/home/ai/mcp.nix`
- Deployment strategies:
  - `remote`: Third-party hosted SSE endpoints (context7, exa)
  - `local-nix`: Stable Nix packages from nixpkgs (github-mcp-server)
  - `local-npx`: Official TypeScript MCP servers via npx (filesystem, memory, sequential-thinking)
  - `local-uvx`: Python tools via uvx (mcp-nixos, grep-mcp, serena)
- Preferred hierarchy: `local-npx` (official TypeScript) → `local-nix` → `local-uvx` (Python)
- Default memory storage: `~/Utility/mcp-memory/memory.jsonl` (directory ensured by the config)
- Clients: enable in `modules/home/ai/default.nix`

### Computed Partial Strategy

MCP configurations use a "Computed Partial" approach:

1. **Nix computes**: Server definitions, secret paths, and transformations live in `modules/home/ai/mcp.nix`
2. **Bridge exports**: `modules/home/chezmoi-bridge.nix` exports computed configs to `~/.config/chezmoi/chezmoidata.json`
3. **Chezmoi templates**: Templates in `chezmoi/dot_config/opencode/`, `chezmoi/dot_cursor/`, and `chezmoi/private_Library/.../Claude/` inject the pre-computed JSON

This keeps infrastructure logic in Nix while allowing rapid iteration on client-specific settings in chezmoi templates.

### Adding/Updating MCP Servers

```bash
# 1. Define server in modules/home/ai/mcp.nix
# 2. Add any required secrets to Bitwarden "API Keys" note
# 3. Apply Nix config (regenerates chezmoidata.json)
apply

# 4. Apply chezmoi templates (updates OpenCode/Claude/Cursor configs)
chezmoi apply
```

See `docs/chezmoi.md` for full template variable reference.

## Troubleshooting

- **"Bitwarden not unlocked"**: Run `bw unlock --session` or unlock Bitwarden Desktop before `chezmoi apply`.
- **Env var empty**: Run `chezmoi apply` after unlocking Bitwarden; open a new terminal.
- **Template errors**: Verify Bitwarden note structure matches template expectations (custom field names).
- **"bw: command not found"**: Ensure `bitwarden-cli` is in packages (see `modules/home/packages.nix`).
- **SSH Agent not working**: Verify Bitwarden SSH Agent is enabled in settings and socket exists at `~/.bitwarden-ssh-agent.sock`.

## Notes

- SSH keys are managed by Bitwarden SSH Agent (see `docs/ssh.md`).
- sops-nix is only used for boot-time secrets (Harmonia cache signing key).
- This doc supersedes the old `ai-environment-variables.md` (merged).
