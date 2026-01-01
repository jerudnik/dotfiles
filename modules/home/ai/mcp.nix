# Unified MCP (Model Context Protocol) servers configuration
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

  # ============================================================
  # MCP Server Definitions
  # ============================================================
  # Define all your MCP servers here.
  #
  # Deployment strategies:
  #   - "remote"    : Third-party hosted SSE endpoints (context7, exa)
  #   - "local-nix" : Stable Nix packages from nixpkgs (github-mcp-server)
  #   - "local-npx" : Official TypeScript MCP servers via npx (filesystem, memory, sequential-thinking)
  #   - "local-uvx" : Python tools via uvx (decoupled from nixpkgs churn)
  #
  # Prefer official TypeScript implementations via npx when available.
  # Use local-uvx for Python tools where nixpkgs lags behind upstream.
  #
  # Fields:
  #   package     = pkgs.* (for local-nix servers)
  #   command     = "npx" | "uvx" (for local servers)
  #   type        = "remote" | "local"
  #   args        = [ ... ] (optional, for local servers)
  #   env         = { VAR = "value"; } (optional, for local servers)
  #   headers     = { HEADER = "value"; } (optional, for remote servers)
  #   url         = "https://..." (required for remote servers)
  #   description = "Human-readable description"

  mcpServerDefinitions = {
    # --------------------------------------------------------
    # Remote MCP Servers (SSE endpoints)
    # --------------------------------------------------------

    # Context7 - Documentation search for libraries and frameworks
    # Usage: Add "use context7" to your prompts
    # API key provides higher rate limits (optional, loaded from environment)
    context7 = {
      type = "remote";
      url = "https://mcp.context7.com/mcp";
      # OpenCode uses {env:VAR} syntax to read from environment at runtime
      headers = {
        CONTEXT7_API_KEY = "{env:CONTEXT7_API_KEY}";
      };
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
    # Local MCP Servers
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
    # Official TypeScript implementation from @modelcontextprotocol/server-filesystem
    # Directories are passed as CLI arguments (multiple allowed)
    filesystem = {
      type = "local";
      command = "npx";
      args = [
        "-y"
        "@modelcontextprotocol/server-filesystem"
        "${config.home.homeDirectory}/Projects"
        "${config.home.homeDirectory}/Notes"
      ];
      description = "Local filesystem access (Projects & Notes directories)";
    };

    # Git - Git repository operations
    # No official npm server published yet; use uvx Python server
    git = {
      type = "local";
      command = "uvx";
      args = [ "mcp-server-git" ];
      description = "Git repository operations";
    };

    # Memory - Persistent memory/knowledge graph
    # Official TypeScript implementation from @modelcontextprotocol/server-memory
    # Uses MEMORY_FILE_PATH env var for custom storage location
    memory = {
      type = "local";
      command = "npx";
      args = [
        "-y"
        "@modelcontextprotocol/server-memory"
      ];
      env = {
        MEMORY_FILE_PATH = "${config.home.homeDirectory}/Utility/mcp-memory/memory.jsonl";
      };
      description = "Persistent memory and knowledge graph";
    };

    # GitHub - GitHub API integration
    # Requires: GITHUB_PERSONAL_ACCESS_TOKEN in environment (set by environment.nix)
    # Server inherits env vars from shell - do NOT set env here (OpenCode doesn't expand $VAR)
    github = {
      type = "local";
      package = pkgs.github-mcp-server;
      args = [ "stdio" ];
      description = "GitHub API integration";
    };

    # NixOS - NixOS/Nix documentation and options search
    # Deployed via uvx to avoid nixpkgs python3Packages.mcp breakage
    nixos = {
      type = "local";
      command = "uvx";
      args = [ "mcp-nixos" ];
      description = "NixOS documentation and options search";
    };

    # Sequential Thinking - Chain-of-thought reasoning
    # Official TypeScript implementation from @modelcontextprotocol/server-sequential-thinking
    sequential-thinking = {
      type = "local";
      command = "npx";
      args = [
        "-y"
        "@modelcontextprotocol/server-sequential-thinking"
      ];
      description = "Chain-of-thought reasoning";
    };

    # Time - Time and timezone utilities
    # Deployed via uvx to avoid nixpkgs python3Packages.mcp breakage
    time = {
      type = "local";
      command = "uvx";
      args = [ "mcp-server-time" ];
      description = "Time and timezone utilities";
    };

    # grep.app - GitHub code search across millions of public repos
    # No API key required
    # Deployed via uvx to avoid nixpkgs python3Packages.mcp breakage
    grep-app = {
      type = "local";
      command = "uvx";
      args = [ "grep-mcp" ];
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
  # OpenCode uses: { "mcp": { "name": { type, command: [...], environment, enabled, headers } } }
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
        // (lib.optionalAttrs (server ? headers && server.headers != { }) {
          headers = server.headers;
        })
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
    # Ensure memory storage directory exists across hosts
    home.file."Utility/mcp-memory/.keep" = {
      text = "";
    };

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
