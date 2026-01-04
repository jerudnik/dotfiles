# Unified Skills configuration
# Mirrors the MCP pattern for reusability across AI clients
# Skills are loaded on-demand to provide context-specific knowledge
{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.services.skills;

  # ============================================================
  # Skill Definitions
  # ============================================================
  # Define skills as structured data. Each skill has:
  #   name        = unique identifier
  #   description = short summary for discovery
  #   tags        = categorization for filtering
  #   content     = markdown content (loaded on-demand)
  #   enabled     = optional, defaults to true

  skillDefinitions = {
    # --------------------------------------------------------
    # Nix Development Skills
    # --------------------------------------------------------

    nix-module = {
      name = "nix-module";
      description = "Guidelines for nix-darwin and home-manager module development";
      tags = [
        "nix"
        "darwin"
        "home-manager"
        "module"
      ];
      content = ''
        ## Module Structure

        ```nix
        { config, pkgs, lib, ... }:
        {
          options.services.myservice = {
            enable = lib.mkEnableOption "My service";
            port = lib.mkOption {
              type = lib.types.port;
              default = 8080;
              description = "Port to listen on";
            };
          };

          config = lib.mkIf config.services.myservice.enable {
            # Configuration when enabled
          };
        }
        ```

        ## Key Patterns

        - **Options**: Use `lib.mkOption` with proper types
        - **Enable flags**: Use `lib.mkEnableOption "description"`
        - **Conditionals**: Use `lib.mkIf` for conditional config
        - **Defaults**: Use `lib.mkDefault` for overridable values
        - **Merging**: Use `lib.mkMerge` for combining configs

        ## File Locations

        | Type | Path |
        |------|------|
        | Darwin modules | `modules/darwin/` |
        | Home modules | `modules/home/` |
        | Services | `modules/darwin/services/` |

        ## Before Committing

        1. Run `nix fmt` to format (treefmt wrapper: nixfmt + prettier)
        2. Run `nix flake check` to validate
      '';
    };

    nix-service = {
      name = "nix-service";
      description = "Creating launchd services with nix-darwin";
      tags = [
        "nix"
        "darwin"
        "launchd"
        "service"
      ];
      content = ''
        ## Service Module Template

        Create `modules/darwin/services/myservice.nix`:

        ```nix
        { config, pkgs, lib, ... }:
        with lib;
        let
          cfg = config.services.myservice;
        in
        {
          options.services.myservice = {
            enable = mkEnableOption "My service";

            host = mkOption {
              type = types.str;
              default = "127.0.0.1";
              description = "Host to bind the service";
            };

            port = mkOption {
              type = types.port;
              default = 8080;
              description = "Port to listen on";
            };

            package = mkOption {
              type = types.package;
              default = pkgs.myservice;
              description = "Package to use";
            };
          };

          config = mkIf cfg.enable {
            launchd.user.agents.myservice = {
              serviceConfig = {
                Label = "com.myservice.daemon";
                ProgramArguments = [
                  "''${cfg.package}/bin/myservice"
                  "--port" (toString cfg.port)
                ];
                RunAtLoad = true;
                KeepAlive = true;
                StandardOutPath = "~/Utility/logs/myservice.log";
                StandardErrorPath = "~/Utility/logs/myservice.error.log";
                EnvironmentVariables = {
                  MY_HOST = cfg.host;
                  MY_PORT = toString cfg.port;
                };
              };
            };

            # For Homebrew-installed apps (fallback when not in nixpkgs):
            # homebrew.casks = [ "myservice" ];
            # Then use: "/Applications/MyService.app/Contents/MacOS/myservice"
          };
        }
        ```

        ## Key serviceConfig Options

        | Option               | Purpose                          |
        |----------------------|----------------------------------|
        | Label                | Unique service identifier (reverse-DNS style) |
        | ProgramArguments     | Command and args (as list)       |
        | RunAtLoad            | Start when agent loads           |
        | KeepAlive            | Restart if process dies          |
        | EnvironmentVariables | Env vars for the process         |
        | StandardOutPath      | Stdout log location              |
        | StandardErrorPath    | Stderr log location              |
        | WorkingDirectory     | Working directory for the daemon |

        ## Integration Steps

        1. Create the module file
        2. Import in `modules/darwin/default.nix`
        3. Enable in host config: `services.myservice.enable = true;`

        ## Notes

        - **Nix packages**: Preferred when available in nixpkgs.
        - **Homebrew fallback**: For macOS GUI apps not in nixpkgs, use
          `homebrew.casks` and reference the app path directly.
        - **Log location**: Use `~/Utility/logs/` for persistent logs.
        - **Label format**: Use reverse-DNS style (e.g., `com.company.service`).
      '';
    };

    nix-style = {
      name = "nix-style";
      description = "Nix code style and formatting conventions";
      tags = [
        "nix"
        "style"
        "formatting"
      ];
      content = ''
        ## Formatting

        - Run `nix fmt` before committing (treefmt wrapper: nixfmt + prettier)
        - Indentation: 2 spaces
        - Trailing commas: Required in sets and lists

        ## Naming Conventions

        | Type | Convention | Example |
        |------|------------|---------|
        | Files | kebab-case | `my-service.nix` |
        | Options | camelCase | `enableFeature` |
        | Packages | kebab-case | `my-package` |

        ## Import Patterns

        ```nix
        # Directory with default.nix
        imports = [ ./subdir ];

        # Specific file
        imports = [ ./specific.nix ];

        # Package lists
        home.packages = with pkgs; [
          package1
          package2
        ];
        ```

        ## Comments

        - Use `#` for inline comments
        - Use `# ====` dividers for major sections
      '';
    };

    # --------------------------------------------------------
    # Secrets Management
    # --------------------------------------------------------

    secrets = {
      name = "secrets-management";
      description = "Managing secrets with sops-nix and Yubikey";
      tags = [
        "secrets"
        "sops"
        "security"
        "yubikey"
      ];
      content = ''
        ## Adding a New Secret

        1. Enter dev shell: `nix develop`

        2. Edit secrets file:
           ```bash
           SOPS_AGE_KEY_FILE=~/.config/sops/age/yubikey-identity.txt \
             sops secrets/secrets.yaml
           ```

        3. Add your secret (YAML structure):
           ```yaml
           api_keys:
             my_service: "secret-value-here"
           ```

        4. Declare in `modules/darwin/secrets.nix`:
           ```nix
           sops.secrets."api_keys/my_service" = { };
           ```

        5. If needed in shell, load in `environment.nix`:
           ```bash
           if [[ -r /run/secrets/api_keys/my_service ]]; then
             export MY_SERVICE_KEY="$(cat /run/secrets/api_keys/my_service)"
           fi
           ```

        ## Accessing Secrets

        | Context | Path |
        |---------|------|
        | Runtime | `/run/secrets/api_keys/my_service` |
        | In configs | `{file:/run/secrets/api_keys/my_service}` |

        ## Security Notes

        - Private key never leaves Yubikey hardware
        - Encrypted `secrets.yaml` is safe to commit
        - Requires physical Yubikey touch to decrypt
      '';
    };

    # --------------------------------------------------------
    # MCP Server Configuration
    # --------------------------------------------------------

    mcp-server = {
      name = "mcp-server";
      description = "Adding and configuring MCP servers";
      tags = [
        "mcp"
        "ai"
        "opencode"
      ];
      content = ''
        ## Adding a Local MCP Server

        In `modules/home/ai/mcp.nix`, add to `mcpServerDefinitions`:

        ```nix
        my-server = {
          type = "local";
          package = pkgs.my-mcp-server;  # or mcpPkgs.mcp-server-*
          args = [ "--flag" "value" ];
          env = {
            MY_API_KEY = "$MY_API_KEY";  # From environment
          };
          description = "What this server does";
          # enabled = false;  # Optional: disable without removing
        };
        ```

        ## Adding a Remote MCP Server

        ```nix
        my-remote = {
          type = "remote";
          url = "https://mcp.example.com/mcp";
          description = "Remote MCP endpoint";
        };
        ```

        ## Custom Command (no Nix package)

        ```nix
        my-custom = {
          type = "local";
          command = "uvx";  # or "npx", "node", etc.
          args = [
            "--from" "git+https://github.com/org/repo"
            "command-name"
          ];
          description = "Custom MCP server";
        };
        ```

        ## Optional Fields

        | Field | Default | Purpose |
        |-------|---------|---------|
        | `enabled` | `true` | Set to `false` to disable temporarily |
        | `args` | `[]` | CLI arguments for local servers |
        | `env` | `{}` | Environment variables |

        ## With API Keys

        1. Add key to sops secrets (see secrets-management skill)
        2. Load in `environment.nix`
        3. Reference as `$ENVVAR` in the `env` block
      '';
    };

    # --------------------------------------------------------
    # Git Workflow
    # --------------------------------------------------------

    git-workflow = {
      name = "git-workflow";
      description = "Git conventions for this repository";
      tags = [
        "git"
        "workflow"
      ];
      content = ''
        ## Commit Message Format

        ```
        module/area: Short description (imperative mood)

        Optional longer description if needed.
        ```

        Examples:
        - `darwin/services: Add whisper transcription service`
        - `home/ai: Configure new MCP server`
        - `flake: Update nixpkgs input`

        ## Pre-Commit Checklist

        1. `nix fmt` - Format all Nix files (treefmt wrapper)
        2. `nix flake check` - Validate configuration
        3. Consider testing with `apply` command

        ## Common Operations

        | Task | Command |
        |------|---------|
        | Format | `nix fmt` |
        | Check | `nix flake check` |
        | Update inputs | `nix flake update` |
        | Apply config | `sudo darwin-rebuild switch --flake .` |
      '';
    };

    # --------------------------------------------------------
    # Repository Structure
    # --------------------------------------------------------

    repo-structure = {
      name = "repo-structure";
      description = "Understanding this dotfiles repository layout";
      tags = [
        "structure"
        "organization"
      ];
      content = ''
        ## Directory Layout

        ```
        flake.nix                    # Entry point - inputs and outputs
        AGENTS.md                    # AI agent guidelines
        docs/                        # Documentation
        scripts/                     # Utility scripts
        hosts/
          common/
            darwin/                  # Shared macOS config
            nixos/                   # Shared NixOS config (placeholder)
          serious-callers-only/      # Host-specific config
        modules/
          base/                      # Cross-platform modules
            stylix.nix               # Theming configuration
          darwin/                    # nix-darwin modules
            services/                # launchd services
            homebrew.nix             # Homebrew casks/formulae
            secrets.nix              # sops-nix secrets
            system.nix               # macOS preferences
          home/                      # home-manager modules
            ai/                      # AI tools (OpenCode, MCP)
            apps/                    # Application configs
            editors/                 # Editor configs (neovim)
            shell/                   # Shell (zsh, starship)
            terminal/                # Terminals (ghostty, wezterm)
            packages.nix             # CLI tools
            git.nix                  # Git configuration
            development.nix          # Dev tools
        users/john/
          default.nix                # User darwin config
          home.nix                   # User home-manager config
        secrets/
          secrets.yaml               # Encrypted secrets
          .sops.yaml                 # sops-nix key configuration
        themes/                      # Stylix themes (modus.nix)
        overlays/                    # Package overlays
        pkgs/                        # Custom packages
        ```

        ## Key Files

        | File | Purpose |
        |------|---------|
        | `flake.nix` | Inputs and outputs |
        | `AGENTS.md` | AI agent guidelines |
        | `modules/home/ai/mcp.nix` | MCP server config |
        | `modules/home/ai/opencode.nix` | OpenCode config |
        | `modules/home/ai/skills.nix` | Skills definitions |
        | `secrets/secrets.yaml` | Encrypted secrets |
      '';
    };

    # --------------------------------------------------------
    # Common Patterns
    # --------------------------------------------------------

    common-patterns = {
      name = "common-patterns";
      description = "Common tasks and patterns in this repository";
      tags = [
        "patterns"
        "howto"
      ];
      content = ''
        ## Adding a Package

        **CLI tool** → `modules/home/packages.nix`:
        ```nix
        home.packages = with pkgs; [
          my-cli-tool
        ];
        ```

        **GUI app (Homebrew cask)** → `modules/darwin/homebrew.nix`:
        ```nix
        homebrew.casks = [
          "my-app"
        ];
        ```

        ## Adding a Service

        1. Create `modules/darwin/services/myservice.nix`
        2. Import in `modules/darwin/default.nix`
        3. Enable: `services.myservice.enable = true;`

        ## Adding an MCP Server

        1. Add definition to `modules/home/ai/mcp.nix`
        2. If needs API key, add to sops + environment.nix
        3. Apply configuration

        ## Testing Changes

        ```bash
        # Validate without applying
        nix flake check

        # Build and apply
        sudo darwin-rebuild switch --flake .
        ```
      '';
    };

    serena-workflow = {
      name = "serena-workflow";
      description = "Best practices for using Serena MCP server tools";
      tags = [
        "serena"
        "mcp"
        "code-intelligence"
        "workflow"
      ];
      content = ''
        # Serena Workflow Best Practices

        ## When to Use Serena
        Use Serena tools when you need semantic code understanding:
        - Finding symbol definitions across files
        - Tracing references to functions/options
        - Understanding module structure before edits
        - Navigating between related Nix expressions

        ## Preferred Tool Order
        1. `get_symbols_overview` - understand file structure first
        2. `find_symbol` - locate specific definitions by name
        3. `find_referencing_symbols` - find all usages
        4. `search_for_pattern` - only when symbolic search is insufficient

        ## Memory Management
        - Check `list_memories` before re-learning project context
        - Use `write_memory` for persistent knowledge (module relationships, conventions)
        - Memories persist in `.serena/memories/` per-project

        ## Nix-Specific Tips
        - The `nix-focused` mode prioritizes `*.nix` files
        - Symbol search works for top-level attributes and functions
        - Use pattern search for inline `let` bindings (not indexed as symbols)

        ## Configuration
        Serena is configured in `modules/home/ai/mcp.nix` with:
        - `--context claude-code` - built-in context for Claude agents
        - `--project-from-cwd` - dynamically resolves project from working directory
        - `--mode nix-focused` - custom mode for Nix patterns

        Project config: `.serena/project.yml`
        Mode definition: `~/.serena/modes/nix-focused.yml`
      '';
    };
  };

  # ============================================================
  # Format Transformers
  # ============================================================

  # Filter to only enabled skills
  enabledSkills = lib.filterAttrs (name: skill: skill.enabled or true) cfg.definitions;

  # Generate SKILL.md with frontmatter for OpenCode
  toOpenCodeSkillMd = name: skill: ''
    ---
    name: ${skill.name}
    description: ${skill.description}
    license: MIT
    compatibility: opencode
    metadata:
      tags: ${builtins.toJSON (skill.tags or [ ])}
    ---

    ${skill.content}
  '';

  # Future: Transform for other clients that may support skills
  # toClaudeDesktopFormat = ...
  # toCursorFormat = ...

in
{
  # ============================================================
  # Module Options
  # ============================================================
  options.services.skills = {
    enable = lib.mkEnableOption "Skills configuration";

    definitions = lib.mkOption {
      type = lib.types.attrs;
      default = skillDefinitions;
      description = "Skill definitions";
    };

    enableOpenCode = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Generate OpenCode skill files";
    };

    # Exported configs for use by other modules
    opencode = lib.mkOption {
      type = lib.types.attrs;
      default = lib.mapAttrs toOpenCodeSkillMd enabledSkills;
      readOnly = true;
      description = "Skills formatted for OpenCode";
    };
  };

  # ============================================================
  # Configuration Generation
  # ============================================================
  config = lib.mkIf cfg.enable {
    # Generate OpenCode skill files if enabled
    # Location: ~/.config/opencode/skill/<name>/SKILL.md
    xdg.configFile = lib.mkIf cfg.enableOpenCode (
      lib.mapAttrs' (
        name: skill:
        lib.nameValuePair "opencode/skill/${name}/SKILL.md" { text = toOpenCodeSkillMd name skill; }
      ) enabledSkills
    );
  };
}
