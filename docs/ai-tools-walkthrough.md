# AI Tools Setup Walkthrough

Step-by-step guide for setting up OpenCode TUI with Yubikey-backed secrets.

## Prerequisites

- Yubikey 5 series (5C NFC, 5 NFC, etc.) with PIV support
- macOS with nix-darwin configured
- This dotfiles repository cloned

## Step 1: Enter Development Shell

```bash
cd ~/Projects/dotfiles
nix develop
```

This provides: `age-plugin-yubikey`, `yubikey-manager`, `sops`, `age`

## Step 2: Initialize Yubikey with Age Plugin

Insert your Yubikey and run the setup wizard:

```bash
age-plugin-yubikey
```

The wizard will prompt you to:

1. **Select your Yubikey** (if multiple detected)
2. **Choose a PIN** (6-8 digits, used for PIV operations)
3. **Choose a PUK** (8 digits, recovery PIN if PIN is locked)
4. **Set touch policy** - Select "Always" for maximum security
5. **Name your identity** - e.g., `john-yubikey-primary`

The wizard generates an age key pair directly on the Yubikey. The private key **never leaves the hardware**.

## Step 3: Save Identity File

```bash
mkdir -p ~/.config/sops/age
age-plugin-yubikey --identity > ~/.config/sops/age/yubikey-identity.txt
chmod 600 ~/.config/sops/age/yubikey-identity.txt
```

## Step 4: Get Your Public Key

```bash
age-plugin-yubikey --list
```

Output looks like:
```
#       Serial: 12345678, Slot: 1
#         Name: john-yubikey-primary
#      Created: Wed, 25 Dec 2024 10:30:00 +0000
#   PIN policy: once
# Touch policy: always
age1yubikey1qghhvxsh9ttxpqvnf3um7fuv7y0ut4hvl5gk2rgwtezj0e2avkmd7chvckq
```

Copy the public key (starts with `age1yubikey1...`).

## Step 5: Update `.sops.yaml`

Edit `secrets/.sops.yaml` and replace the placeholder key:

```yaml
keys:
  - &john age1yubikey1qghhvxsh9ttxpqvnf3um7fuv7y0ut4hvl5gk2rgwtezj0e2avkmd7chvckq

creation_rules:
  - path_regex: secrets\.yaml$
    key_groups:
      - age:
          - *john
```

## Step 6: Create Encrypted Secrets

```bash
cd ~/Projects/dotfiles/secrets
SOPS_AGE_KEY_FILE=~/.config/sops/age/yubikey-identity.txt sops secrets.yaml
```

Your editor opens. Add your secrets:

```yaml
api_keys:
  opencode_zen: "op-your-api-key-here"
```

Save and exit. **Touch your Yubikey** when prompted to encrypt.

## Step 7: Verify Encryption

```bash
head -5 secrets/secrets.yaml
```

You should see encrypted content:
```yaml
api_keys:
    opencode_zen: ENC[AES256_GCM,data:...,type:str]
```

## Step 8: Apply Configuration

```bash
sudo darwin-rebuild switch --flake .
```

**Touch your Yubikey** when prompted (during secret decryption).

## Step 9: Open New Terminal

**Important**: Open a new terminal window/tab to load the environment variables.

The shell startup script loads the API key from the decrypted secret into `OPENCODE_API_KEY`.

## Step 10: Verify Setup

Check the environment variable is set:
```bash
echo $OPENCODE_API_KEY
# Should show your API key
```

Check the decrypted secret exists and is readable:
```bash
cat /run/secrets/api_keys/opencode_zen
# Should show your API key (owned by your user)
```

Verify OpenCode is installed:
```bash
which opencode
opencode --version
```

Check OpenCode config was generated:
```bash
cat ~/.config/opencode/opencode.json
```

## Step 11: Test OpenCode

```bash
cd ~/Projects/some-project
oc   # or 'opencode'
```

Run `/models` in OpenCode to verify available models.

## Quick Reference

### Edit Secrets
```bash
cd ~/Projects/dotfiles/secrets
SOPS_AGE_KEY_FILE=~/.config/sops/age/yubikey-identity.txt sops secrets.yaml
# Touch Yubikey to decrypt, edit, touch again to re-encrypt
```

### Apply Changes
```bash
cd ~/Projects/dotfiles
sudo darwin-rebuild switch --flake .
# Touch Yubikey to decrypt secrets
```

### Shell Aliases (after setup)
- `oc` - Alias for `opencode`
- `ai` - Alias for `opencode run`

### Environment Variables (set automatically)
- `OPENCODE_API_KEY` - OpenCode Zen API key (loaded from secret at shell startup)
- `SOPS_AGE_KEY_FILE` - Points to Yubikey identity
- `OLLAMA_HOST` - Local Ollama server

## Security Notes

1. **PIN vs Touch**: PIN is entered once per session; touch is required for each decrypt operation
2. **Identity file**: Contains only public key and Yubikey reference - safe if leaked
3. **Encrypted secrets**: Safe to commit to git - can only be decrypted with physical Yubikey
4. **Backup Yubikey**: Strongly recommended - see setup guide for instructions

## Next Steps

- Set up a backup Yubikey (see `docs/ai-tools-setup.md`)
- Add more API keys (Anthropic, OpenAI, etc.)
- Configure additional MCP servers
- Add project-specific AGENTS.md files
