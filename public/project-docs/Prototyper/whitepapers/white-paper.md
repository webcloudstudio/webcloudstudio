---
title: Ed Barlows Specification Driven Design Methodology
header_title: Build Methodology
eyebrow: Specification Driven Design
subtitle: Best practices for a full life-cycle specification driven design methodology. Describes various workflows and artifacts and integrates an opinionated structured stack of business, design, and technology rules targeting reproducible, supportable, easy-to-develop and easy-to-maintain software.
author: Ed Barlow
studio: Web Cloud Studio
year: 2026
nav_active: white-paper.html
head_scripts: workflows.js
init_js: window.renderAllWorkflowsCompact(document.getElementById('wp-workflows'));
---

## Specification Files

Specification Driven Design separates *what to build* from *how to build it*. The developer writes
concise, structured specification files. An opinionated technology stack and a set of
technology/business rules provide the *how*. A build script assembles everything into a single
prompt that an AI agent executes in one pass.

Each project is defined by a small set of markdown files in a permissioned Specification repository:

- `METADATA.md` — identity, stack, status, manual metadata for the project
- `ARCHITECTURE.md` — mandatory architecture (modules, routes, directory layout...)
- `DATABASE.md` — tables, columns, types (schema only — implementation separate)
- `FUNCTIONALITY.md` — what the application does at a high level
- `SCREEN-*.md` — per-screen: route, layout, interactions
- `FEATURE-*.md` — per-feature: trigger, sequence, reads, writes
- `UI-GENERAL.md` — shared UI patterns across screens

### Technology Rules

A shared rules engine (`CLAUDE_RULES.md`, which is injected and auto-managed in AGENTS.md) provides
structure for agents to build your code: file structure, naming conventions, error handling,
security, commit standards.

Stack files (for example `flask.md`, `sqlite.md`) provide exact implementation patterns the AI
software build agents follow exactly — no creative interpretation.

## Iteration

After the initial build, changes flow through the specification — not through ad-hoc code edits.
Numbered tickets (`SCREEN-NNN-*.md`, `FEATURE-NNN-*.md`, `PATCH-NNN-*.md`) describe focused changes.
The `iterate.sh` script assembles these into an iteration prompt that the AI agent applies to the
existing codebase.

Quality tools keep things on track: `scorecard.sh` measures specification-to-code alignment,
`spec_iterate.sh` identifies specification gaps, and `tran_logger.sh` extracts bugs and ideas from
AI session logs.

## Promotion

When a prototype is ready, `merge.sh` squash-merges the feature branch into the base branch.
`ProjectValidate.sh` checks compliance against maturity-level rules (IDEA → PROTOTYPE → ACTIVE →
PRODUCTION). `ProjectUpdate.sh` propagates the latest rules and templates to promoted projects.

<div id="wp-workflows"></div>
