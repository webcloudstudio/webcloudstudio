# Specification Driven Design

A methodology for building software from structured specifications using AI agents.

## Core Idea

You write concise specification files describing what to build. An opinionated
technology stack and business rules define how to build it. A script assembles
everything into a single prompt. The AI builds the application in one pass.

The specification directory is the source of truth. The code is a derived artifact.

## The Pipeline

```
Setup → OneShot → Merge → Automate
```

1. **Setup** — Scaffold specification files from templates, or reverse-engineer an existing project
2. **OneShot** — Validate, assemble, and build; `oneshot_phased.sh` rebuilds only phases whose spec hashes changed; `iterate.sh` edits a spec and re-applies it to code
3. **Merge** — Squash-merge the feature branch into the base branch
4. **Automate** — AI-scored gap analysis feeds back into the pipeline

## What Makes It Work

**Structured inputs.** Each file type has a defined format — tables and bullets, not prose.
The AI agent knows exactly what to expect.

**Opinionated stack.** Prescriptive patterns per technology (`flask.md`, `sqlite.md`, etc.)
eliminate ambiguity. The AI copies patterns, not interprets guidelines.

**Rules engine.** `CLAUDE_RULES.md` defines agent behavior across all projects — file
structure, naming, error handling, security. Every project gets the same contract.

**Traceability.** Every phase records the spec and code commit plus a content hash per input
spec file. Re-running rebuilds only the phases whose specs changed; scorecards track drift
between specification and code.

## When to Use It

Best for small-to-medium applications built on a known stack. The methodology assumes
the AI can build the entire application from the specification in one pass, then
iterate on it with `iterate.sh` — one claude session that edits the spec and applies
the change to code. Complex multi-service architectures or unfamiliar technology stacks
need a different approach.

## When the Spec Has Unknowns — the Developer Console

When scope is small but uncertainty is high, the **Agile Team Oneshot** mode runs instead.
`build_plan.sh --analysis` splits the spec into spikes (investigate unknowns) and stories
(deliver known work); `oneshot.sh` runs them and stops at a gate. A per-project **Console** —
a config-driven local web app deployed automatically, no build required — shows each ticket
as a Kanban card with its evidence. You Approve, Revise, or Reject; the decision writes
straight back into `AGILE_PLAN.md`. You are the product owner; the LLM is the team.
