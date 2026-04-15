# Step 2 — OneShot

Generate AI build prompts from your specification files. For small specifications, one prompt
builds the app in a single pass. For large specifications, the build splits into multiple
phases automatically — each phase gets its own `claude -p` call.

## How It Works

### Single-Shot (Small Specs)

For specifications under ~80KB, `oneshot.sh` validates, then assembles one prompt:

```bash
bash bin/oneshot.sh MyProject > MyProject/oneshot-prompt.md
```

The prompt contains:
- Your specification files (what to build)
- Stack patterns from `RulesEngine/stack/` (how to build it)
- Agent rules from `CLAUDE_RULES.md` (constraints and conventions)

Then pipe it to `claude -p`:
```bash
cat MyProject/oneshot-prompt.md | claude -p --model sonnet
```

Or pass a target directory to run everything automatically:
```bash
bash bin/oneshot.sh MyProject MyTarget  # creates dir, inits git, runs claude -p
```

### Phased Build (Large Specs)

For specifications over ~80KB, the model's attention window can't reliably hold load-bearing
specifications at the tail of a monolithic prompt. The build automatically splits into phases.

`oneshot.sh` detects the size, reads `BUILD_PLAN.md` from your spec directory,
and delegates to `oneshot_phased.sh`:

```bash
bash bin/oneshot.sh GAME GAME_v6  # auto-phases if prompt > 80KB
```

Each phase:
1. Copies scaffolding files (common.sh, common.py, etc.) — no LLM involved
2. Assembles a focused prompt (~30-50KB) with specifications at the bottom (recency window)
3. Calls `claude -p` to build that phase only
4. Restarts the app and runs curl smoke tests
5. Pauses for you to retry, continue, or stop

You can also phase manually:

```bash
# Run only phase 4
bash bin/oneshot_phased.sh GAME GAME_v6 --phase 4

# Rebuild one screen (useful if Phase 2 drifted)
bash bin/oneshot_phased.sh GAME GAME_v6 --retry-screen SCREEN-WELCOME-SUMMARY.md

# Preview a phase's prompt without running claude
bash bin/oneshot_phased.sh GAME GAME_v6 --dump-prompt 2 > /tmp/phase2.md
```

## Build Modes

| Mode | When | What happens |
|------|------|-------------|
| **New project (single-shot)** | No `git_repo` in METADATA + spec <80KB | Generates prompt only — you create the directory and run claude |
| **New project (auto-phased)** | No `git_repo` + spec >80KB + BUILD_PLAN.md exists | Detects size, delegates to phased driver, runs each phase visibly |
| **Feature branch** | `git_repo` + `BUILD_FEATURE_BRANCH_NAME` in `.env` | Clones/fetches, creates branch, runs single-shot or phased depending on size |
| **Update** | `--update` flag on oneshot.sh | Generates prompt targeting specification changes against existing code |

## Defining Phases

Create `BUILD_PLAN.md` in your spec directory:

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
  - test -f run.py
  - "! grep -q nohup bin/start.sh"

## Phase 2: Screens
specs: SCREEN-*.md
context: UI-GENERAL.md
instructions: |
  Build all screens using the scaffolding from Phase 1.
smoke:
  - curl -sf http://localhost:${PORT}/ -o /dev/null
```

Fields:
- **specs:** Glob patterns of load-bearing spec files (placed at the bottom of the prompt)
- **context:** Additional context files like UI-GENERAL.md (METADATA and ARCHITECTURE are always included)
- **copy:** Bash-friendly `src -> dst` pairs copied before the LLM runs
- **instructions:** Free-form prose injected into the phase header (tell the LLM what to build)
- **smoke:** Curl/bash tests run after the phase (fail aborts the build)

## Traceability

Every build creates an annotated git tag:

Single-shot: `oneshot/MyProject/2026-04-02.1`
Phased: `oneshot/MyProject/2026-04-02.1.phased`

Tags are permanent. Diff between builds at the spec level:

```bash
git diff oneshot/MyProject/2026-03-20.1..oneshot/MyProject/2026-04-02.1 -- MyProject/
```

## Examples

### GAME (phased)
```bash
bash bin/oneshot.sh GAME GAME_v6 opus      # 9 phases, ~30-50KB each, sonnet by default
bash bin/oneshot_phased.sh GAME GAME_v6 --phase 2 --skip-smoke  # rebuild Phase 2, skip curl tests
```

### Small project (single-shot)
```bash
bash bin/oneshot.sh Wyckoff Wyckoff_v1    # <80KB, runs single-shot
```

### Retry one screen after Phase 2 drifted
```bash
bash bin/oneshot_phased.sh GAME GAME_v6 --retry-screen SCREEN-PROJECTS-DASHBOARD.md
```
