# OpenCode TUI configuration
# https://opencode.ai/docs/
{
  config,
  pkgs,
  lib,
  ...
}:

let
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
    # Agents are specialized AI assistants for specific tasks
    # Primary agents: build, plan (switch with Tab)
    # Subagents: general, explore, deep-thinker, no-dumb-questions, nix-expert, docs-writer (invoke with @)
    agent = {
      # --------------------------------------------------------
      # Primary Agents (Tab to switch)
      # --------------------------------------------------------

      # Primary build agent - uses Claude Pro subscription
      build = {
        mode = "primary";
        model = "anthropic/claude-opus-4-5";
        description = "Primary build agent using Claude Opus 4.5 via Claude Pro subscription";
      };

      # Planning agent - uses Claude via Antigravity for thinking
      plan = {
        mode = "primary";
        model = "google/claude-opus-4-5-thinking-medium";
        description = "Planning agent using Claude Opus 4.5 with thinking via Antigravity";
        tools = {
          write = false;
          edit = false;
          bash = false;
        };
      };

      # --------------------------------------------------------
      # Subagents (invoke with @agent-name)
      # --------------------------------------------------------

      # General-purpose subagent - free tier
      general = {
        mode = "subagent";
        model = "opencode/glm-4.7-free";
        description = "General-purpose subagent using GLM 4.7 via OpenCode Zen (free)";
      };

      # Fast codebase exploration - free tier
      explore = {
        mode = "subagent";
        model = "opencode/glm-4.7-free";
        description = "Fast codebase exploration using GLM 4.7 via OpenCode Zen (free)";
      };

      # Deep reasoning subagent
      deep-thinker = {
        mode = "subagent";
        model = "opencode/gpt-5.1-codex-max";
        description = "Deep reasoning agent using GPT-5.1 Codex Max via OpenCode Zen";
      };

      # Quick questions subagent - free tier
      no-dumb-questions = {
        mode = "subagent";
        model = "opencode/big-pickle";
        description = "Quick questions agent using Big Pickle via OpenCode Zen (free)";
      };

      # Nix configuration expert
      nix-expert = {
        mode = "subagent";
        model = "opencode/gpt-5.1-codex-max";
        description = "Nix/NixOS/nix-darwin/home-manager specialist";
        prompt = ''
          You are a Nix expert specializing in:
          - nix-darwin module development
          - home-manager configurations
          - Flake-based setups
          - NixOS options and services

          Always:
          - Use lib.mkOption with proper types for module options
          - Use lib.mkIf for conditional configuration
          - Use lib.mkEnableOption for boolean enable flags
          - Follow nixfmt-rfc-style formatting conventions
          - Use the mcp-nixos tools for documentation lookups when needed

          When writing modules, follow patterns from modules/darwin/services/*.nix
        '';
      };

      # Documentation writer
      docs-writer = {
        mode = "subagent";
        model = "opencode/glm-4.7-free";
        description = "Technical documentation and markdown specialist";
        prompt = ''
          You are a technical documentation writer. Create clear, concise docs.

          For this nix-darwin/home-manager repository:
          - Document options with types, defaults, and examples
          - Use proper markdown formatting
          - Follow the style of existing documentation
          - Include code examples with proper Nix syntax

          Keep documentation minimal but complete.
        '';
        tools = {
          write = true;
          edit = true;
          bash = false;
        };
      };

      # --------------------------------------------------------
      # Local Inference Subagents (Mac Studio M3 Ultra 256GB)
      # --------------------------------------------------------

      # Local code builder - draft code quickly on local hardware
      local-builder = {
        mode = "subagent";
        model = "ollama/qwen3-coder:30b";
        description = "Local code builder using Qwen3-Coder 30B on M3 Ultra";
        prompt = ''
          You are a local code generation assistant running on a Mac Studio M3 Ultra.
          Your role is to draft code implementations quickly and efficiently.

          Guidelines:
          - Write complete, working implementations
          - Follow the patterns established in this codebase
          - Include comments for complex logic
          - Your output may be reviewed by a cloud model, so focus on functionality
          - For Nix code, follow nixfmt-rfc-style conventions
        '';
      };

      # Local deep analysis using the largest local model
      local-analyst = {
        mode = "subagent";
        model = "ollama/devstral:123b";
        description = "Deep code analysis using Devstral-2 123B locally";
        prompt = ''
          You are a code analysis expert running locally on powerful hardware.
          Perform thorough analysis of code structure, patterns, and potential issues.

          Focus on:
          - Architecture and design patterns
          - Potential bugs or edge cases
          - Performance considerations
          - Security implications

          Take your time - quality matters more than speed for analysis tasks.
        '';
        tools = {
          write = false;
          edit = false;
          bash = false;
        };
      };

      # Local reasoning for complex planning using DeepSeek R1
      local-reasoner = {
        mode = "subagent";
        model = "ollama/deepseek-r1:70b";
        description = "Local reasoning agent using DeepSeek R1 70B";
        prompt = ''
          You are a reasoning assistant for complex problem-solving.
          Use chain-of-thought reasoning to break down problems systematically.

          Your strengths:
          - Multi-step logical reasoning
          - Mathematical and algorithmic thinking
          - Planning complex implementations
          - Analyzing tradeoffs and alternatives

          Think step-by-step and show your reasoning process.
        '';
        tools = {
          write = false;
          edit = false;
          bash = false;
        };
      };

      # Cloud reviewer for the build-review pattern
      reviewer = {
        mode = "subagent";
        model = "anthropic/claude-opus-4-5";
        description = "Code reviewer using Claude Opus 4.5 - reviews and refines code";
        prompt = ''
          Review the code or plan provided and offer constructive feedback.

          Focus on:
          - Correctness and potential bugs
          - Best practices and idiomatic patterns
          - Security considerations
          - Suggestions for improvement

          You have edit/write access - apply your suggestions directly when appropriate.
          Be concise but thorough. For Nix code, ensure nixfmt-rfc-style compliance.
        '';
        tools = {
          write = true;
          edit = true;
          bash = false;
        };
      };
    };

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
  # Install OpenCode
  home.packages = with pkgs; [ opencode ];

  # Generate OpenCode configuration
  xdg.configFile."opencode/opencode.json".text = builtins.toJSON opencodeConfig;
}
