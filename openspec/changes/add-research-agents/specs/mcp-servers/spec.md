# Capability: MCP Servers for Research

## ADDED Requirements

### Requirement: Document Conversion Server (docling-mcp)

The system SHALL provide a `docling-mcp` MCP server for PDF document conversion.

#### Scenario: Server definition
- **GIVEN** the `docling-mcp` server definition in `mcp.nix`
- **WHEN** evaluated
- **THEN** it SHALL be defined in `mcpServerDefinitions`

#### Scenario: Server configuration
- **GIVEN** the `docling-mcp` server configuration
- **WHEN** evaluated
- **THEN** type SHALL be `"local"`
- **AND** command SHALL be `"uvx"`
- **AND** args SHALL be `["--from=docling-mcp", "docling-mcp-server"]`
- **AND** enabled SHALL be `true`
- **AND** description SHALL indicate PDF to structured JSON conversion capability

#### Scenario: Server availability
- **GIVEN** the MCP server is enabled
- **WHEN** OpenCode loads MCP configuration
- **THEN** `docling-mcp` SHALL be available for document processing
- **AND** it SHALL support local files and URLs

### Requirement: Academic Paper Search Server (paper-search-mcp)

The system SHALL provide a `paper-search-mcp` MCP server for academic paper search.

#### Scenario: Server definition
- **GIVEN** the `paper-search-mcp` server definition in `mcp.nix`
- **WHEN** evaluated
- **THEN** it SHALL be defined in `mcpServerDefinitions`

#### Scenario: Server configuration
- **GIVEN** the `paper-search-mcp` server configuration
- **WHEN** evaluated
- **THEN** type SHALL be `"local"`
- **AND** command SHALL be `"npx"`
- **AND** args SHALL be `["-y", "@openags/paper-search-mcp"]`
- **AND** enabled SHALL be `true`
- **AND** description SHALL indicate multi-source academic search capability

#### Scenario: Search sources
- **GIVEN** the paper-search-mcp server
- **WHEN** invoked for paper search
- **THEN** it SHALL support searching:
  - arXiv
  - PubMed
  - Semantic Scholar
  - Google Scholar
  - bioRxiv

## MODIFIED Requirements

### Requirement: Memory Server Enabled

The memory MCP server SHALL be enabled for cross-session knowledge persistence.

#### Scenario: Server enable state
- **GIVEN** the `memory` server definition in `mcp.nix`
- **WHEN** evaluated
- **THEN** enabled SHALL be `true`
- **AND** the change SHALL be from previous `enabled = false`

#### Scenario: Storage path unchanged
- **GIVEN** the `memory` server configuration
- **WHEN** evaluated
- **THEN** storage path SHALL remain at `~/Utility/mcp-memory/memory.jsonl`
- **AND** existing memory data SHALL be preserved

#### Scenario: Research agent integration
- **GIVEN** memory server is enabled
- **WHEN** research agents store or retrieve knowledge
- **THEN** the memory server SHALL be available
- **AND** r-search SHALL store successful search strategies
- **AND** r-think SHALL store insights for continuity
