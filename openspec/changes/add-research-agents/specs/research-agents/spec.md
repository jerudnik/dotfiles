# Capability: Research Agents

## ADDED Requirements

### Requirement: Literature Research Agent (r-search)

The system SHALL provide a `r-search` subagent for literature discovery.

#### Scenario: Agent definition
- **GIVEN** the `r-search` agent definition in `agents.nix`
- **WHEN** evaluated
- **THEN** mode SHALL be `"subagent"`
- **AND** model SHALL be `"opencode/glm-4.7-free"`
- **AND** description SHALL indicate literature discovery purpose
- **AND** tools SHALL be `{ write = false; edit = false; bash = false; }`

#### Scenario: Paper discovery workflow
- **GIVEN** a user invokes `@r-search` with a research topic
- **WHEN** the agent processes the request
- **THEN** it SHALL check `/Users/jrudnik/Bibliographies/paperpile.bib` via grep BEFORE external search
- **AND** it SHALL suggest papers by title/author/DOI only (no BibTeX formatting)
- **AND** it SHALL store successful search strategies in memory MCP

#### Scenario: Escalation guidance
- **GIVEN** the agent prompt
- **THEN** it SHALL indicate that users should escalate to `@r-assess` for deep paper evaluation

### Requirement: Linting Agent (r-lint)

The system SHALL provide a `r-lint` subagent for mechanical text corrections.

#### Scenario: Agent definition
- **GIVEN** the `r-lint` agent definition in `agents.nix`
- **WHEN** evaluated
- **THEN** mode SHALL be `"subagent"`
- **AND** model SHALL be `"opencode/glm-4.7-free"`
- **AND** description SHALL indicate linting/correction purpose
- **AND** tools SHALL be `{ write = true; edit = true; bash = false; }`

#### Scenario: Vale integration
- **GIVEN** a user invokes `@r-lint` on a markdown file
- **WHEN** the agent processes the request
- **THEN** the prompt SHALL instruct it to run `vale <file>` and interpret output
- **AND** it SHALL enforce domain terminology from `research-global` skill
- **AND** it SHALL load skill `editing-style` for conventions

### Requirement: Assessment Agent (r-assess)

The system SHALL provide a `r-assess` subagent for critical review of arguments.

#### Scenario: Agent definition
- **GIVEN** the `r-assess` agent definition in `agents.nix`
- **WHEN** evaluated
- **THEN** mode SHALL be `"subagent"`
- **AND** model SHALL be `"anthropic/claude-opus-4-5"`
- **AND** description SHALL indicate critical assessment purpose
- **AND** tools SHALL be `{ write = false; edit = false; bash = false; }`

#### Scenario: Skill loading requirement
- **GIVEN** the agent prompt
- **THEN** it SHALL instruct the agent to load skill `research-global` first before responding

#### Scenario: Critical review workflow
- **GIVEN** a user invokes `@r-assess` with text to evaluate
- **WHEN** the agent processes the request
- **THEN** it SHALL apply theoretical lenses (Verbeek, Ihde, Mol, Thévenot, Abend)
- **AND** it SHALL output: strengths, weaknesses, questions, suggestions
- **AND** it SHALL NOT make any file edits under any circumstances

### Requirement: Editing Agent (r-edit)

The system SHALL provide a `r-edit` subagent for note refactoring and organization.

#### Scenario: Agent definition
- **GIVEN** the `r-edit` agent definition in `agents.nix`
- **WHEN** evaluated
- **THEN** mode SHALL be `"subagent"`
- **AND** model SHALL be `"google/claude-sonnet-4-5"`
- **AND** description SHALL indicate note editing purpose
- **AND** tools SHALL be `{ write = true; edit = true; bash = false; }`

#### Scenario: Obsidian editing workflow
- **GIVEN** a user invokes `@r-edit` for note operations
- **WHEN** the agent processes the request
- **THEN** it SHALL follow Obsidian conventions (wikilinks, frontmatter)
- **AND** it SHALL load skill `editing-style` for conventions
- **AND** it SHALL NOT perform delete operations
- **AND** it SHALL NOT use terminal/bash

### Requirement: Thought Partner Agent (r-think)

The system SHALL provide a `r-think` subagent for conceptual brainstorming.

#### Scenario: Agent definition
- **GIVEN** the `r-think` agent definition in `agents.nix`
- **WHEN** evaluated
- **THEN** mode SHALL be `"subagent"`
- **AND** model SHALL be `"anthropic/claude-opus-4-5"`
- **AND** description SHALL indicate conceptual exploration purpose
- **AND** tools SHALL be `{ write = false; edit = false; bash = false; }`

#### Scenario: Skill loading requirement
- **GIVEN** the agent prompt
- **THEN** it SHALL instruct the agent to load skill `research-global` first before responding

#### Scenario: Conceptual exploration workflow
- **GIVEN** a user invokes `@r-think` for theoretical exploration
- **WHEN** the agent processes the request
- **THEN** it SHALL NOT make file edits unless explicitly requested
- **AND** it MAY search for theoretical concepts and fetch papers for discussion
- **AND** it SHALL store insights in memory MCP for continuity

### Requirement: Meta Agent (r-meta)

The system SHALL provide a `r-meta` subagent for project overview and context recovery.

#### Scenario: Agent definition
- **GIVEN** the `r-meta` agent definition in `agents.nix`
- **WHEN** evaluated
- **THEN** mode SHALL be `"subagent"`
- **AND** model SHALL be `"google/claude-sonnet-4-5"`
- **AND** description SHALL indicate project synthesis purpose
- **AND** tools SHALL be `{ write = false; edit = false; bash = false; }`

#### Scenario: Skill loading requirement
- **GIVEN** the agent prompt
- **THEN** it SHALL instruct the agent to load skill `research-global` first before responding

#### Scenario: Project status workflow
- **GIVEN** a user invokes `@r-meta` for project context
- **WHEN** the agent processes the request
- **THEN** it SHALL cross-reference notes and memory for project state
- **AND** it SHALL be read-only with synthesis focus
- **AND** it SHALL provide cross-session context recovery
