# Step 2b — oneshot_phased.sh

Multi-phase build orchestrator for large specifications. Reads `BUILD_PLAN.md` from the specification directory and runs each phase as a separate `claude -p` call, keeping prompts under ~50KB so specifications stay in the model's recency window.

## How It Works

Between phases, the driver:
- Copies scaffolding files (no LLM involved)
- Restarts the app
- Runs smoke tests
- Pauses for review (unless `--non-interactive`)

Each phase is independent — cherry-pick phases with `--phase` or `--from`.

## Usage

```bash
bash bin/oneshot_phased.sh <ProjectName> <TargetDir> [options]
```

| Argument | Purpose |
|----------|---------|
| `<ProjectName>` | Specification directory name (resolves under `specification_directory:` from METADATA.md) |
| `<TargetDir>` | Target project directory. Simple name (goes under `../`) or absolute path starting with `/` |

## Options

| Option | Default | Purpose |
|--------|---------|---------|
| `--model sonnet\|opus\|haiku` | sonnet | AI model to use |
| `--phase N` | — | Run only phase N; skip others |
| `--from N` | — | Run phases N through end; skip 1..N-1 |
| `--retry-screen NAME` | — | Rebuild one screen spec only (if phase drifted) |
| `--skip-smoke` | — | Skip curl/bash smoke tests after each phase |
| `--skip-validate` | — | Skip specification validation before build |
| `--no-copy` | — | Skip file-copy step (useful on reruns) |
| `--no-app` | — | Don't start/stop app between phases |
| `--non-interactive` | — | Run full build unattended; don't pause |
| `--dump-prompt N` | — | Print phase N prompt to stdout; exit (no LLM call) |
| `--status` | — | Show per-phase completion status for this spec/target; exit (no LLM call) |

## Examples

Run all phases:
```bash
bash bin/oneshot_phased.sh GAME GAME_v4
bash bin/oneshot_phased.sh GAME GAME_v4 --model opus
```

Resume from phase 3 (phases 1-2 already done):
```bash
bash bin/oneshot_phased.sh GAME GAME_v4 --from 3
```

Rebuild a single phase:
```bash
bash bin/oneshot_phased.sh GAME GAME_v4 --phase 2
bash bin/oneshot_phased.sh GAME GAME_v4 --phase 2 --skip-smoke
```

Rebuild one screen if phase drifted:
```bash
bash bin/oneshot_phased.sh GAME GAME_v4 --retry-screen SCREEN-WELCOME-SUMMARY.md
```

Full unattended build:
```bash
bash bin/oneshot_phased.sh GAME GAME_v4 --non-interactive
```

Preview phase 2 prompt without running LLM:
```bash
bash bin/oneshot_phased.sh GAME GAME_v4 --dump-prompt 2 > /tmp/phase2.md
```

Debug a failing phase:
```bash
bash bin/oneshot_phased.sh GAME GAME_v4 --phase 3 --skip-smoke --no-app
cd GAME_v4
bash bin/start.sh
curl http://localhost:8080/
```

Check build progress:
```bash
bash bin/oneshot_phased.sh GAME GAME_v4 --status
```

Example output:
```
=== Build Status: GAME → GAME_v4 ===
  spec:   ../Specifications/GAME/BUILD_PLAN.md
  target: ../GAME_v4

  4 of 9 LLM phases complete  (9 total phases)

  Phase 1   Scaffold                       DONE          2026-04-11 14:23  prompt=47KB  log=128KB
  Phase 2   Database Models                DONE          2026-04-11 14:41  prompt=38KB  log=95KB
  Phase 3   Core Screens                   DONE          2026-04-11 15:02  prompt=52KB  log=143KB
  Phase 4   Dashboard                      DONE          2026-04-11 15:31  prompt=44KB  log=117KB
  Phase 5   Features                       PENDING
  Phase 6   Admin                          PENDING
  Phase 7   Reports                        PENDING
  Phase 8   Verify: smoke check            VERIFY-ONLY
  Phase 9   Integration                    PENDING
```

Status values:
- **DONE** — `logs/oneshot_phase_N.log` exists with content; shows timestamp and prompt/log sizes
- **PENDING** — no log file; phase has not run against this target
- **VERIFY-ONLY** — phase has no `specs:` field; no LLM call needed

## Phase Execution

For each phase with `specs:` defined:

1. **[copy]** Copy files from Prototyper repo to target (no LLM)
2. **[prompt]** Assemble phase prompt from specs + context + stack files
3. **[archive]** Save prompt to `logs/oneshot_phase_N.md` and `spec_prompts/`
4. **[claude -p]** Stream LLM output; tee to `logs/oneshot_phase_N.log`
5. **[start-app]** Run `bin/start.sh` → wait for healthcheck
6. **[smoke]** Run tests from `smoke:` section; fail → abort
7. **[pause]** Wait for review (unless `--non-interactive`)

Verify-only phases (no `specs:`) skip steps 2-4.

## Checking Phase Status

See which phases are done:
```bash
ls -la logs/oneshot_phase_*.log
tail -100 logs/oneshot_phase_2.log
git log --oneline | head -5
```

## BUILD_PLAN.md Format

Define phases in your specification's `BUILD_PLAN.md`:

```markdown
## Phase 1: Scaffold

specs: DATABASE.md
context: UI-GENERAL.md
copy:
  - RulesEngine/templates/common.sh -> bin/common.sh
  - RulesEngine/templates/common.py -> bin/common.py
instructions: |
  Build the foundation only — no screens yet.
smoke:
  - test -f bin/start.sh
  - "! grep -q nohup bin/start.sh"
  - curl -sf http://localhost:${PORT}/ -o /dev/null

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
| `specs:` | Comma-separated globs; placed at bottom of prompt (recency anchor) | Yes (unless verify-only) |
| `context:` | Additional context files (e.g., `UI-GENERAL.md`, `FUNCTIONALITY.md`). METADATA + ARCHITECTURE always included | No |
| `copy:` | `src -> dst` pairs; src relative to Prototyper repo; dst relative to target | No |
| `instructions:` | Free-form prose; tell LLM what to build | No |
| `smoke:` | Bash commands run after phase; `${PORT}` substituted; fail → abort | No |

## Artifacts

Each phase creates:
- `logs/oneshot_phase_N.md` — prompt sent to LLM
- `logs/oneshot_phase_N.log` — LLM response + stdout
- `spec_prompts/{spec}_{target}_{timestamp}_pN.md` — archived copy

Central audit logs in Prototyper repo:
- `data/prompts.jsonl` — prompt metadata
- `data/executions.jsonl` — execution metadata

## Debugging

**Phase failed:**
```bash
cat logs/oneshot_phase_2.md | less
cat logs/oneshot_phase_2.log | less
bash bin/oneshot_phased.sh GAME GAME_v4 --phase 2
```

**Smoke tests failed:**
```bash
bash bin/oneshot_phased.sh GAME GAME_v4 --phase 2 --skip-smoke
```

**App won't start:**
```bash
bash bin/oneshot_phased.sh GAME GAME_v4 --phase 2 --no-app
cd GAME_v4
bash bin/start.sh
curl http://localhost:8080/
```

**One screen drifted:**
```bash
bash bin/oneshot_phased.sh GAME GAME_v4 --retry-screen SCREEN-PROJECTS-DETAIL.md
```

## Exit Codes

| Code | Meaning |
|------|---------|
| `0` | Success |
| `1` | Missing argument, spec validation failed, git failure, or phase failed (smoke tests failed) |

## Notes

Phases run in `BUILD_PLAN.md` file order. Each phase is independent; cherry-pick phases with `--phase` or `--from`. App always stopped before LLM runs (so model can freely rewrite files). Logs always preserved, even on failure.
