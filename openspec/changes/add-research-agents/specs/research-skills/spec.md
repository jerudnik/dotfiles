# Capability: Research Skills

## ADDED Requirements

### Requirement: Research Global Skill

The system SHALL provide a `research-global` skill encoding core theoretical and 
terminological commitments for HCI/STS research.

#### Scenario: Skill metadata
- **GIVEN** the `research-global` skill definition in `skills.nix`
- **WHEN** evaluated
- **THEN** name SHALL be `"research-global"`
- **AND** description SHALL be "Core theoretical and terminological commitments for HCI/STS research"
- **AND** tags SHALL include `"research"`, `"theory"`, `"terminology"`

#### Scenario: Content word limit
- **GIVEN** the skill content
- **THEN** it SHALL be approximately 250 words (200-300 range acceptable)

#### Scenario: Terminology requirements
- **GIVEN** the skill content
- **THEN** it SHALL specify preferred terminology:
  - "older adult" (not "elderly" or "senior")
  - "care constellation" (not "dyad")
  - "family caregiver" (not "informal caregiver")
  - "aging in place" (not "aging at home")

#### Scenario: Theoretical commitments
- **GIVEN** the skill content
- **THEN** it SHALL reference (name-drop, not explain):
  - Technological mediation (Verbeek, Ihde)
  - Moral background (Abend)
  - Tinkering (Mol)
  - Regimes of engagement (Thévenot)

#### Scenario: Anti-patterns
- **GIVEN** the skill content
- **THEN** it SHALL list anti-patterns to avoid:
  - Solutionist framing ("solving aging problems")
  - Acting as IRB reviewer unless explicitly asked
  - Generic HCI advice ("ensure usability")
  - Treating concepts as descriptive labels vs analytical tools

#### Scenario: Bibliography location
- **GIVEN** the skill content
- **THEN** it SHALL specify bibliography location as `/Users/jrudnik/Bibliographies/paperpile.bib`

### Requirement: Literature Search Skill

The system SHALL provide a `literature-search` skill for multi-source paper discovery.

#### Scenario: Skill metadata
- **GIVEN** the `literature-search` skill definition in `skills.nix`
- **WHEN** evaluated
- **THEN** name SHALL be `"literature-search"`
- **AND** description SHALL be "Multi-source paper discovery and bibliography management strategy"
- **AND** tags SHALL include `"research"`, `"literature"`, `"search"`

#### Scenario: Content word limit
- **GIVEN** the skill content
- **THEN** it SHALL be approximately 150 words (100-200 range acceptable)

#### Scenario: Search strategy content
- **GIVEN** the skill content
- **THEN** it SHALL specify:
  - Check paperpile.bib FIRST via grep for existing references
  - Use author names, keywords, citekeys as search launch points
  - Multi-source strategy: arXiv, Semantic Scholar, PubMed, Google Scholar
  - Output format: Suggest by title/author/DOI only
  - Store successful search strategies in memory MCP
  - Escalation: User invokes `@r-assess` for deep paper evaluation

### Requirement: Critical Review Skill

The system SHALL provide a `critical-review` skill for assessing arguments.

#### Scenario: Skill metadata
- **GIVEN** the `critical-review` skill definition in `skills.nix`
- **WHEN** evaluated
- **THEN** name SHALL be `"critical-review"`
- **AND** description SHALL be "Framework for assessing arguments, theoretical framing, and methodological rigor"
- **AND** tags SHALL include `"research"`, `"assessment"`, `"critique"`

#### Scenario: Content word limit
- **GIVEN** the skill content
- **THEN** it SHALL be approximately 150 words (100-200 range acceptable)

#### Scenario: Assessment framework content
- **GIVEN** the skill content
- **THEN** it SHALL specify:
  - Assessment dimensions: logical coherence, theoretical alignment, methodological appropriateness
  - Apply theoretical lenses from research-global skill
  - Output format: strengths, weaknesses, questions to pursue, suggestions
  - Consider: Does this use concepts analytically or merely descriptively?
  - Constraint: NO file edits - assessment only

### Requirement: Editing Style Skill

The system SHALL provide an `editing-style` skill for Obsidian formatting conventions.

#### Scenario: Skill metadata
- **GIVEN** the `editing-style` skill definition in `skills.nix`
- **WHEN** evaluated
- **THEN** name SHALL be `"editing-style"`
- **AND** description SHALL be "Markdown conventions, Obsidian formatting, and Vale integration"
- **AND** tags SHALL include `"research"`, `"editing"`, `"style"`

#### Scenario: Content word limit
- **GIVEN** the skill content
- **THEN** it SHALL be approximately 150 words (100-200 range acceptable)

#### Scenario: Formatting conventions content
- **GIVEN** the skill content
- **THEN** it SHALL specify:
  - Obsidian link format: `[[wikilinks]]` for internal, `[text](url)` for external
  - Citation format: `[@citekey]` for pandoc compatibility
  - Frontmatter: YAML with tags, aliases, created date
  - Vale integration: run `vale <file>` and interpret output
  - Terminology enforcement: defer to research-global skill
