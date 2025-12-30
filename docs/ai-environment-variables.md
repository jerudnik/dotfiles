# AI Environment Variables

Documentation of environment variables used by AI tooling in this dotfiles repository.

## From SOPS Secrets

These variables are loaded from encrypted secrets at `/run/secrets/`.

| Variable                       | Secret Path              | Used By                       |
| ------------------------------ | ------------------------ | ----------------------------- |
| `OPENCODE_API_KEY`             | `api_keys/opencode_zen`  | OpenCode Zen provider         |
| `GITHUB_PERSONAL_ACCESS_TOKEN` | `api_keys/github_token`  | GitHub MCP server             |
| `CONTEXT7_API_KEY`             | `api_keys/context7`      | Context7 MCP server           |
| `EXA_API_KEY`                  | `api_keys/exa`           | Exa AI search MCP server      |

### Secret Declaration

Secrets are declared in `modules/darwin/secrets.nix`:

```nix
sops.secrets = {
  "api_keys/opencode_zen" = { owner = "john"; mode = "0400"; };
  "api_keys/github_token" = { owner = "john"; mode = "0400"; };
  "api_keys/context7" = { owner = "john"; mode = "0400"; };
  "api_keys/exa" = { owner = "john"; mode = "0400"; };
};
```

### Secret Loading

Secrets are loaded as environment variables in `modules/home/ai/environment.nix`:

```nix
home.sessionVariables = {
  OPENCODE_API_KEY = "$(cat /run/secrets/api_keys/opencode_zen 2>/dev/null || echo '')";
  GITHUB_PERSONAL_ACCESS_TOKEN = "$(cat /run/secrets/api_keys/github_token 2>/dev/null || echo '')";
  # etc.
};
```

## Static Configuration

These variables are set directly in configuration, not from secrets.

| Variable            | Value                                           | Purpose                        |
| ------------------- | ----------------------------------------------- | ------------------------------ |
| `SOPS_AGE_KEY_FILE` | `~/.config/sops/age/yubikey-identity.txt`       | Yubikey age identity for sops  |
| `OLLAMA_HOST`       | `http://127.0.0.1:11434`                        | Local Ollama server endpoint   |

## MCP Server Environment

MCP servers inherit environment variables from the parent shell process. The loading order is:

1. **sops-nix** decrypts secrets to `/run/secrets/` at system activation
2. **home-manager** sets `sessionVariables` when shell initializes
3. **OpenCode/Claude Desktop** launch MCP servers, which inherit the shell environment

### Troubleshooting

If an MCP server can't access an API key:

1. Verify the secret exists: `ls -la /run/secrets/api_keys/`
2. Verify it's readable: `cat /run/secrets/api_keys/<name>`
3. Check the env var is set: `echo $VARIABLE_NAME`
4. Restart the AI client to pick up new environment

## Adding New API Keys

1. Add encrypted secret to `secrets/secrets.yaml`:
   ```bash
   SOPS_AGE_KEY_FILE=~/.config/sops/age/yubikey-identity.txt sops secrets/secrets.yaml
   ```

2. Declare in `modules/darwin/secrets.nix`:
   ```nix
   sops.secrets."api_keys/new_key" = { owner = "john"; mode = "0400"; };
   ```

3. Export in `modules/home/ai/environment.nix`:
   ```nix
   NEW_API_KEY = "$(cat /run/secrets/api_keys/new_key 2>/dev/null || echo '')";
   ```

4. Apply configuration:
   ```bash
   darwin-rebuild switch --flake .
   ```
