# AGENTS.md

Guidelines for AI agents working in this nix-darwin + home-manager dotfiles repository.

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

## Directory Structure

```
flake.nix                    # Entry point - inputs and outputs
hosts/
  common/
    darwin/default.nix       # Shared darwin config (all macOS hosts)
    nixos/default.nix        # Shared NixOS config (placeholder)
  mac-studio/default.nix     # Host-specific config
modules/
  base/
    stylix.nix               # Theming configuration (cross-platform)
  darwin/
    default.nix              # Darwin module index
    system.nix               # macOS system preferences
    homebrew.nix             # Homebrew casks and formulae
    secrets.nix              # sops-nix secrets configuration
    services/                # Custom launchd services (ollama, whisper, etc.)
  home/
    default.nix              # Home-manager module index
    shell/                   # Shell configuration (zsh, starship)
    editors/                 # Editor configs (helix)
    terminal/                # Terminal emulators (ghostty, wezterm)
    apps/                    # Application configs
    ai/                      # AI tools (OpenCode, MCP servers)
    packages.nix             # CLI tools
    git.nix                  # Git configuration
    development.nix          # Dev tools and runtimes
    python-tools.nix         # Python-specific tooling
users/john/
  home.nix                   # User home-manager entry point
themes/
  modus.nix                  # Base16 color schemes
secrets/
  .sops.yaml                 # sops-nix key configuration (Yubikey public keys)
  secrets.yaml               # Encrypted secrets (safe to commit)
```

## Code Style

### Formatter
Run `nix fmt` before committing (uses `nixfmt-rfc-style`, configured in `flake.nix`).

### Module Structure
```nix
{ config, pkgs, lib, ... }:
{
  # Module content
}
```

Add `inputs` to the signature only when accessing flake inputs directly.

### Formatting Conventions
- Indentation: 2 spaces
- Trailing commas: Required in attribute sets and lists (nixfmt enforces)
- String quotes: Use double quotes `"string"`
- Multi-line strings: Use `''multi-line''` syntax

### Comments
- Use `#` for comments
- Section headers: Use `# ====` dividers for major sections
- Inline comments: Place after code on same line when brief

### Naming Conventions
- File names: kebab-case (e.g., `system.nix`, `fzf-tab`)
- Imports: Relative paths; directories auto-import `default.nix`
- Package lists: Use `with pkgs; [ ... ]` pattern

### Options and Configuration
- Use `lib.mkOption` for custom options with proper types
- Use `lib.mkIf` for conditional configuration
- Use `lib.mkDefault` for overridable defaults
- Use `lib.mkEnableOption` for boolean enable flags

### Service Modules Pattern
Custom services follow this pattern (see `modules/darwin/services/ollama.nix`):
```nix
{ config, pkgs, lib, ... }:
with lib;
let cfg = config.services.myservice;
in {
  options.services.myservice = {
    enable = mkEnableOption "My service";
    port = mkOption { type = types.port; default = 8080; };
  };
  config = mkIf cfg.enable { /* Service configuration */ };
}
```

## Secrets (sops-nix)

Secrets are encrypted with Yubikey-backed age keys. The private key never leaves the hardware.

```bash
# Edit secrets (requires Yubikey touch)
SOPS_AGE_KEY_FILE=~/.config/sops/age/yubikey-identity.txt sops secrets/secrets.yaml

# In Nix modules, declare secrets at darwin level (modules/darwin/secrets.nix):
sops.secrets."api_keys/example" = { };

# Secrets decrypt to /run/secrets/api_keys/example
# Reference in configs with: {file:/run/secrets/api_keys/example}
```

- Never commit unencrypted secrets
- Encrypted secrets.yaml is safe to commit (requires physical Yubikey to decrypt)
- See `docs/ai-tools-setup.md` for full documentation

## Theming (Stylix)

```nix
themes.variant = "modus-vivendi"   # Dark theme
themes.variant = "modus-operandi"  # Light theme
```

- Custom themes: Add base16 schemes to `themes/` directory
- Stylix auto-applies colors/fonts to terminal, editors, and apps

## MCP Servers (Model Context Protocol)

MCP servers are configured centrally in `modules/home/ai/mcp.nix` and can be shared across multiple clients (OpenCode, Claude Desktop, Cursor).

```nix
# In mcp.nix, add servers to mcpServerDefinitions:
mcpServerDefinitions = {
  # Remote server (OpenCode only)
  context7 = {
    type = "remote";
    url = "https://mcp.context7.com/mcp";
    description = "Documentation search";
  };
  
  # Exa - AI web search (remote, requires EXA_API_KEY)
  exa = {
    type = "remote";
    url = "https://mcp.exa.ai/mcp";
    description = "Exa AI web search";
  };
  
  # Local server with Nix package
  grep-app = {
    type = "local";
    package = pkgs.grep-mcp;
    description = "GitHub code search via grep.app";
  };
  
  # Local server (works with all clients)
  github = {
    type = "local";
    package = pkgs.github-mcp-server;
    args = [ "stdio" ];
    env = { GITHUB_PERSONAL_ACCESS_TOKEN = "$GITHUB_PERSONAL_ACCESS_TOKEN"; };
  };
};
```

Enable client configs in `modules/home/ai/default.nix`:
```nix
services.mcp.enableClaudeDesktop = true;  # ~/Library/Application Support/Claude/
services.mcp.enableCursor = true;          # ~/.cursor/mcp.json
```

## Common Patterns

### Adding a New Package
Add to `modules/home/packages.nix` in the `home.packages` list.

### Adding a Homebrew Cask
Add to `modules/darwin/homebrew.nix` in the `homebrew.casks` list.

### Adding a New Service
1. Create `modules/darwin/services/myservice.nix`
2. Import in `modules/darwin/default.nix`
3. Enable in host config: `services.myservice.enable = true;`

### Adding Host-Specific Config
1. Create `hosts/newhostname/default.nix`
2. Import common config and add host-specific settings
3. Add to `darwinConfigurations` in `flake.nix`

### Adding an MCP Server
1. Add server definition to `modules/home/ai/mcp.nix` in `mcpServerDefinitions`
2. If it needs an API key, add to secrets and load in `environment.nix`
3. Apply - configs auto-generate for enabled clients

## Important Notes

- This repo uses Determinate Nix (nix.enable = false in darwin config)
- nixpkgs follows unstable channel
- home-manager is integrated via nix-darwin modules
- Homebrew cleanup is set to "zap" - unlisted packages will be removed
