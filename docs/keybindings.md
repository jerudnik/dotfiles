# Keyboard Shortcuts Reference

This document catalogs keyboard shortcuts configured across the dotfiles.

## macOS System Shortcuts

Configured in `modules/darwin/system.nix`.

### Spotlight (Disabled)

Spotlight shortcuts are disabled to free CMD+Space for Raycast:

| Shortcut      | Default Action   | Status   |
| ------------- | ---------------- | -------- |
| CMD+Space     | Spotlight Search | Disabled |
| CMD+Alt+Space | Spotlight Window | Disabled |

**Setup**: After applying, configure Raycast:

1. Raycast Settings > General > Raycast Hotkey > CMD+Space
2. Enable "Launch at Login"

## Ghostty Terminal

Configured in `chezmoi/dot_config/ghostty/config.tmpl`.

### Window Management

| Shortcut        | Action        |
| --------------- | ------------- |
| CMD+Shift+Enter | New window    |
| CMD+Shift+T     | New tab       |
| CMD+Shift+W     | Close surface |

### Splits

| Shortcut       | Action               |
| -------------- | -------------------- |
| CMD+D          | Split right          |
| CMD+Shift+D    | Split down           |
| CMD+Ctrl+Left  | Navigate split left  |
| CMD+Ctrl+Right | Navigate split right |
| CMD+Ctrl+Up    | Navigate split up    |
| CMD+Ctrl+Down  | Navigate split down  |

### Tab Navigation

| Shortcut | Action    |
| -------- | --------- |
| CMD+1-9  | Go to tab |

## Neovim

Configured in `chezmoi/dot_config/nvim/init.lua`. Uses which-key for discoverability.

### Split Navigation

| Shortcut | Action              |
| -------- | ------------------- |
| Ctrl+H   | Move to left split  |
| Ctrl+L   | Move to right split |
| Ctrl+J   | Move to lower split |
| Ctrl+K   | Move to upper split |

**Tip**: Press Space in normal mode to see available keybinds via which-key.

## Claude Desktop

Configured in `modules/home/ai/claude-desktop.nix`.

| Option               | Default       | Description        |
| -------------------- | ------------- | ------------------ |
| `quickEntryShortcut` | `cmd+shift+c` | Quick entry hotkey |

## Atuin Shell History

Configured in `chezmoi/dot_config/atuin/config.toml.tmpl`.

| Shortcut | Action                              |
| -------- | ----------------------------------- |
| Ctrl+R   | Search shell history                |
| Up Arrow | Search history (directory-filtered) |

## NixOS Hyprland (Linux)

Keybindings for the Hyprland Wayland compositor are managed via chezmoi
or Hyprland's default configuration. See Hyprland documentation for defaults.

Required packages installed in `modules/nixos/desktop/hyprland.nix`:

- `brightnessctl` - Brightness control
- `playerctl` - Media key support
- `pamixer` - Volume control
