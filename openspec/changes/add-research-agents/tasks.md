# Tasks: Add Research Agents

## Phase 1: Module Restructure

- [ ] 1.1 Create `modules/home/ai/agents.nix` with module boilerplate and option definitions
- [ ] 1.2 Extract existing coding agents from `opencode.nix` into `agents.nix`
- [ ] 1.3 Create `modules/home/ai/clients/` directory
- [ ] 1.4 Move `opencode.nix` to `clients/opencode.nix`
- [ ] 1.5 Refactor `clients/opencode.nix` to consume `config.services.agents.definitions`
- [ ] 1.6 Update `claude-desktop.nix` with minimal MCP configuration
- [ ] 1.7 Update `default.nix` imports for new structure
- [ ] 1.8 Validate: `nix flake check` passes

## Phase 1.5: Obsidian MCP Integration

- [ ] 1.5.1 Add `obsidian-mcp-server` to `mcp.nix`
  - Type: `local-npx`
  - Package: `@cyanheads/obsidian-mcp-server`
  - Env: `OBSIDIAN_API_KEY` (Bitwarden), `OBSIDIAN_BASE_URL` (localhost:27123)
  - Vault path: derived from `config.home.homeDirectory`

- [ ] 1.5.2 Add `obsidian-index` to `mcp.nix`
  - Type: `local-uvx`
  - Package: `obsidian-index`
  - Args: `["--vault", vaultPath, "--database", "${vaultPath}/.obsidian-index.db", "--watch"]`

- [ ] 1.5.3 Update `chezmoi-bridge.nix` to export `homeDirectory` for vault path templating

- [ ] 1.5.4 Add `OBSIDIAN_API_KEY` to chezmoi Bitwarden injection
  - Bitwarden secret: "Obsidian Keys" with per-host custom fields (just-testing, serious-callers-only, sleeper-service)

- [ ] 1.5.5 Configure Claude Desktop minimal MCP set in `claude-desktop.nix`:
  - time, sequential-thinking, github, context7, obsidian-mcp-server, obsidian-index

- [ ] 1.5.6 Include both Obsidian servers in OpenCode MCP config

## Phase 2: Research Agents

- [ ] 2.1 Add `r-search` agent to `agents.nix`
  - Model: `opencode/glm-4.7-free`
  - Tools: `{ write = false; edit = false; bash = false; }`
  - Prompt: Literature discovery, check paperpile.bib first, suggest by title/author/DOI
  
- [ ] 2.2 Add `r-lint` agent to `agents.nix`
  - Model: `opencode/glm-4.7-free`
  - Tools: `{ write = true; edit = true; bash = false; }`
  - Prompt: Vale integration, terminology enforcement, load editing-style skill
  
- [ ] 2.3 Add `r-assess` agent to `agents.nix`
  - Model: `anthropic/claude-opus-4-5`
  - Tools: `{ write = false; edit = false; bash = false; }`
  - Prompt: Load research-global first, apply theoretical lenses, NO file edits
  
- [ ] 2.4 Add `r-edit` agent to `agents.nix`
  - Model: `google/claude-sonnet-4-5`
  - Tools: `{ write = true; edit = true; bash = false; }`
  - Prompt: Obsidian conventions, load editing-style skill, NO delete operations
  
- [ ] 2.5 Add `r-think` agent to `agents.nix`
  - Model: `anthropic/claude-opus-4-5`
  - Tools: `{ write = false; edit = false; bash = false; }`
  - Prompt: Load research-global first, conceptual brainstorming, store insights in memory
  
- [ ] 2.6 Add `r-meta` agent to `agents.nix`
  - Model: `google/claude-sonnet-4-5`
  - Tools: `{ write = false; edit = false; bash = false; }`
  - Prompt: Load research-global first, project synthesis, cross-reference notes and memory

## Phase 3: Research Skills

- [ ] 3.1 Add `research-global` skill to `skills.nix` (~250 words)
  - Tags: `["research", "theory", "terminology"]`
  - Content: Domain terminology, theoretical commitments, anti-patterns, bibliography location
  
- [ ] 3.2 Add `literature-search` skill to `skills.nix` (~150 words)
  - Tags: `["research", "literature", "search"]`
  - Content: Check paperpile.bib first, multi-source strategy, output format, escalation pattern
  
- [ ] 3.3 Add `critical-review` skill to `skills.nix` (~150 words)
  - Tags: `["research", "assessment", "critique"]`
  - Content: Assessment dimensions, theoretical lenses, output format, analytical vs descriptive
  
- [ ] 3.4 Add `editing-style` skill to `skills.nix` (~150 words)
  - Tags: `["research", "editing", "style"]`
  - Content: Obsidian links, citations, frontmatter, Vale integration, terminology

## Phase 4: MCP Servers

- [ ] 4.1 Add `docling-mcp` server to `mcp.nix`
  - Type: `local-uvx`
  - Args: `["--from=docling-mcp", "docling-mcp-server"]`
  - Description: "Convert PDFs to structured JSON"

- [ ] 4.2 Add `paper-search-mcp` server to `mcp.nix`
  - Type: `local-npx`
  - Args: `["-y", "@openags/paper-search-mcp"]`
  - Description: "Search arXiv, PubMed, Semantic Scholar"

- [ ] 4.3 Enable `memory` server in `mcp.nix`
  - Change `enabled = false` to `enabled = true`

Note: Obsidian MCP servers (obsidian-mcp-server, obsidian-index) handled in Phase 1.5

## Phase 5: Obsidian Integration

- [ ] 5.1 Create `chezmoi/dot_Notes/obsidian/robinson/AGENTS.md` (static file)
  - Research context and agent descriptions
  - Escalation patterns
  - Theoretical commitments summary

## Phase 6: Validation

- [ ] 6.1 Run `nix fmt` - format all changes
- [ ] 6.2 Run `nix flake check` - must pass
- [ ] 6.3 Run `apply` - rebuild system configuration
- [ ] 6.4 Run `chezmoi apply` - deploy AGENTS.md to vault
- [ ] 6.5 Verify research agents accessible via `@r-*` prefix in OpenCode
- [ ] 6.6 Verify skills loadable via skill tool (`skill research-global`)
- [ ] 6.7 Verify MCP servers active (docling-mcp, paper-search-mcp, memory)
- [ ] 6.8 Verify existing coding agents still work

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

- 9 existing skills in `skills.nix` that will need migration consideration
- Current MCP servers: 10 local, 2 remote (see `openspec/project.md` for details)
