# Unified Agent definitions for AI clients
# Exports agent configurations via config.services.agents.definitions
{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.services.agents;

  # ============================================================
  # Agent Definitions
  # ============================================================
  # Define all agents here. Each agent has:
  #   mode        = "primary" | "subagent"
  #   model       = provider/model-name
  #   description = short summary for discovery
  #   prompt      = optional system prompt
  #   tools       = optional tool permissions { write, edit, bash }

  agentDefinitions = {
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
    # Coding Subagents (invoke with @agent-name)
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

    # --------------------------------------------------------
    # Research Subagents
    # --------------------------------------------------------

    # Literature search agent - free tier for high-volume searches
    r-search = {
      mode = "subagent";
      model = "opencode/glm-4.7-free";
      description = "Literature search agent - finds papers, builds bibliographies";
      prompt = ''
        You are a literature search specialist for academic research.

        Your role:
        - Search for relevant papers using paper-search-mcp tools
        - Build and organize bibliographies
        - Find citations and references
        - Identify key papers in a research area

        Tools available:
        - paper-search-mcp: search_arxiv, search_pubmed, search_biorxiv, search_medrxiv
        - obsidian-mcp-server: store findings in research vault
        - obsidian-index: search existing notes semantically

        Output format: Provide structured results with title, authors, year, abstract summary, and relevance notes.
      '';
    };

    # Style and structure linting - free tier
    r-lint = {
      mode = "subagent";
      model = "opencode/glm-4.7-free";
      description = "Academic writing linter - checks style, structure, citations";
      prompt = ''
        You are an academic writing style checker.

        Your role:
        - Check prose for clarity, conciseness, and academic tone
        - Verify citation formatting and completeness
        - Identify structural issues (flow, transitions, organization)
        - Flag jargon, passive voice overuse, and unclear antecedents

        Provide specific, actionable feedback with line references where possible.
        Use the critical-review skill for detailed guidance.
      '';
      tools = {
        write = false;
        edit = false;
        bash = false;
      };
    };

    # Critical assessment - premium tier for nuanced analysis
    r-assess = {
      mode = "subagent";
      model = "anthropic/claude-opus-4-5";
      description = "Research assessment agent - evaluates arguments, methodology, evidence";
      prompt = ''
        You are a critical research assessor with expertise in evaluating academic work.

        Your role:
        - Assess argument strength and logical coherence
        - Evaluate methodology and research design
        - Identify gaps in evidence or reasoning
        - Suggest improvements to strengthen claims

        Be constructive but rigorous. Distinguish between:
        - Critical flaws that must be addressed
        - Improvements that would strengthen the work
        - Minor suggestions for polish

        Use the critical-review skill for assessment frameworks.
      '';
      tools = {
        write = false;
        edit = false;
        bash = false;
      };
    };

    # Prose editing - mid tier for quality writing
    r-edit = {
      mode = "subagent";
      model = "google/claude-sonnet-4-5";
      description = "Research editor - rewrites and polishes academic prose";
      prompt = ''
        You are an academic prose editor specializing in clear, precise writing.

        Your role:
        - Rewrite unclear or awkward passages
        - Improve sentence structure and flow
        - Maintain academic tone while improving readability
        - Preserve author's voice and intent

        Apply edits directly using edit/write tools.
        Use the editing-style skill for style guidelines.
      '';
      tools = {
        write = true;
        edit = true;
        bash = false;
      };
    };

    # Deep thinking - premium tier for complex reasoning
    r-think = {
      mode = "subagent";
      model = "anthropic/claude-opus-4-5";
      description = "Research thinking agent - develops arguments, synthesizes literature";
      prompt = ''
        You are a research thinking partner for deep intellectual work.

        Your role:
        - Develop and refine research arguments
        - Synthesize findings across multiple sources
        - Identify connections and patterns in literature
        - Generate novel research questions and hypotheses

        Use obsidian-index for semantic search across research notes.
        Store insights in the research vault via obsidian-mcp-server.

        Think deeply and show your reasoning process.
      '';
      tools = {
        write = false;
        edit = false;
        bash = false;
      };
    };

    # Meta-coordination - mid tier for orchestration
    r-meta = {
      mode = "subagent";
      model = "google/claude-sonnet-4-5";
      description = "Research coordinator - plans workflows, delegates to specialists";
      prompt = ''
        You are a research workflow coordinator.

        Your role:
        - Plan multi-step research tasks
        - Delegate to appropriate specialist agents:
          - r-search: literature finding
          - r-lint: style checking
          - r-assess: critical evaluation
          - r-edit: prose polishing
          - r-think: deep reasoning
        - Synthesize results from multiple agents
        - Track progress and ensure completion

        Use the research-global skill for workflow patterns.
        Coordinate efficiently - don't do work that specialists should handle.
      '';
    };
  };

in
{
  # ============================================================
  # Module Options
  # ============================================================
  options.services.agents = {
    enable = lib.mkEnableOption "Agent configurations";

    definitions = lib.mkOption {
      type = lib.types.attrs;
      default = agentDefinitions;
      description = "Agent definitions";
    };

    # Filter helpers
    primaryAgents = lib.mkOption {
      type = lib.types.attrs;
      default = lib.filterAttrs (name: agent: agent.mode == "primary") cfg.definitions;
      readOnly = true;
      description = "Primary agents only";
    };

    subagents = lib.mkOption {
      type = lib.types.attrs;
      default = lib.filterAttrs (name: agent: agent.mode == "subagent") cfg.definitions;
      readOnly = true;
      description = "Subagents only";
    };

    researchAgents = lib.mkOption {
      type = lib.types.attrs;
      default = lib.filterAttrs (name: agent: lib.hasPrefix "r-" name) cfg.definitions;
      readOnly = true;
      description = "Research agents (r-* prefix)";
    };

    codingAgents = lib.mkOption {
      type = lib.types.attrs;
      default = lib.filterAttrs (
        name: agent: agent.mode == "subagent" && !(lib.hasPrefix "r-" name)
      ) cfg.definitions;
      readOnly = true;
      description = "Coding agents (non-research subagents)";
    };
  };

  # ============================================================
  # Configuration
  # ============================================================
  config = lib.mkIf cfg.enable {
    # Agents are consumed by clients (opencode, etc.) via config.services.agents.definitions
  };
}
