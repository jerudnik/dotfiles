# Chezmoi Integration

This repository now uses a hybrid approach where Nix manages infrastructure while chezmoi manages dotfiles. Nix remains the source of truth for services, packages, and computed configuration, exporting data via `chezmoidata.json`. Chezmoi consumes that data inside templates, enabling fast iteration on everyday dotfiles without rebuilding the system.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         NIX                                  │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │  Packages   │  │  Services   │  │  Computed Configs   │  │
│  │  (nixpkgs)  │  │  (launchd)  │  │  (chezmoi bridge)   │  │
│  └─────────────┘  └─────────────┘  └──────────┬──────────┘  │
└───────────────────────────────────────────────┼─────────────┘
                                                │
                      chezmoidata.json          │
                      (Stylix colors,           ▼
                       MCP configs,      ┌─────────────────┐
                       host metadata)    │    CHEZMOI      │
                                         │  ┌───────────┐  │
                                         │  │ Templates │  │
                                         │  │ (.tmpl)   │  │
                                         │  └───────────┘  │
                                         └────────┬────────┘
                                                  │
                                                  ▼
                                         ~/.config/*
                                         ~/.gitconfig
                                         etc.
```

## Computed Partial Strategy

- Define infrastructure (Stylix, MCP servers, fonts, host metadata) in Nix.
- `modules/home/chezmoi-bridge.nix` exports those values to `~/.config/chezmoi/chezmoidata.json`.
- Chezmoi templates use `include` to read the data file, then inject pre-computed JSON via helpers like `toPrettyJson`.
- This keeps logic in Nix while allowing dotfiles to live in chezmoi for rapid editing.

Example (`chezmoi/dot_config/opencode/opencode.json.tmpl`):

```go-template
{{- $data := include (joinPath .chezmoi.homeDir ".config/chezmoi/chezmoidata.json") | fromJson -}}
{
  "agent": { "persona": "friendly" },
  "mcp": {{ $data.opencode_mcp_config | toPrettyJson }}
}
```

**Important**: Templates use `include` to read data from `~/.config/chezmoi/chezmoidata.json` rather than relying on chezmoi's native `.chezmoidata.*` mechanism. This allows the nix-generated data file to work across all hosts regardless of username.

## Directory Structure

```
chezmoi/                              # Source repo (linked to ~/.local/share/chezmoi)
├── .chezmoi.toml.tmpl
├── .chezmoiignore
├── dot_gitconfig.tmpl                # Git config with FIDO2 Yubikey signing
├── dot_config/
│   ├── nvim/init.lua                 # kickstart.nvim base config
│   ├── ghostty/config.tmpl           # Terminal with Stylix colors
│   ├── starship.toml.tmpl            # Prompt with Stylix colors
│   ├── atuin/
│   │   ├── config.toml.tmpl          # Shell history with Bitwarden key
│   │   └── private_key.tmpl          # Atuin sync key
│   ├── zed/settings.json.tmpl        # Zed editor with MCP and Nix LSP (nil)
│   ├── zsh/
│   │   ├── aliases.zsh               # Shell aliases (static)
│   │   ├── functions.zsh             # Shell functions (static)
│   │   └── local.zsh.tmpl            # Host-specific config, API keys
│   └── opencode/opencode.json.tmpl   # OpenCode MCP config
├── dot_cursor/mcp.json.tmpl          # Cursor MCP config (Computed Partial)
├── private_Library/                  # macOS Library (private_ = restricted perms)
│   └── private_Application Support/
│       └── Claude/
│           └── claude_desktop_config.json.tmpl
└── dot_Notes/                        # Obsidian vault templates
    └── obsidian/robinson/
        └── .obsidian/plugins/...
```

> **Note**: The `private_` prefix is a chezmoi convention that creates files/directories with restricted permissions (0700 for dirs, 0600 for files). This is used for macOS `~/Library/` paths which contain sensitive application data.

**Path conventions:**
- Claude Desktop: `private_Library/private_Application Support/Claude/` → `~/Library/Application Support/Claude/`
- Cursor: `dot_cursor/` → `~/.cursor/`
- The `private_` prefix ensures proper permissions and is stripped during apply.

### Neovim configuration

- `chezmoi/dot_config/nvim/init.lua` tracks the kickstart.nvim base config.
- Customize this file directly in the repo (or via `~/.local/share/chezmoi/dot_config/nvim/init.lua`).
- Run `chezmoi apply` after edits to sync.

## Available Template Variables

Values come from `~/.config/chezmoi/chezmoidata.json`.

After loading with `$data := include ... | fromJson`:

- `$data.stylix.base00` … `$data.stylix.base0F`: Base16 colors with `#` prefix.
- `$data.font.monospace`, `$data.font.size`: Fonts exported by Stylix.
- `$data.hostname`, `$data.username`, `$data.isDarwin`, `$data.isLinux`: Host metadata.
- `$data.opencode_mcp_config`, `$data.claude_config`, `$data.cursor_config`: Computed MCP payloads.
- `$data.tools.git`, `$data.tools.nix`: Nix store paths to tools.

## Workflow

### Initial setup / source location

By convention, this repo's `chezmoi/` directory is symlinked to the default chezmoi source path:

```bash
ln -sf ~/Projects/dotfiles/chezmoi ~/.local/share/chezmoi
```

Alternatively, point chezmoi directly at the repo:

```bash
chezmoi init --source ~/Projects/dotfiles/chezmoi
```

### When changing Nix infrastructure

```bash
apply                    # Rebuilds system and refreshes chezmoidata.json
chezmoi apply           # Renders templates with new computed data
```

### When editing dotfiles only

```bash
chezmoi apply
```

### Full sync shorthand

```bash
apply && chezmoi apply
```

## Adding a New Dotfile Template

1. Create `chezmoi/dot_config/app/config.toml.tmpl` (or relevant path).
2. Add the data include at the top of the template:
   ```go-template
   {{- $data := include (joinPath .chezmoi.homeDir ".config/chezmoi/chezmoidata.json") | fromJson -}}
   ```
3. Reference computed values: `{{ $data.stylix.base05 }}`, `{{ $data.hostname }}`.
4. Handle OS differences with `{{ if $data.isDarwin }}…{{ end }}`.
5. Run `chezmoi apply` to deploy immediately.

## Adding or Updating MCP Servers

1. Define the server in `modules/home/ai/mcp.nix`.
2. Run `apply` so the bridge recomputes `.opencode_mcp_config`, `.claude_config`, and `.cursor_config`.
3. Run `chezmoi apply` to push updates into Cursor/Claude/OpenCode templates under `dot_cursor/` and `Library/Application Support/Claude/`.

## Verification Checklist

- `cat ~/.config/chezmoi/chezmoidata.json | jq .stylix` shows stylix colors.
- `chezmoi execute-template < chezmoi/dot_cursor/mcp.json.tmpl` renders without errors.
- `chezmoi apply --dry-run` lists expected changes before applying.
- Documentation now reflects neovim as the default editor.
