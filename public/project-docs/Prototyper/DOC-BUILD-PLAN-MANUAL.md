# Step 2a — build_plan.sh

Analyzes a specification directory and determines whether a phased build is required.
If the assembled prompt would exceed ~80KB, a phased build is recommended and `BUILD_PLAN.md`
must be authored to guide `oneshot_phased.sh`.

## How It Works

`build_plan.sh` estimates the total prompt size by summing all `.md` files in the specification
directory plus any stack files matching the project's `stack:` field. It compares the result
against the 80KB threshold used by `oneshot.sh`.

- **Under threshold** — single-shot build is sufficient; use `oneshot.sh` directly.
- **Over threshold** — phased build recommended; author `BUILD_PLAN.md` in the spec directory,
  then run `oneshot_phased.sh`.

## Usage

```bash
bash bin/build_plan.sh <ProjectName>
```

| Argument | Purpose |
|----------|---------|
| `<ProjectName>` | Specification directory name (resolves under `specification_directory:` from METADATA.md) |

## Output

```
Specification: GAME
Spec directory: ../Specifications/GAME
Estimated prompt size: 112KB (threshold: 80KB)

Prompt size exceeds threshold — phased build recommended.
```

If `BUILD_PLAN.md` already exists, the script reports its location and exits cleanly.

## Authoring BUILD_PLAN.md

Create `BUILD_PLAN.md` in your spec directory. Each `## Phase N: Name` block defines one build
phase consumed by `oneshot_phased.sh`:

```markdown
## Phase 1: Scaffold

specs: DATABASE.md
context: UI-GENERAL.md
copy:
  - RulesEngine/templates/common.sh -> bin/common.sh
  - RulesEngine/templates/common.py -> bin/common.py
instructions: |
  Build the app factory and database schema only.
  Do not create screens yet.
smoke:
  - test -f bin/start.sh
  - "! grep -q nohup bin/start.sh"

## Phase 2: Screens

specs: SCREEN-*.md
context: UI-GENERAL.md
instructions: |
  Build all screens using the scaffolding from Phase 1.
smoke:
  - curl -sf http://localhost:${PORT}/ -o /dev/null
```

| Field | Purpose | Required |
|-------|---------|----------|
| `specs:` | Glob patterns of load-bearing spec files (recency anchor at bottom of prompt) | Yes (unless verify-only) |
| `context:` | Additional context files — METADATA and ARCHITECTURE are always included | No |
| `copy:` | `src -> dst` pairs copied before LLM runs; src relative to Prototyper repo | No |
| `instructions:` | Free-form prose injected into the phase header — tell the LLM what to build | No |
| `smoke:` | Bash commands run after the phase; `${PORT}` substituted; failure aborts build | No |

## Relationship to oneshot.sh

`oneshot.sh` enforces the same 80KB gate automatically. If the assembled prompt exceeds the
threshold and no `BUILD_PLAN.md` exists in the spec directory, `oneshot.sh` exits with an error
directing you to author the plan first. Once `BUILD_PLAN.md` exists, `oneshot.sh` delegates to
`oneshot_phased.sh` automatically.

```
oneshot.sh
  └─ prompt > 80KB → BUILD_PLAN.md exists? → oneshot_phased.sh
                   → BUILD_PLAN.md missing → error: run build_plan.sh first
```

## Examples

```bash
# Check if GAME needs a phased build
bash bin/build_plan.sh GAME

# Then run the phased build
bash bin/oneshot.sh GAME GAME_v6
```
