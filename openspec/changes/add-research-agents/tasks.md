# Tasks: Add Research Agents

## Phase 1: Module Restructure

- [x] 1.1 Create `modules/home/ai/agents.nix` with module boilerplate and option definitions
- [x] 1.2 Extract existing coding agents from `opencode.nix` into `agents.nix`
- [x] 1.3 Create `modules/home/ai/clients/` directory
- [x] 1.4 Move `opencode.nix` to `clients/opencode.nix`
- [x] 1.5 Refactor `clients/opencode.nix` to consume `config.services.agents.definitions`
- [x] 1.6 Verify `claude-desktop.nix` retained with preferences; all MCP servers available via bridge
- [x] 1.7 Update `default.nix` imports for new structure
- [x] 1.8 Validate: `nix flake check` passes

## Phase 1.5: Obsidian MCP Integration

- [x] 1.5.1 Add `obsidian-mcp-server` to `mcp.nix`
  - Type: `local-npx`
  - Package: `@cyanheads/obsidian-mcp-server`
  - Env: `OBSIDIAN_API_KEY` (Bitwarden), `OBSIDIAN_BASE_URL` (localhost:27123)
  - Vault path: derived from `config.home.homeDirectory`

- [x] 1.5.2 Add `obsidian-index` to `mcp.nix`
  - Type: `local-uvx`
  - Package: `obsidian-index`
  - Args: `["--vault", vaultPath, "--database", "${vaultPath}/.obsidian-index.db", "--watch"]`

- [x] 1.5.3 Add `OBSIDIAN_API_KEY` to chezmoi Bitwarden injection
  - Bitwarden secret: "Obsidian Keys" with per-host custom fields (just-testing, serious-callers-only, sleeper-service)
  - Note: Secret already configured by user

- [x] 1.5.4 Include both Obsidian servers in OpenCode MCP config

## Phase 2: Research Agents

- [x] 2.1 Add `r-search` agent to `agents.nix`
  - Model: `opencode/glm-4.7-free`
  - Tools: `{ write = false; edit = false; bash = false; }`
  - Prompt: Literature discovery, check paperpile.bib first, suggest by title/author/DOI
- [x] 2.2 Add `r-lint` agent to `agents.nix`
  - Model: `opencode/glm-4.7-free`
  - Tools: `{ write = false; edit = false; bash = false; }`
  - Prompt: Vale integration, terminology enforcement, load editing-style skill
- [x] 2.3 Add `r-assess` agent to `agents.nix`
  - Model: `anthropic/claude-opus-4-5`
  - Tools: `{ write = false; edit = false; bash = false; }`
  - Prompt: Load research-global first, apply theoretical lenses, NO file edits
- [x] 2.4 Add `r-edit` agent to `agents.nix`
  - Model: `google/claude-sonnet-4-5`
  - Tools: `{ write = true; edit = true; bash = false; }`
  - Prompt: Obsidian conventions, load editing-style skill, NO delete operations
- [x] 2.5 Add `r-think` agent to `agents.nix`
  - Model: `anthropic/claude-opus-4-5`
  - Tools: `{ write = false; edit = false; bash = false; }`
  - Prompt: Load research-global first, conceptual brainstorming, store insights in memory
- [x] 2.6 Add `r-meta` agent to `agents.nix`
  - Model: `google/claude-sonnet-4-5`
  - Tools: default (no restrictions for coordination)
  - Prompt: Load research-global first, project synthesis, cross-reference notes and memory

## Phase 3: Research Skills

- [x] 3.1 Add `research-global` skill to `skills.nix` (~250 words)
  - Tags: `["research", "workflow", "coordination"]`
  - Content: Agent delegation, workflow phases, tool integration, best practices
- [x] 3.2 Add `literature-search` skill to `skills.nix` (~150 words)
  - Tags: `["research", "literature", "search"]`
  - Content: Search strategy, database selection, search tools, citation tracking
- [x] 3.3 Add `critical-review` skill to `skills.nix` (~150 words)
  - Tags: `["research", "critical", "assessment"]`
  - Content: Argument assessment, methodology evaluation, evidence quality, feedback categories
- [x] 3.4 Add `editing-style` skill to `skills.nix` (~150 words)
  - Tags: `["research", "writing", "editing"]`
  - Content: Clarity principles, structure checks, common issues, academic conventions

## Phase 4: MCP Servers

- [x] 4.1 Add `docling-mcp` server to `mcp.nix`
  - Type: `local-uvx` (nixpkgs package has broken dependency)
  - Args: `["--from", "docling-mcp", "docling-mcp-server"]`
  - Description: "Convert PDFs to structured JSON"

- [x] 4.2 Add `paper-search-mcp` server to `mcp.nix`
  - Type: `local-npx`
  - Args: `["-y", "@openags/paper-search-mcp"]`
  - Description: "Search arXiv, PubMed, bioRxiv, medRxiv"

- [x] 4.3 Enable `memory` server in `mcp.nix`
  - Removed `enabled = false` line

Note: Obsidian MCP servers (obsidian-mcp-server, obsidian-index) handled in Phase 1.5

## Phase 5: Obsidian Integration

- [x] 5.1 Create `~/Notes/obsidian/robinson/AGENTS.md` (static file)
  - Research context and agent descriptions
  - Slash commands for research workflows
  - Vault conventions and tips

## Phase 6: Validation

- [x] 6.1 Run `nix fmt` - format all changes
- [x] 6.2 Run `nix flake check` - must pass
- [ ] 6.3 Run `apply` - rebuild system configuration
- [ ] 6.4 Run `chezmoi apply` - deploy config to system
- [ ] 6.5 Verify research agents accessible via `@r-*` prefix in OpenCode
- [ ] 6.6 Verify skills loadable via skill tool (`skill research-global`)
- [ ] 6.7 Verify MCP servers active (docling-mcp, paper-search-mcp, memory)
- [ ] 6.8 Verify existing coding agents still work
- [x] 6.9 Validate chezmoi templates render correctly:
  - `chezmoi execute-template --file chezmoi/dot_config/opencode/opencode.json.tmpl`
  - Verify JSON is valid with `jq empty`

## Dependencies

```
Phase 1 (restructure) -> Phase 1.5 (Obsidian MCP) -> Phase 2 (agents) -> Phase 6 (validation)
                                                  -> Phase 3 (skills) ->
                                                  -> Phase 4 (MCP)    ->
                                                  -> Phase 5 (obsidian)->
```

Phase 1.5 must complete before Phase 2-5 (Obsidian servers needed for agent configs).
Phases 2-5 can be done in parallel after Phase 1.5 completes.

## Notes

- 9 existing skills in `skills.nix` preserved, 4 research skills added (total: 13)
- docling-mcp uses uvx instead of nixpkgs due to broken docling-parse dependency
- AGENTS.md placed directly in vault (not via chezmoi) for immediate availability
