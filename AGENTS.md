# Guidelines for AI agents working in this nix-darwin + home-manager dotfiles repository.

## Build Commands

```bash
# Apply configuration (requires sudo)
apply                                    # Dev shell alias
sudo darwin-rebuild switch --flake .     # Direct command

# Update flake inputs
update                                   # Dev shell alias
nix flake update                         # Direct command

# Format all Nix files
nix fmt

# Check flake validity
nix flake check

# Enter development shell (provides apply, update, sops, age)
nix develop
```

There are no tests in this repository. Validation is done via `nix flake check` and successful `apply`.

## Directory Map (need-to-know)

- `flake.nix` / `flake.lock` – inputs/outputs
- `hosts/` – per-host configs
  - `common/{darwin,nixos}/default.nix`
  - `mac-studio/default.nix` (serious-callers-only)
  - `just-testing/default.nix` (just-testing)
  - `sleeper-service/default.nix` (Pixelbook, NixOS)
- `modules/`
  - `base/` – stylix
  - `darwin/` – system, homebrew, secrets, services (ollama, whisper, tailscale, sshd, emacs, harmonia, linux-builder)
  - `nixos/` – desktop (hyprland, launcher, lock, notifications, waybar), security, system, secrets
  - `home/` – ai, apps (incl. linux), editors, shell, terminal, git, packages, ssh, development
- `users/{john,jrudnik}/` – user home-manager configs
- `themes/` – base16 schemes
- `secrets/` – `.sops.yaml`, `secrets.yaml`

## Code Style

- Formatter: `nix fmt` (nixfmt-rfc-style)
- Module form: `{ config, pkgs, lib, ... }: { ... }`
- Conventions: 2-space indent; trailing commas; double quotes; `with pkgs; [ ... ]` for package lists
- Options: `lib.mkOption`, `lib.mkIf`, `lib.mkDefault`, `lib.mkEnableOption`
- Service pattern: see `modules/darwin/services/ollama.nix`

## Secrets (sops-nix)

- Encrypted with Yubikey-backed age (macOS) or host-derived age (NixOS)
- Decrypts to `/run/secrets/...`
- Declare in `modules/darwin/secrets.nix` or `modules/nixos/secrets.nix`
- Edit: `SOPS_AGE_KEY_FILE=~/.config/sops/age/yubikey-identity.txt sops secrets/secrets.yaml`
- See `docs/ai-tools-setup.md` for full workflow

## MCP Servers (summary)

- Definitions: `modules/home/ai/mcp.nix`
- Types: `remote`, `local-npx` (official TypeScript), `local-nix`, `local-uvx` (Python)
- Preferred hierarchy: `local-npx` (official TS) → `local-nix` → `local-uvx` (Python tools)
- Clients: enable in `modules/home/ai/default.nix`
- Details and examples: `docs/ai-tools-setup.md`

## SSH (FIDO2 Yubikey)

- Client: `modules/home/ssh.nix` (per-host matchBlocks, uses Nix openssh)
- Server: `modules/darwin/services/sshd.nix`
- Hostnames: serious-callers-only, just-testing, sleeper-service (+ `.local`)
- Critical fix: set `IdentityAgent = "none"` per host to bypass macOS agent
- More: `docs/ssh.md`

## Git Signing (Yubikey over SSH)

- `programs.git.signing = { key = "~/.ssh/id_ed25519_sk.pub"; signByDefault = true; };`
- `gpg.format = "ssh"; gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";`

## Common Patterns

- Add package: `modules/home/packages.nix` (use nixpkgs when possible)
- Add Homebrew cask: `modules/darwin/homebrew.nix`
- Add service: create `modules/darwin/services/foo.nix`, import in `modules/darwin/default.nix`, enable in host
- Add host: `hosts/<name>/default.nix`, then list in `flake.nix`
- Add MCP server: define in `modules/home/ai/mcp.nix`, add secret if needed, apply

## Important Notes

- Determinate Nix in use (nix.enable = false in darwin config)
- nixpkgs: unstable
- home-manager integrated via nix-darwin modules
- Homebrew cleanup = "zap" (unlisted casks removed)
