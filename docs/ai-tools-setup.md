# AI Tools Setup: OpenCode TUI with Yubikey-Backed Secrets

## Overview

This document covers the setup of OpenCode TUI with Yubikey-backed secrets management using sops-nix. The private encryption key never leaves the Yubikey hardware, providing strong security for API keys and other secrets.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Your Dotfiles                            │
├─────────────────────────────────────────────────────────────────┤
│  secrets/                                                       │
│  ├── .sops.yaml          # Encryption rules (Yubikey public key)│
│  └── secrets.yaml        # Encrypted secrets (safe to commit)   │
│                                                                 │
│  modules/darwin/secrets.nix      # sops-nix configuration       │
│  modules/home/ai/opencode.nix    # OpenCode configuration       │
│  modules/home/ai/environment.nix # Loads secrets into env vars  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    darwin-rebuild switch                         │
│                    (requires Yubikey touch)                      │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  /run/secrets/api_keys/opencode_zen   # Decrypted, owned by john│
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  Shell startup (.zshrc) loads secret into OPENCODE_API_KEY      │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  OpenCode config uses: {env:OPENCODE_API_KEY}                   │
└─────────────────────────────────────────────────────────────────┘
```

## Module Structure

```
modules/
├── darwin/
│   └── secrets.nix        # sops-nix config (darwin level)
└── home/
    └── ai/
        ├── default.nix    # Module index
        ├── opencode.nix   # OpenCode package + config
        └── environment.nix # Shell environment + aliases
```

## Key Files

### `modules/darwin/secrets.nix`

Configures sops-nix at the darwin (system) level:
- Points to `secrets/secrets.yaml`
- Uses Yubikey identity file for decryption
- Declares secrets with owner/permissions for user access
- Secrets decrypted to `/run/secrets/`

### `modules/home/ai/opencode.nix`

Configures OpenCode:
- Installs the `opencode` package
- Generates `~/.config/opencode/opencode.json`
- References secrets via `{env:VARIABLE_NAME}` syntax
- Configures MCP servers (Context7, etc.)

### `modules/home/ai/environment.nix`

Shell environment setup:
- Loads secrets from `/run/secrets/` into environment variables at shell startup
- Sets `OPENCODE_API_KEY` from the decrypted secret
- Provides shell aliases (`oc`, `ai`)

### `secrets/.sops.yaml`

Defines encryption rules:
- Lists authorized Yubikey public keys
- Specifies which keys can decrypt which files

## Adding New Secrets

1. **Edit the encrypted secrets file** (requires Yubikey):
   ```bash
   cd ~/Projects/dotfiles/secrets
   SOPS_AGE_KEY_FILE=~/.config/sops/age/yubikey-identity.txt sops secrets.yaml
   ```

2. **Add your secret** in YAML format:
   ```yaml
   api_keys:
     opencode_zen: "op-existing-key"
     anthropic: "sk-ant-new-key"    # Add new key
   ```

3. **Declare the secret** in `modules/darwin/secrets.nix`:
   ```nix
   sops.secrets = {
     "api_keys/opencode_zen" = { owner = "john"; mode = "0400"; };
     "api_keys/anthropic" = { owner = "john"; mode = "0400"; };
   };
   ```

4. **Load into environment** in `modules/home/ai/environment.nix`:
   ```nix
   programs.zsh.initExtra = ''
     if [[ -r /run/secrets/api_keys/anthropic ]]; then
       export ANTHROPIC_API_KEY="$(cat /run/secrets/api_keys/anthropic)"
     fi
   '';
   ```

5. **Reference in config** using environment variable:
   ```nix
   apiKey = "{env:ANTHROPIC_API_KEY}";
   ```

6. **Apply the configuration**:
   ```bash
   sudo darwin-rebuild switch --flake .
   # Touch Yubikey when prompted
   # Open new terminal to load environment variables
   ```

## Adding a Backup Yubikey

1. **Set up the backup Yubikey**:
   ```bash
   age-plugin-yubikey  # Run wizard with backup key inserted
   ```

2. **Get the backup key's public key**:
   ```bash
   age-plugin-yubikey --list
   ```

3. **Add to `.sops.yaml`**:
   ```yaml
   keys:
     - &john age1yubikey1q...primary...
     - &john-backup age1yubikey1q...backup...
   
   creation_rules:
     - path_regex: secrets\.yaml$
       key_groups:
         - age:
             - *john
             - *john-backup
   ```

4. **Re-encrypt secrets** with both keys:
   ```bash
   cd ~/Projects/dotfiles/secrets
   SOPS_AGE_KEY_FILE=~/.config/sops/age/yubikey-identity.txt sops updatekeys secrets.yaml
   ```

## Cross-Platform Usage

The same Yubikey works across machines:

1. Copy identity file to new machine:
   ```bash
   scp ~/.config/sops/age/yubikey-identity.txt user@newhost:~/.config/sops/age/
   ```
   Or regenerate: `age-plugin-yubikey --identity > ~/.config/sops/age/yubikey-identity.txt`

2. Install `age-plugin-yubikey` on the new machine

3. Plug in your Yubikey - decryption works identically

For NixOS hosts, use `sops-nix.nixosModules.sops` instead of `darwinModules.sops`.

## Troubleshooting

### "age: error: no identity matched any of the recipients"
- Ensure Yubikey is plugged in
- Verify identity file exists: `cat ~/.config/sops/age/yubikey-identity.txt`
- Check public key matches `.sops.yaml`: `age-plugin-yubikey --list`

### "please touch your YubiKey" hangs
- Touch the metal contact on your Yubikey
- If using USB-C, ensure good connection
- Try removing and reinserting the Yubikey

### Secrets not appearing in `/run/secrets/`
- Check sops-nix service: `sudo launchctl list | grep sops`
- Verify secrets are declared in `modules/darwin/secrets.nix`
- Check system log for errors

### OpenCode can't read API key
- Open a **new terminal** to load environment variables
- Verify env var is set: `echo $OPENCODE_API_KEY`
- Check secret is readable: `cat /run/secrets/api_keys/opencode_zen`
- Verify secret has correct owner: `ls -la /run/secrets/api_keys/`

### Environment variable not set
- Ensure you opened a new terminal after `darwin-rebuild switch`
- Check the secret file is readable by your user (owner should be `john`)
- Verify `programs.zsh.initExtra` is loading the secret
