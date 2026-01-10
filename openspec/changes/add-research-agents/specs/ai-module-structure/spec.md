# Capability: AI Module Structure

## ADDED Requirements

### Requirement: Dedicated Agent Module

The AI module SHALL provide a dedicated `agents.nix` module for all agent definitions.

#### Scenario: Agent module exists

- **GIVEN** the AI module directory at `modules/home/ai/`
- **WHEN** the module structure is evaluated
- **THEN** `agents.nix` SHALL exist
- **AND** it SHALL define `options.services.agents.enable`
- **AND** it SHALL define `options.services.agents.definitions`

#### Scenario: Agent definitions are accessible

- **GIVEN** agents defined in `agents.nix`
- **WHEN** another module needs agent data
- **THEN** it SHALL access agents via `config.services.agents.definitions`

### Requirement: Client Configuration Isolation

Client-specific configurations SHALL be isolated in a `clients/` subdirectory.

#### Scenario: OpenCode client in subdirectory

- **GIVEN** OpenCode client configuration
- **WHEN** the module structure is evaluated
- **THEN** OpenCode config SHALL be at `modules/home/ai/clients/opencode.nix`
- **AND** it SHALL NOT define agents inline
- **AND** it SHALL consume agents via `config.services.agents.definitions`

#### Scenario: OpenCode consumes shared definitions

- **GIVEN** `clients/opencode.nix` requires agents, skills, and MCP servers
- **WHEN** the module is evaluated
- **THEN** it SHALL consume definitions via:
  - `config.services.agents.definitions` for agents
  - `config.services.skills.definitions` for skills
  - `config.services.mcp.servers` for MCP servers

### Requirement: Unified Module Imports

The `default.nix` SHALL import all AI submodules with the new structure.

#### Scenario: Module import structure

- **GIVEN** the AI module directory
- **WHEN** `default.nix` is evaluated
- **THEN** it SHALL import:
  - `./agents.nix`
  - `./skills.nix`
  - `./mcp.nix`
  - `./environment.nix`
  - `./clients/opencode.nix`
- **AND** it SHALL import `./claude-desktop.nix`
- **AND** it SHALL NOT import `./opencode.nix` from the root level

## MODIFIED Requirements

### Requirement: Claude Desktop Configuration Retained

The `claude-desktop.nix` module SHALL be retained with access to all MCP servers.

**Reason:** Claude Desktop receives all enabled MCP servers via chezmoi bridge; user toggles servers in-app.

#### Scenario: Module retained

- **GIVEN** the file `modules/home/ai/claude-desktop.nix`
- **WHEN** the restructure is complete
- **THEN** the file SHALL exist with preferences configuration
- **AND** `default.nix` SHALL import `./claude-desktop.nix`
- **AND** all enabled MCP servers SHALL be available via `claudeDesktopConfig`

### Requirement: Inline Agent Definitions in opencode.nix

Agent definitions SHALL NOT be embedded in client configuration.

**Reason:** Violates separation of concerns; makes agents harder to share across clients.

#### Scenario: Agents extracted

- **GIVEN** the restructured `clients/opencode.nix`
- **WHEN** the file is evaluated
- **THEN** it SHALL NOT contain agent definition literals
- **AND** it SHALL reference `config.services.agents.definitions`
