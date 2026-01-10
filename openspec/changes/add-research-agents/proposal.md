# Change: Add Research Agents for Doctoral HCI/STS Work

## Why

Doctoral research in HCI/STS requires specialized AI assistance for literature discovery,
critical assessment, and conceptual brainstorming. Current AI module infrastructure
supports coding workflows but lacks research-focused agents with appropriate model
tiers, theoretical commitments, and tool constraints.

Additionally, the current `modules/home/ai/` structure mixes concerns (agents embedded
in client config) and includes unused components (claude-desktop.nix). A restructure
will provide cleaner separation and easier extensibility.

## What Changes

### Module Restructure (BREAKING)

- Extract agent definitions from `opencode.nix` into dedicated `agents.nix`
- Move `opencode.nix` to `clients/opencode.nix` (client-specific config)
- Retain `claude-desktop.nix` with all MCP servers via chezmoi bridge
- Update `default.nix` imports for new structure

### Research Agents (6 new subagents with `r-` prefix)

| Agent    | Purpose                    | Model                       | Tier    | Tools                                     |
| -------- | -------------------------- | --------------------------- | ------- | ----------------------------------------- |
| r-search | Literature discovery       | `opencode/glm-4.7-free`     | Free    | `{ write=false; edit=false; bash=false }` |
| r-lint   | Citation/grammar fixes     | `opencode/glm-4.7-free`     | Free    | `{ write=true; edit=true; bash=false }`   |
| r-assess | Critical review            | `anthropic/claude-opus-4-5` | Premium | `{ write=false; edit=false; bash=false }` |
| r-edit   | Note refactoring           | `google/claude-sonnet-4-5`  | Mid     | `{ write=true; edit=true; bash=false }`   |
| r-think  | Conceptual brainstorming   | `anthropic/claude-opus-4-5` | Premium | `{ write=false; edit=false; bash=false }` |
| r-meta   | Project overview/synthesis | `google/claude-sonnet-4-5`  | Mid     | `{ write=false; edit=false; bash=false }` |

### Research Skills (4 new skills)

| Skill             | Purpose                               | Word Limit |
| ----------------- | ------------------------------------- | ---------- |
| research-global   | Terminology + theoretical commitments | ~250       |
| literature-search | Multi-source paper discovery strategy | ~150       |
| critical-review   | Assessment framework                  | ~150       |
| editing-style     | Obsidian/markdown conventions         | ~150       |

### MCP Servers

| Server              | Action | Type      | Command | Purpose                         |
| ------------------- | ------ | --------- | ------- | ------------------------------- |
| docling-mcp         | ADD    | local-uvx | uvx     | PDF to structured JSON          |
| paper-search-mcp    | ADD    | local-npx | npx     | arXiv, PubMed, Semantic Scholar |
| memory              | ENABLE | local-npx | npx     | Cross-session knowledge         |
| obsidian-mcp-server | ADD    | local-npx | npx     | Vault CRUD via Local REST API   |
| obsidian-index      | ADD    | local-uvx | uvx     | Semantic search via embeddings  |

### Claude Desktop Configuration

Retain `claude-desktop.nix` with access to all enabled MCP servers. User toggles individual servers in-app as needed. No Nix-level filtering required.

### Obsidian Integration

- ADD `chezmoi/dot_Notes/obsidian/robinson/AGENTS.md` (static vault context file)

## Impact

- **Affected modules:** `modules/home/ai/*` (full restructure)
- **Affected configs:** `~/.config/opencode/opencode.json`, chezmoidata.json
- **Breaking:** Import paths change; `claude-desktop.nix` retained with all MCP servers
- **Cost model:** 2 free + 2 mid + 2 premium tier agents

## Success Criteria

- [ ] `nix flake check` passes
- [ ] 6 research agents accessible via `@r-*` prefix in OpenCode
- [ ] 4 research skills loadable via skill tool
- [ ] docling-mcp, paper-search-mcp active; memory enabled
- [ ] AGENTS.md deployed to Obsidian vault via chezmoi
- [ ] Claude Desktop receives all enabled MCP servers via chezmoi bridge
- [ ] Obsidian MCP servers (obsidian-mcp-server, obsidian-index) active in both clients
- [ ] Existing coding agents/skills/MCP unaffected

## Related Specs

- `specs/ai-module-structure/` - Module restructure requirements
- `specs/research-agents/` - Agent definitions and behaviors
- `specs/research-skills/` - Skill content requirements
- `specs/mcp-servers/` - Server configurations
