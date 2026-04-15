# update_reference_gaps.sh

Identify gaps between your specification and prototype implementation. Analyzes specification files against the built code using `claude -p` (your subscription).

## What It Identifies

- **Spec-to-Code gaps** — features in spec but missing from code
- **Code-to-Spec gaps** — implemented features not documented in spec
- **Schema mismatches** — database differences between spec and implementation
- **Pattern violations** — code not following stack conventions

## Usage

```bash
bash bin/update_reference_gaps.sh <ProjectName>
```

| Argument | Purpose |
|----------|---------|
| `<ProjectName>` | Specification directory name (required). Resolves under `specification_directory:` from METADATA.md |

## Examples

Basic usage:
```bash
bash bin/update_reference_gaps.sh GAME
```

Review the gaps:
```bash
cat ../Specifications/GAME/REFERENCE_GAPS.md | head -50
```

Use in iteration workflow:
```bash
bash bin/update_reference_gaps.sh GAME
less ../Specifications/GAME/REFERENCE_GAPS.md
bash bin/iterate.sh GAME > iterate-prompt.md
cd /path/to/GAME && claude -p "$(cat ../Specifications/GAME/iterate-prompt.md)"
bash bin/update_reference_gaps.sh GAME
```

## Output

Creates `Specifications/<ProjectName>/REFERENCE_GAPS.md` with four main sections:

### Spec-to-Code Gaps

Features in specification but missing from code:

```
Missing Screen: SCREEN-SETTINGS-AUDIT-LOG.md
- Defined in spec with full layout and interactions
- Not found in prototype code
- Action: Create SCREEN-NNN-AUDIT-LOG.md ticket; run iterate.sh
```

### Code-to-Spec Gaps

Implemented features not documented in specification:

```
Undocumented API: POST /api/projects/{id}/scan
- Implemented in app/views/projects.py
- Spec defines PROJECT-SCAN but not this endpoint
- Action: Update FEATURE-SERVICE-CATALOG.md
```

### Database Schema Mismatches

Schema differences between spec and code:

```
projects table
- Spec: {id, name, path, status}
- Code: {id, name, path, status, last_scan_ts}
- Action: Update DATABASE.md or revert column
```

### Pattern Violations

Code not following stack conventions:

```
bin/start.sh uses nohup
- Stack/common.md prescribes foreground under tee
- Code violates: "nohup python3 run.py &"
- Action: Create PATCH-NNN-FIX-START-SH.md; run iterate.sh
```

## Workflow

1. Build prototype with `oneshot.sh` or `oneshot_phased.sh`
2. Run `bash bin/update_reference_gaps.sh <ProjectName>`
3. Review `REFERENCE_GAPS.md` to identify priority gaps
4. Create numbered tickets (`SCREEN-NNN-*.md`, `FEATURE-NNN-*.md`, `PATCH-NNN-*.md`)
5. Run `bash bin/iterate.sh <ProjectName>` to address gaps
6. Re-run `update_reference_gaps.sh` to verify gaps are closed

## Integration with Other Tools

Works alongside `spec_iterate.sh`:

| Tool | Purpose |
|------|---------|
| `update_reference_gaps.sh` | Spec vs. prototype; identifies implementation gaps |
| `spec_iterate.sh` | Specification quality; identifies authoring gaps |

Run both periodically to keep spec and code in sync.

## Notes

- Runs via `claude -p` using your subscription (not API tokens)
- Output written to specification directory, not prototype
- Safe to run multiple times — overwrites `REFERENCE_GAPS.md`
- Gaps are informational; they don't block builds
- Large gaps indicate spec is too far behind code; consider `decompose.sh` to regenerate spec

## Exit Codes

| Code | Meaning |
|------|---------|
| `0` | Success; `REFERENCE_GAPS.md` written |
| `1` | Missing spec directory, missing METADATA.md, or claude CLI not found |
