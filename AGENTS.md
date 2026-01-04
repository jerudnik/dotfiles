# Guidelines for AI agents working in this nix-darwin + home-manager dotfiles repository.

## Build Commands

```bash
# Basic (run from dev shell: nix develop)
apply                                    # Apply configuration (requires sudo)
update                                   # Update flake inputs
nix fmt                                  # Format code (nixfmt + prettier)

# Validation
nix flake check                          # Validate all configurations
darwin-rebuild check --flake .           # Dry-run darwin (no changes)
nixos-rebuild dry-build --flake .        # Dry-run NixOS

# Component testing
nix build .#darwinConfigurations.serious-callers-only.system
nix eval .#darwinConfigurations.serious-callers-only.config.services.ollama.enable

# Exploration
nix repl --expr 'builtins.getFlake "."'  # Interactive REPL
```

There are no tests. Validation is via `nix flake check` and successful `apply`.

## Directory Map

- `flake.nix` / `flake.lock` – Inputs and outputs
- `hosts/` – Per-host configs (`serious-callers-only`, `just-testing`, `sleeper-service`)
- `modules/base/` – Cross-platform (stylix theming)
- `modules/darwin/` – macOS system, homebrew, secrets, services
- `modules/nixos/` – NixOS desktop, security, system
- `modules/home/` – Home-manager: ai, apps, editors, shell, terminal, packages
- `users/` – User home-manager configs
- `themes/` – Base16 color schemes
- `secrets/` – sops-nix encrypted secrets

## Code Style

**Formatter**: `nix fmt` runs treefmt (nixfmt-rfc-style for `.nix`, prettier for md/yaml/json)

**Module signature** (required):

```nix
{ config, pkgs, lib, ... }:
```

**Comment styles** (required):

```nix
# File header - Brief description
# https://optional-reference-url

# ============================================================
# Major Section (use for grouping in large files)
# ============================================================

# Inline comment explaining non-obvious code
someOption = value;
```

**Naming conventions**:

- Files: kebab-case (`linux-builder.nix`)
- Options: dot-separated hierarchy (`services.ollama.enable`)
- Variables: camelCase for helpers (`enabledServers`)
- Config alias: `cfg = config.services.servicename;`

**Package lists**: Use section markers and inline comments:

```nix
home.packages = with pkgs; [
  # ==== Category ====
  package1  # Brief explanation
  package2
];
```

## Module Patterns

**Service module template**:

```nix
# Service Name - Brief description
# https://reference-url
{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.services.example;
in
{
  options.services.example = {
    enable = mkEnableOption "Example service";
    port = mkOption { type = types.port; default = 8080; description = "Port for the service"; };
  };
  config = mkIf cfg.enable {
    # Configuration here
  };
}
```

**Complete example**: `modules/darwin/services/ollama.nix`
**Advanced patterns**: See `docs/nix-patterns.md`

## Platform Differences

| Aspect   | Darwin                  | NixOS                        |
| -------- | ----------------------- | ---------------------------- |
| Apply    | `darwin-rebuild switch` | `nixos-rebuild switch`       |
| Services | `launchd.user.agents`   | `systemd.services`           |
| Daemons  | `launchd.daemons`       | `systemd.services`           |
| GUI Apps | `homebrew.casks`        | `environment.systemPackages` |
| Arch     | `aarch64-darwin`        | `x86_64-linux`               |
| User cfg | `users/*/home.nix`      | `users/*/home-linux.nix`     |

## Boundaries

**Always**: Run `nix flake check` before committing, run `nix fmt` to format changes,
update `modules/*/default.nix` imports when adding modules, use nixpkgs over homebrew

**Ask first**: Adding flake inputs, modifying `secrets/secrets.yaml`,
changing `homebrew.onActivation` settings, modifying `system.stateVersion`

**Never**: Edit `flake.lock` manually (use `nix flake update`), commit unencrypted secrets,
remove module imports without checking references, use `x86_64-darwin` (this repo uses Apple Silicon)

## Common Mistakes

- **Missing import**: After creating a module, add it to `modules/*/default.nix`
- **Platform paths**: Use `/Applications` on Darwin, `/usr/bin` on NixOS
- **Home-manager contract**: Don't break `useGlobalPkgs = true` in host configs
- **Architecture**: Darwin hosts are `aarch64-darwin`, not `x86_64-darwin`

## Secrets (sops-nix)

Encrypted with Yubikey-backed age. Decrypts to `/run/secrets/...`. Declare in
`modules/darwin/secrets.nix` or `modules/nixos/secrets.nix`. Workflow: `docs/ai-tools-setup.md`

## Integrations

**Chezmoi**: Nix handles packages/services/themes, chezmoi handles dotfile templates.
Bridge exports Stylix colors to `~/.config/chezmoi/chezmoidata.json`. See `docs/chezmoi.md`.

**MCP Servers**: Defined in `modules/home/ai/mcp.nix`. Types: `local-npx`, `local-nix`, `local-uvx`.
Prefer `local-npx` for official TS servers. **SSH/Git**: FIDO2 Yubikey via `modules/home/ssh.nix`.

## Serena Integration

- Prefer `find_symbol`, `find_referencing_symbols` over grep for code navigation
- Use `replace_symbol_body`, `insert_after_symbol` for targeted edits
- Read relevant memories before complex changes; write granular memories for discovered patterns
