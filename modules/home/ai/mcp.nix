# Unified MCP (Model Context Protocol) servers configuration
# Uses mcp-servers-nix for pre-built packages (no npx at runtime)
# Generates configs for OpenCode, Claude Desktop, and Cursor
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

let
  cfg = config.services.mcp;

  # Get mcp-servers-nix packages for the current system
  # Some packages are now in nixpkgs directly (github-mcp-server, mcp-nixos, etc.)
  mcpPkgs = inputs.mcp-servers-nix.packages.${pkgs.system};

  # ============================================================
  # MCP Server Definitions
  # ============================================================
  # Define all your MCP servers here using mcp-servers-nix packages.
  # These are pre-built Nix packages - no npx/npm at runtime!
  #
  # Fields:
  #   package     = mcpPkgs.mcp-server-* (required for local servers)
  #   type        = "remote" | "local"
  #   args        = [ ... ] (optional, for local servers)
  #   env         = { VAR = "value"; } (optional, for local servers)
  #   url         = "https://..." (required for remote servers)
  #   description = "Human-readable description"

  mcpServerDefinitions = {
    # --------------------------------------------------------
    # Remote MCP Servers (SSE endpoints)
    # --------------------------------------------------------

    # Context7 - Documentation search for libraries and frameworks
    # Usage: Add "use context7" to your prompts
    context7 = {
      type = "remote";
      url = "https://mcp.context7.com/mcp";
      description = "Documentation search for libraries and frameworks";
    };

    # Exa - AI-powered web search and code context
    # Provides web_search_exa and get_code_context_exa tools
    # Requires: EXA_API_KEY in environment
    exa = {
      type = "remote";
      url = "https://mcp.exa.ai/mcp";
      description = "Exa AI web search and code context";
    };

    # --------------------------------------------------------
    # Local MCP Servers (using mcp-servers-nix packages)
    # --------------------------------------------------------

    # Fetch - HTTP fetching capabilities
    # DISABLED: AsyncClient compatibility issue with 'proxies' parameter
    # Alternative: Use webfetch tool or context7 for HTTP requests
    # fetch = {
    #   type = "local";
    #   package = mcpPkgs.mcp-server-fetch;
    #   description = "HTTP fetch capabilities";
    # };

    # Filesystem - Local filesystem access
    filesystem = {
      type = "local";
      package = mcpPkgs.mcp-server-filesystem;
      args = [
        "/Users/john/Projects"
        "/Users/john/Notes"
      ];
      description = "Local filesystem access (Projects and Notes)";
    };

    # Git - Git repository operations
    git = {
      type = "local";
      package = mcpPkgs.mcp-server-git;
      description = "Git repository operations";
    };

    # Memory - Persistent memory/knowledge graph
    memory = {
      type = "local";
      package = mcpPkgs.mcp-server-memory;
      env = {
        MEMORY_FILE_PATH = "/Users/john/Projects/mcp-memory/memory.json";
      };
      description = "Persistent memory and knowledge graph";
    };

    # GitHub - GitHub API integration
    # Requires: GITHUB_PERSONAL_ACCESS_TOKEN in environment
    # Now available in nixpkgs directly
    github = {
      type = "local";
      package = pkgs.github-mcp-server;
      args = [ "stdio" ];
      env = {
        GITHUB_PERSONAL_ACCESS_TOKEN = "$GITHUB_PERSONAL_ACCESS_TOKEN";
      };
      description = "GitHub API integration";
    };

    # NixOS - NixOS/Nix documentation and options search
    # Now available in nixpkgs directly
    nixos = {
      type = "local";
      package = pkgs.mcp-nixos;
      description = "NixOS documentation and options search";
    };

    # Sequential Thinking - Chain-of-thought reasoning
    sequential-thinking = {
      type = "local";
      package = mcpPkgs.mcp-server-sequential-thinking;
      description = "Chain-of-thought reasoning";
    };

    # Time - Time and timezone utilities
    time = {
      type = "local";
      package = mcpPkgs.mcp-server-time;
      description = "Time and timezone utilities";
    };

    # grep.app - GitHub code search across millions of public repos
    # No API key required
    grep-app = {
      type = "local";
      package = pkgs.grep-mcp;
      description = "GitHub code search via grep.app";
    };

    # Serena - Semantic code retrieval and editing via LSP
    # Uses claude-code context (excludes file/shell tools that OpenCode handles)
    # Provides: find_symbol, find_referencing_symbols, rename_symbol,
    #           get_symbols_overview, insert_after_symbol, replace_symbol_body, etc.
    serena = {
      type = "local";
      # Not a Nix package - runs via uvx (uv's package runner)
      command = "uvx";
      args = [
        "--from"
        "git+https://github.com/oraios/serena"
        "serena"
        "start-mcp-server"
        "--context"
        "claude-code"
        "--project-from-cwd"
        "--mode"
        "nix-focused"
      ];
      description = "Semantic code retrieval and editing via LSP";
    };
  };

  # ============================================================
  # Client-specific transformations
  # ============================================================

  # Filter to only enabled servers
  enabledServers = lib.filterAttrs (name: server: server.enabled or true) cfg.servers;

  # Get the command path for a server
  # Supports both Nix packages (server.package) and custom commands (server.command)
  getCommand =
    server:
    if server.type == "remote" then
      null
    else if server ? command then
      server.command
    else
      lib.getExe server.package;

  # Transform for OpenCode format
  # OpenCode uses: { "mcp": { "name": { type, command: [...], environment, enabled } } }
  toOpenCodeFormat =
    servers:
    lib.mapAttrs (
      name: server:
      if server.type == "remote" then
        {
          type = "remote";
          url = server.url;
          enabled = server.enabled or true;
        }
      else
        {
          type = "local";
          # OpenCode wants command as an array: [binary, ...args]
          command = [ (getCommand server) ] ++ (server.args or [ ]);
          enabled = server.enabled or true;
        }
        // (lib.optionalAttrs (server ? env && server.env != { }) {
          environment = server.env;
        })
    ) servers;

  # Transform for Claude Desktop / Cursor format (stdio-based)
  # They use: { "mcpServers": { "name": { command, args, env } } }
  # Note: Only includes servers that have either a package or a command
  toStdioClientFormat =
    servers:
    let
      localServers = lib.filterAttrs (
        name: server: server.type == "local" && (server ? package || server ? command)
      ) servers;
    in
    lib.mapAttrs (
      name: server:
      {
        command = getCommand server;
        args = server.args or [ ];
      }
      // (lib.optionalAttrs (server ? env && server.env != { }) {
        env = server.env;
      })
    ) localServers;

  # Claude Desktop config structure
  claudeDesktopConfig = {
    mcpServers = toStdioClientFormat enabledServers;
  }
  // lib.optionalAttrs (config.services ? claudeDesktop) {
    preferences = {
      menuBarEnabled = config.services.claudeDesktop.preferences.menuBarEnabled;
      quickEntryShortcut = config.services.claudeDesktop.preferences.quickEntryShortcut;
    };
  };

  # Cursor config structure (same format as Claude Desktop)
  cursorConfig = {
    mcpServers = toStdioClientFormat enabledServers;
  };

in
{
  # ============================================================
  # Module Options
  # ============================================================
  options.services.mcp = {
    enable = lib.mkEnableOption "MCP server configurations";

    servers = lib.mkOption {
      type = lib.types.attrs;
      default = mcpServerDefinitions;
      description = "MCP server definitions";
    };

    enableClaudeDesktop = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Generate Claude Desktop MCP configuration";
    };

    enableCursor = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Generate Cursor global MCP configuration";
    };

    # Exported configs for use by other modules
    opencode = lib.mkOption {
      type = lib.types.attrs;
      default = toOpenCodeFormat enabledServers;
      readOnly = true;
      description = "MCP config formatted for OpenCode";
    };

    claudeDesktopConfig = lib.mkOption {
      type = lib.types.attrs;
      default = claudeDesktopConfig;
      readOnly = true;
      description = "Full Claude Desktop config with mcpServers";
    };

    cursorConfig = lib.mkOption {
      type = lib.types.attrs;
      default = cursorConfig;
      readOnly = true;
      description = "Full Cursor config with mcpServers";
    };
  };

  # ============================================================
  # Configuration Generation
  # ============================================================
  config = lib.mkIf cfg.enable {
    # Generate Claude Desktop config if enabled
    # Location: ~/Library/Application Support/Claude/claude_desktop_config.json
    home.file."Library/Application Support/Claude/claude_desktop_config.json" =
      lib.mkIf cfg.enableClaudeDesktop
        {
          text = builtins.toJSON cfg.claudeDesktopConfig;
        };

    # Generate Cursor global config if enabled
    # Location: ~/.cursor/mcp.json
    home.file.".cursor/mcp.json" = lib.mkIf cfg.enableCursor {
      text = builtins.toJSON cfg.cursorConfig;
    };
  };
}
