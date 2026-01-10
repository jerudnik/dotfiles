# Project: Nix Dotfiles

A Nix-based configuration management system for macOS (nix-darwin) and Linux (NixOS)
with home-manager, supporting AI-assisted development and research workflows.

## Purpose

Declarative, reproducible system configuration across Apple Silicon Macs and x86_64
Linux machines. Manages packages, services, shell environment, AI tooling, and
application configuration through Nix flakes with secrets management via sops-nix.

## Tech Stack

| Layer         | Technology                                                     |
| ------------- | -------------------------------------------------------------- |
| Configuration | Nix flakes, nix-darwin, NixOS, home-manager                    |
| Secrets       | sops-nix (Yubikey-backed age), Bitwarden (chezmoi templates)   |
| Dotfiles      | Chezmoi (templates consuming Nix-computed values)              |
| Formatting    | treefmt (nixfmt-rfc-style for .nix, prettier for md/yaml/json) |
| AI Tooling    | OpenCode, MCP servers, custom agents and skills                |
| Shell         | Zsh with starship prompt, atuin history                        |
| Editor        | Neovim, Zed                                                    |

## Architecture

### Directory Structure

```
├── flake.nix / flake.lock     # Inputs and outputs
├── hosts/                      # Per-host configs (darwin/nixos)
├── modules/
│   ├── base/                   # Cross-platform (stylix theming)
│   ├── darwin/                 # macOS: system, homebrew, services
│   ├── nixos/                  # NixOS: desktop, security, system
│   └── home/                   # home-manager: ai, apps, editors, shell
├── users/                      # User-specific home-manager configs
├── themes/                     # Base16 color schemes
├── secrets/                    # sops-nix encrypted secrets
├── chezmoi/                    # Dotfile templates
├── docs/                       # Documentation
└── openspec/                   # Change proposals and specs
```

### Module Patterns

**Service module signature:**

```nix
{ config, pkgs, lib, ... }:
with lib;
let cfg = config.services.example;
in {
  options.services.example = { ... };
  config = mkIf cfg.enable { ... };
}
```

**Export conventions:**

- Options: `config.services.<name>.<option>`
- Read-only computed values: `config.services.<name>.<computed>` with `readOnly = true`
- Transformers: `to{Format}Format` naming (e.g., `toOpenCodeFormat`)
- Filters: `enabledServers`, `enabledSkills` for enabled subsets

### Chezmoi Bridge Pattern

**Data Flow:**

```
Nix modules compute values
        ↓
chezmoi-bridge.nix exports to ~/.config/chezmoi/chezmoidata.json
        ↓
Chezmoi templates consume via {{ $data := include ... | fromJson }}
        ↓
chezmoi apply generates final dotfiles
```

**Exported Data:**

- `stylix`: Base16 colors (`base00` through `base0F`)
- `font`: Monospace font name and size
- `hostname`, `username`, `isDarwin`, `isLinux`: Host metadata
- `opencode_mcp_config`: MCP servers in OpenCode format
- `claude_config`, `cursor_config`: MCP servers in stdio client format
- `tools`: Nix store paths for git, nix, etc.

**Template Patterns:**

1. **Data Loading**: `{{ $data := include (joinPath .chezmoi.homeDir ".config/chezmoi/chezmoidata.json") | fromJson }}`
2. **JSON Injection**: `{{ $data.opencode_mcp_config | toPrettyJson }}`
3. **Value Access**: `{{ $data.stylix.base00 }}`
4. **OS Branching**: `{{ if $data.isDarwin }}...{{ end }}`
5. **Secret Injection**: `{{ $apiKeys := bitwardenFields "item" "API Keys" }}`

## Code Style

- **Formatter:** `nix fmt` runs treefmt (nixfmt-rfc-style)
- **Module signature:** `{ config, pkgs, lib, ... }:`
- **Naming conventions:**
  - Files: kebab-case (`linux-builder.nix`)
  - Options: dot-separated (`services.mcp.enable`)
  - Variables/helpers: camelCase (`enabledServers`)
  - Resources: kebab-case (`context7`, `nix-module`)
- **Comments:** File headers, section markers (`# ====`), inline explanations
- **Package lists:** Section markers with inline comments

## Validation

### Nix Validation

```bash
nix flake check              # Validate all configurations
nix fmt                      # Format code
nix fmt -- --check           # Check formatting without changes
darwin-rebuild check --flake . # Dry-run darwin (no changes)
nixos-rebuild dry-build --flake . # Dry-run NixOS
```

### Chezmoi Validation

```bash
# Template validation (test rendering)
chezmoi execute-template --file chezmoi/dot_config/opencode/opencode.json.tmpl

# State verification
chezmoi verify               # Check all targets match source (exit 1 if mismatch)
chezmoi diff                 # Show pending changes
chezmoi status               # Quick summary of changes
chezmoi apply --dry-run      # Preview apply without changes

# Bridge validation (after Nix apply)
jq empty ~/.config/chezmoi/chezmoidata.json              # Validate JSON syntax
jq -e '.stylix.base00' ~/.config/chezmoi/chezmoidata.json # Verify expected fields
```

### Full Validation Workflow

```bash
nix flake check                                    # 1. Validate Nix config
apply                                              # 2. Rebuild system + chezmoidata.json
jq empty ~/.config/chezmoi/chezmoidata.json        # 3. Verify bridge JSON
chezmoi execute-template --file chezmoi/dot_config/opencode/opencode.json.tmpl  # 4. Test templates
chezmoi diff                                       # 5. Review changes
chezmoi apply                                      # 6. Apply dotfiles
chezmoi verify                                     # 7. Confirm success
```

No test suite — validation is via `nix flake check`, successful `apply`, and `chezmoi verify`.

## Hosts

| Host                 | Platform   | Architecture   |
| -------------------- | ---------- | -------------- |
| serious-callers-only | nix-darwin | aarch64-darwin |
| just-testing         | nix-darwin | aarch64-darwin |
| sleeper-service      | NixOS      | x86_64-linux   |

## AI Module (`modules/home/ai/`)

### Current Structure

| File                 | Purpose                                | Exports                                                            |
| -------------------- | -------------------------------------- | ------------------------------------------------------------------ |
| `default.nix`        | Orchestrates imports, enables services | -                                                                  |
| `opencode.nix`       | OpenCode client config + agents        | - (consumed by chezmoi-bridge)                                     |
| `skills.nix`         | Skill definitions                      | `services.skills.{definitions,opencode}`                           |
| `mcp.nix`            | MCP server definitions                 | `services.mcp.{servers,opencode,claudeDesktopConfig,cursorConfig}` |
| `environment.nix`    | Shell environment variables            | -                                                                  |
| `claude-desktop.nix` | Claude Desktop preferences             | `services.claudeDesktop.preferences`                               |

### MCP Server Types

- `remote`: SSE endpoints (context7)
- `local-nix`: Nix packages (github-mcp-server)
- `local-npx`: TypeScript via npx (filesystem, sequential-thinking, exa)
- `local-uvx`: Python via uvx (mcp-nixos, serena)

**Preference order:** local-npx → local-nix → local-uvx

### Obsidian Integration (Planned)

_See `openspec/changes/add-research-agents/` for implementation proposal._

Research notes vault at `~/Notes/obsidian/robinson/`. Planned MCP servers:

- **obsidian-mcp-server**: CRUD operations via Local REST API
- **obsidian-index**: Semantic search via embeddings

API key stored in Bitwarden ("Obsidian Keys" secret with per-host fields).

### Skills

Generated to `~/.config/opencode/skill/<name>/SKILL.md` with YAML frontmatter.
Loaded on-demand via OpenCode's `skill` tool.

## Constraints

### Always

- Run `nix flake check` before committing
- Run `nix fmt` to format changes
- Update `modules/*/default.nix` imports when adding modules
- Prefer nixpkgs over homebrew
- Validate chezmoi templates after Nix changes

### Ask First

- Adding flake inputs
- Modifying `secrets/secrets.yaml`
- Changing `homebrew.onActivation` settings
- Modifying `system.stateVersion`

### Never

- Edit `flake.lock` manually (use `nix flake update`)
- Commit unencrypted secrets
- Remove module imports without checking references
- Use `x86_64-darwin` (Apple Silicon only)

## Domain Context

### Research Context

Doctoral research in HCI/STS examining AI-enabled care technologies. Research
notes in `~/Notes/obsidian/robinson/` (Obsidian vault). Planned: research-focused
agents and skills with theoretical commitments for academic writing.

### Secret Management

```
sops-nix (Yubikey) → /run/secrets/... (system secrets)
Bitwarden → chezmoi templates → env vars (API keys)
OpenCode → {env:VAR} syntax → runtime expansion
```

## Git Workflow

- Branch from main for changes
- Conventional commits preferred
- PRs for significant changes
- `apply` deploys configuration

## Related Documentation

- `docs/chezmoi.md` - Nix/chezmoi integration patterns
- `docs/ai-tools-setup.md` - MCP server configuration
- `docs/nix-patterns.md` - Advanced Nix patterns
- `docs/ssh.md` - SSH and FIDO2 setup
