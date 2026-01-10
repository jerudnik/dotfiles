# OpenCode TUI configuration
# https://opencode.ai/docs/
{
  config,
  pkgs,
  lib,
  ...
}:

let
  # Import agents from the centralized agents module
  agents = config.services.agents.definitions;

  # OpenCode configuration
  opencodeConfig = {
    "$schema" = "https://opencode.ai/config.json";

    # Disable auto-update (managed via Nix)
    autoupdate = false;

    # Default model via OpenCode Zen
    model = "anthropic/claude-opus-4-5";

    # ============================================================
    # Plugins
    # ============================================================
    # Plugins are loaded from:
    # - npm packages (auto-installed to ~/.cache/opencode/node_modules/)
    # - file:// URLs pointing to local packages
    # - ~/.config/opencode/plugin/ directory
    plugin = [
      # Antigravity Auth - Google OAuth for Gemini/Claude access
      "opencode-antigravity-auth@latest"

      # Markdown table formatter
      "@franlol/opencode-md-table-formatter@latest"

      # Auto-injects typescript types into file reads and provides lookup tools
      "@nick-vi/opencode-type-inject@latest"

      # Dynamic context pruning - optimizes token usage by removing stale tool outputs
      "@tarquinen/opencode-dcp@latest"
    ];

    # ============================================================
    # Permissions
    # ============================================================
    # Granular control over what operations require approval
    permission = {
      edit = "allow";
      webfetch = "allow";
      external_directory = "ask";
      doom_loop = "ask";
      bash = {
        "*" = "ask";

        # Directory navigation and file info
        "ls" = "allow";
        "ls *" = "allow";
        "pwd" = "allow";
        "cd *" = "allow";
        "tree" = "allow";
        "tree *" = "allow";
        "stat *" = "allow";
        "file *" = "allow";
        "which *" = "allow";
        "type *" = "allow";
        "realpath *" = "allow";
        "dirname *" = "allow";
        "basename *" = "allow";

        # File reading
        "cat *" = "allow";
        "head *" = "allow";
        "tail *" = "allow";
        "less *" = "allow";
        "more *" = "allow";
        "bat *" = "allow";

        # Search and text processing
        "find *" = "allow";
        "grep *" = "allow";
        "rg *" = "allow";
        "ag *" = "allow";
        "ack *" = "allow";
        "fd *" = "allow";
        "fzf *" = "allow";
        "wc *" = "allow";
        "sort *" = "allow";
        "uniq *" = "allow";
        "diff *" = "allow";
        "colordiff *" = "allow";
        "comm *" = "allow";
        "cut *" = "allow";
        "awk *" = "allow";
        "sed *" = "allow";
        "tr *" = "allow";
        "xargs *" = "allow";
        "jq *" = "allow";
        "yq *" = "allow";

        # Git operations
        "git *" = "allow";

        # Nix operations
        "nix fmt" = "allow";
        "nix fmt *" = "allow";
        "nix flake check" = "allow";
        "nix flake check *" = "allow";
        "nix flake update" = "allow";
        "nix flake update *" = "allow";
        "nix build *" = "allow";
        "nix develop" = "allow";
        "nix develop *" = "allow";
        "nix eval *" = "allow";
        "nix repl *" = "allow";
        "nixfmt *" = "allow";

        # System info
        "whoami" = "allow";
        "id" = "allow";
        "id *" = "allow";
        "uptime" = "allow";
        "date" = "allow";
        "date *" = "allow";
        "echo *" = "allow";
        "printf *" = "allow";
        "env" = "allow";
        "printenv" = "allow";
        "printenv *" = "allow";
        "uname" = "allow";
        "uname *" = "allow";
        "hostname" = "allow";
        "df *" = "allow";
        "du *" = "allow";
        "free *" = "allow";
        "top *" = "allow";
        "ps *" = "allow";
        "lsof *" = "allow";

        # Network (safe read-only)
        "ping -c *" = "allow";
        "ping *" = "ask";
        "dig *" = "allow";
        "nslookup *" = "allow";
        "host *" = "allow";
        "curl *" = "allow";
        "wget *" = "allow";
        "nc *" = "ask";
        "netcat *" = "ask";
        "ssh *" = "ask";
        "scp *" = "ask";
        "rsync *" = "ask";

        # Destructive/sensitive operations - always ask
        "rm *" = "ask";
        "rmdir *" = "ask";
        "trash *" = "ask";
        "sudo *" = "ask";
        "chmod *" = "ask";
        "chown *" = "ask";
        "chgrp *" = "ask";
        "kill *" = "ask";
        "pkill *" = "ask";
        "killall *" = "ask";
        "mv *" = "ask";
        "cp *" = "ask";
        "ln *" = "ask";
        "mkdir *" = "ask";
      };
    };

    # ============================================================
    # LSP Configuration
    # ============================================================
    lsp = {
      marksman = {
        command = [
          "marksman"
          "server"
        ];
        extensions = [
          ".md"
          ".markdown"
        ];
      };
    };

    # ============================================================
    # Agent Configuration
    # ============================================================
    # Agents imported from centralized agents.nix module
    # Primary agents: build, plan (switch with Tab)
    # Subagents: invoke with @agent-name
    agent = agents;

    # ============================================================
    # Custom Commands (slash commands)
    # ============================================================
    # Invoke with /command-name in the TUI
    # $ARGUMENTS is replaced with any text after the command
    command = {
      # --------------------------------------------------------
      # Nix-Darwin Workflow Commands
      # --------------------------------------------------------

      check = {
        template = ''
          Run `nix flake check` and analyze the output.
          If there are errors or warnings, explain what's wrong and suggest fixes.
          If everything passes, confirm the configuration is valid.
        '';
        description = "Validate the flake configuration";
        agent = "build";
      };

      apply = {
        template = ''
          Apply the nix-darwin configuration:
          1. First run `nix flake check` to validate
          2. If check passes, run `sudo darwin-rebuild switch --flake .`
          3. Report success or diagnose any errors

          Additional context: $ARGUMENTS
        '';
        description = "Build and apply nix-darwin configuration";
        agent = "build";
      };

      update = {
        template = ''
          Update flake inputs:
          1. Run `nix flake update`
          2. Show the diff of flake.lock using `git diff flake.lock`
          3. Summarize what inputs changed and their new versions
        '';
        description = "Update flake inputs and show changes";
        agent = "build";
      };

      # --------------------------------------------------------
      # Development Commands
      # --------------------------------------------------------

      add-mcp = {
        template = ''
          Help add a new MCP server named "$ARGUMENTS" to this configuration:
          1. Determine if it's a local or remote MCP server
          2. Research the server if needed using web search
          3. Add it to modules/home/ai/mcp.nix following existing patterns
          4. If it needs an API key, explain how to add it to sops secrets
        '';
        description = "Add a new MCP server";
        agent = "nix-expert";
      };

      add-package = {
        template = ''
          Add the package "$ARGUMENTS" to this configuration:
          1. Search nixpkgs for the package
          2. Determine the appropriate location:
             - CLI tools go in modules/home/packages.nix
             - GUI apps go in modules/darwin/homebrew.nix as casks
          3. Add it following existing patterns in that file
        '';
        description = "Add a package to the configuration";
        agent = "nix-expert";
      };

      add-service = {
        template = ''
          Create a new launchd service for "$ARGUMENTS":
          1. Create modules/darwin/services/$ARGUMENTS.nix
          2. Follow the pattern from existing services like ollama.nix
          3. Include proper options (enable, port, package, etc.)
          4. Import it in modules/darwin/default.nix
        '';
        description = "Create a new launchd service";
        agent = "nix-expert";
      };

      # --------------------------------------------------------
      # Review Commands
      # --------------------------------------------------------

      review = {
        template = ''
          Review the current git changes:
          1. Show `git diff` for unstaged changes
          2. Show `git diff --cached` for staged changes
          3. Provide a detailed code review focusing on:
             - Correctness and potential bugs
             - Nix best practices
             - Security considerations

          Focus area: $ARGUMENTS
        '';
        description = "Review current git changes";
        agent = "build";
      };

      # --------------------------------------------------------
      # Research Commands
      # --------------------------------------------------------

      research = {
        template = ''
          Start a research workflow for: $ARGUMENTS

          Use the r-meta agent to coordinate:
          1. Plan the research approach
          2. Delegate to appropriate specialist agents
          3. Synthesize findings in the research vault

          Available specialists: r-search (literature), r-lint (style), r-assess (critique), r-edit (polish), r-think (synthesis)
        '';
        description = "Start a coordinated research workflow";
        agent = "r-meta";
      };

      lit-search = {
        template = ''
          Search for academic literature on: $ARGUMENTS

          Use paper-search-mcp tools to find relevant papers.
          Provide structured results with citations.
        '';
        description = "Search academic literature";
        agent = "r-search";
      };
    };

    # ============================================================
    # Provider Configuration
    # ============================================================
    provider = {
      # OpenCode Zen - reads API key from environment variable
      # OPENCODE_API_KEY is set in environment.nix from sops secret
      opencode = {
        options = {
          apiKey = "{env:OPENCODE_API_KEY}";
        };
      };

      # Google via Antigravity - Gemini and Claude models
      # Authenticated via opencode-antigravity-auth plugin
      google = {
        models = {
          # Gemini 3 Pro variants
          "gemini-3-pro-low" = {
            name = "Gemini 3 Pro Low (Antigravity)";
            limit = {
              context = 1048576;
              output = 65535;
            };
            modalities = {
              input = [
                "text"
                "image"
                "pdf"
              ];
              output = [ "text" ];
            };
          };
          "gemini-3-pro-high" = {
            name = "Gemini 3 Pro High (Antigravity)";
            limit = {
              context = 1048576;
              output = 65535;
            };
            modalities = {
              input = [
                "text"
                "image"
                "pdf"
              ];
              output = [ "text" ];
            };
          };
          "gemini-3-flash" = {
            name = "Gemini 3 Flash (Antigravity)";
            limit = {
              context = 1048576;
              output = 65536;
            };
            modalities = {
              input = [
                "text"
                "image"
                "pdf"
              ];
              output = [ "text" ];
            };
          };

          # Claude Sonnet 4.5 variants via Antigravity
          "claude-sonnet-4-5" = {
            name = "Claude Sonnet 4.5 (Antigravity)";
            limit = {
              context = 200000;
              output = 64000;
            };
            modalities = {
              input = [
                "text"
                "image"
                "pdf"
              ];
              output = [ "text" ];
            };
          };
          "claude-sonnet-4-5-thinking-low" = {
            name = "Claude Sonnet 4.5 Thinking Low (Antigravity)";
            limit = {
              context = 200000;
              output = 64000;
            };
            modalities = {
              input = [
                "text"
                "image"
                "pdf"
              ];
              output = [ "text" ];
            };
          };
          "claude-sonnet-4-5-thinking-medium" = {
            name = "Claude Sonnet 4.5 Thinking Medium (Antigravity)";
            limit = {
              context = 200000;
              output = 64000;
            };
            modalities = {
              input = [
                "text"
                "image"
                "pdf"
              ];
              output = [ "text" ];
            };
          };
          "claude-sonnet-4-5-thinking-high" = {
            name = "Claude Sonnet 4.5 Thinking High (Antigravity)";
            limit = {
              context = 200000;
              output = 64000;
            };
            modalities = {
              input = [
                "text"
                "image"
                "pdf"
              ];
              output = [ "text" ];
            };
          };

          # Claude Opus 4.5 variants via Antigravity
          "claude-opus-4-5-thinking-low" = {
            name = "Claude Opus 4.5 Thinking Low (Antigravity)";
            limit = {
              context = 200000;
              output = 64000;
            };
            modalities = {
              input = [
                "text"
                "image"
                "pdf"
              ];
              output = [ "text" ];
            };
          };
          "claude-opus-4-5-thinking-medium" = {
            name = "Claude Opus 4.5 Thinking Medium (Antigravity)";
            limit = {
              context = 200000;
              output = 64000;
            };
            modalities = {
              input = [
                "text"
                "image"
                "pdf"
              ];
              output = [ "text" ];
            };
          };
          "claude-opus-4-5-thinking-high" = {
            name = "Claude Opus 4.5 Thinking High (Antigravity)";
            limit = {
              context = 200000;
              output = 64000;
            };
            modalities = {
              input = [
                "text"
                "image"
                "pdf"
              ];
              output = [ "text" ];
            };
          };

          # GPT-OSS via Antigravity
          "gpt-oss-120b-medium" = {
            name = "GPT-OSS 120B Medium (Antigravity)";
            limit = {
              context = 131072;
              output = 32768;
            };
            modalities = {
              input = [
                "text"
                "image"
                "pdf"
              ];
              output = [ "text" ];
            };
          };
        };
      };

      # Local Ollama integration
      ollama = {
        npm = "@ai-sdk/openai-compatible";
        name = "Ollama (local)";
        options = {
          baseURL = "http://localhost:11434/v1";
        };
        models = {
          # Models are auto-detected, but specific ones can be configured here
        };
      };
    };

    # MCP servers - from unified config in mcp.nix
    mcp = config.services.mcp.opencode;
  };
in
{
  # OpenCode is installed via `nix profile install github:sst/opencode`
  # The flake overlay causes source builds which fail due to bun sandbox issues.
  # Until upstream fixes their binary cache or bun lockfile, use profile install.
  #
  # To update: nix profile upgrade opencode
  # To install: nix profile install github:sst/opencode

  # Configuration is managed by chezmoi via chezmoi-bridge.nix
  # Template at: chezmoi/dot_config/opencode/opencode.json.tmpl
}
