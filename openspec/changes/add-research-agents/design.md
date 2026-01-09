# Design: Research Agents Module Architecture

## Context

The AI module at `modules/home/ai/` has grown organically, mixing concerns:
- `opencode.nix` contains both agent definitions and client configuration
- `claude-desktop.nix` is unused but still imported
- No clear separation between coding and research contexts

This change restructures the module while adding research capabilities.

## Goals / Non-Goals

**Goals:**
- Clear separation of concerns (agents, skills, mcp, clients)
- Research agents isolated with `r-` prefix convention
- Cost-optimized model assignments (free -> mid -> premium)
- Theoretical commitments encoded in skills, not duplicated across agents
- Prompt instruction pattern for skill loading

**Non-Goals:**
- Cross-client skill synchronization (future work)
- Multi-vault Obsidian strategy (noted for future)
- Per-agent MCP filtering (not supported by OpenCode)
- Inline skill content in agent prompts (use skill tool instead)

## Decisions

### D1: Module Structure

**Decision:** Restructure to separate agents from client config

```
modules/home/ai/
├── agents.nix          # All agent definitions (coding + research)
├── skills.nix          # All skill definitions (coding + research)
├── mcp.nix             # MCP server definitions (incl. Obsidian servers)
├── clients/
│   ├── opencode.nix    # OpenCode client config (consumes agents, skills, mcp)
│   └── claude-desktop.nix  # Claude Desktop minimal MCP config
├── environment.nix     # Environment variables
└── default.nix         # Imports, enables services
```

**Rationale:** 
- Agents are the primary unit of work; deserve dedicated module
- Skills are cross-cutting; one module with sections
- MCP is already well-structured; keep as-is
- Clients consume agents/skills/mcp; subdirectory clarifies relationship
- Removes unused claude-desktop.nix

**Alternative considered:** Keep flat structure, add `research.nix` -> rejected because 
it would create unclear boundaries between `opencode.nix` and `research.nix`.

### D2: Agent Export Pattern

**Decision:** `agents.nix` exports via `config.services.agents.definitions`

```nix
# agents.nix
options.services.agents = {
  enable = mkEnableOption "Agent definitions";
  definitions = mkOption {
    type = types.attrsOf (types.submodule { ... });
    default = agentDefinitions;
  };
};
```

**Rationale:** Matches existing pattern in `skills.nix` and `mcp.nix`.

### D3: Skill Loading via Prompt Instruction

**Decision:** Agents use prompt instruction "Load skill `research-global` first before responding."

**Rationale:** 
- OpenCode skill tool is reliable
- Avoids content duplication across agent prompts
- Skills can be updated independently of agent prompts
- Subagents have context to call skill tool

### D4: Model Tier Assignment

**Decision:** Cost-optimized tiers based on task complexity

| Tier    | Model                     | Use Case                | Agents            |
| ------- | ------------------------- | ----------------------- | ----------------- |
| Free    | `opencode/glm-4.7-free`     | High-volume, mechanical | r-search, r-lint  |
| Mid     | `google/claude-sonnet-4-5`  | Reliable tool use       | r-edit, r-meta    |
| Premium | `anthropic/claude-opus-4-5` | Deep reasoning          | r-assess, r-think |

**Rationale:** 
- Literature search is high-volume; use free tier
- Linting is mechanical; use free tier
- Critical assessment needs deep reasoning; premium
- Thought partnership needs deep reasoning; premium
- File editing needs reliable tool use; mid tier
- Project synthesis needs competence without deep reasoning; mid tier

### D5: Retain claude-desktop.nix with Minimal Config

**Decision:** Keep `claude-desktop.nix` with a reduced MCP server set for quick tasks

**Minimal MCP set:**
- `time` - Timezone utilities
- `sequential-thinking` - Structured reasoning
- `github` - Repository access
- `context7` - Documentation lookup
- `obsidian-mcp-server` - Vault CRUD operations
- `obsidian-index` - Semantic vault search

**Rationale:** Claude Desktop remains useful for quick tasks while research agents focus on specialized workflows in OpenCode. Eventual deprecation planned but not immediate priority.

### D6: Static AGENTS.md for Obsidian

**Decision:** Use static file, not chezmoi template

**Rationale:**
- Agent names are fixed (r-search, r-lint, etc.)
- Theoretical commitments are stable
- No computed values from Nix needed
- Can add templating later if needed

### D7: Obsidian MCP Integration

**Decision:** Use dual Obsidian MCP servers for complementary capabilities

| Server              | Type      | Purpose                            |
| ------------------- | --------- | ---------------------------------- |
| obsidian-mcp-server | local-npx | CRUD, search, frontmatter/tags     |
| obsidian-index      | local-uvx | Semantic search via embeddings     |

**Configuration:**
- Vault path: Derived from `config.home.homeDirectory` + `/Notes/obsidian/robinson`
- API key: Bitwarden → chezmoi injection (per-host keys in "Obsidian Keys" secret)
- Database: `${vaultPath}/.obsidian-index.db` (in vault directory)
- Both servers available in Claude Desktop and OpenCode

**Rationale:**
- obsidian-mcp-server provides reliable CRUD via Local REST API plugin
- obsidian-index adds semantic search for conceptual discovery
- Complementary capabilities without overlap
- Previous mcp-tools plugin appears unmaintained (404 on GitHub)

## Data Flow

```
agents.nix                    skills.nix                    mcp.nix
     |                             |                            |
     v                             v                            v
config.services.agents      config.services.skills      config.services.mcp
     |                             |                            |
     +-----------------------------+----------------------------+
                                   |
                                   v
                        clients/opencode.nix
                                   |
                                   v
                          chezmoi-bridge.nix
                                   |
                                   v
                          chezmoidata.json
                                   |
                                   v
                        opencode.json.tmpl
```

## Risks / Trade-offs

| Risk                          | Mitigation                                                      |
| ----------------------------- | --------------------------------------------------------------- |
| Breaking import paths         | Update `default.nix` imports; test with `nix flake check`         |
| Skill loading compliance      | Research agents have `bash=false`; can't bypass instructions      |
| Memory MCP data location      | Existing config uses `~/Utility/mcp-memory/memory.jsonl`; keep    |
| Agent prompt verbosity        | Keep prompts focused; detailed guidance in skills                |
| Model availability            | All models verified in existing opencode.json.tmpl               |

## Migration Plan

1. Create `agents.nix` with existing coding agents + new research agents
2. Create `clients/` directory and move `opencode.nix` there
3. Update `opencode.nix` to consume `config.services.agents`
4. Add research skills to `skills.nix`
5. Add MCP servers to `mcp.nix`; enable memory
6. Update `default.nix` imports; remove claude-desktop.nix
7. Create `chezmoi/dot_Notes/obsidian/robinson/AGENTS.md`
8. Validate with `nix flake check`
9. Deploy with `apply` then `chezmoi apply`

## Open Questions

None - all clarified during proposal phase.

## Future Considerations

Documented for later implementation:
- Conversation review feature (`/review` command)
- Dual-model pipeline for literature (cheap discovery -> quality evaluation)
- Zotero MCP if switching from Paperpile
- RAG with Docling + Milvus for semantic paper search
- opencode-obsidian plugin for embedded experience
- Telekasten migration for multi-vault research/tinkering separation
