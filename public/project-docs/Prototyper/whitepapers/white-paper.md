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
- `DATABASE.md` — persistence contract: every store (SQLite schema, `.env` keys, file stores, external services) and the typed class that encapsulates each
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

After the initial build, changes flow through the specification — never through ad-hoc code edits.
`iterate.sh <Project> [TargetDir] <Action> <Scope> "<Change>"` runs a single Claude session that
edits the specification and applies the change to code. Action BOTH (default) does both; SPEC edits
the specification only; TGT is a code-only hotfix. Editing a base file (DATABASE, ARCHITECTURE)
dirties a downstream feature only when its typed access interface changed, and dirties screens only
when a feature's provided routes changed — so unaffected phases are never rebuilt. The Scope argument
resolves a URL path, a keyword, or a filename to the right spec file; TargetDir auto-resolves from the
last build.

For projects whose scope is small but uncertain, the **Agile Team Oneshot** mode delegates the build
to an AI team and keeps you as product owner, reviewing spikes and stories through a per-project
Console. See the *Agile Team Oneshot* paper.

Quality tools keep things on track: `scorecard.sh` measures specification-to-code alignment, and
`spec_iterate.sh` identifies specification gaps.

## Promotion

When a prototype is ready, `merge.sh` squash-merges the feature branch into the base branch.
`ProjectValidate.sh` checks compliance against maturity-level rules (IDEA → PROTOTYPE → ACTIVE →
PRODUCTION). `ProjectUpdate.sh` propagates the latest rules and templates to promoted projects.

<div id="wp-workflows"></div>
