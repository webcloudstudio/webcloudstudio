# Photo Organizer/Deduplicator — Flows

## GUI Workflow: Scan → Analyze → Review → ReOrganize

The GUI implements a linear 4-step state machine. Each step must complete successfully before the next button is enabled.

**Trigger:** User launches `WcsPhotoOrganizer.exe` (or `./bin/start.sh`) and clicks through each tab in sequence.

**Reads:** `config.ini` (folder paths, behavior flags), `data/directory_states.txt` (preferred-directory overrides)
**Writes:** `data/scan_data.pkl`, `data/scan_summary.txt`, `data/files_to_copy.txt`; optionally moves/copies files to `final_photo_folder`

```mermaid
flowchart TD
  A([Launch App]) --> B[Tab 1: Scan\nIndex all source folders\nWrites scan_data.pkl]
  B -->|scan complete| C[Tab 2: Preferences / Analyze\nApply preferred-dir rules\nWrites files_to_copy.txt]
  C -->|analysis complete| D[Tab 3: Review Copy Plan\nInspect every planned operation]
  D -->|user clicks Approve| E[Tab 4: ReOrganize\nExecute copy/move plan\nLive log viewer]
  E --> F([Done])
```

Each step runs in a background thread; the GUI remains responsive and displays a live progress counter. State flags (`scan_completed`, `analysis_completed`, `plan_approved`) control which buttons are active.

---

## CLI Pipeline: photo_scan → photo_analyze → photo_dedup

The headless pipeline mirrors the GUI workflow exactly and is designed for WSL or automation use. All three steps share the same `data/` directory as the hand-off point.

**Trigger:** Manual invocation or shell script chaining.

**Reads:** `config.ini`, `data/directory_states.txt`
**Writes:** `data/scan_data.pkl` → `data/files_to_copy.txt` → (live mode) files copied/moved to `final_photo_folder`

```mermaid
sequenceDiagram
  participant User
  participant scan as photo_scan.sh\n(cli_scan.py)
  participant analyze as photo_analyze.sh\n(cli_analyze.py)
  participant dedup as photo_dedup.sh\n(cli_dedup.py)
  participant data as data/

  User->>scan: ./bin/photo_scan.sh
  scan->>data: scan_data.pkl, scan_summary.txt
  User->>analyze: ./bin/photo_analyze.sh
  analyze->>data: reads scan_data.pkl
  analyze->>data: files_to_copy.txt
  User->>dedup: ./bin/photo_dedup.sh (dry-run)
  dedup->>User: prints planned operations
  User->>dedup: ./bin/photo_dedup.sh --live
  dedup->>data: reads files_to_copy.txt
  dedup->>User: copies/moves files to final_photo_folder
```

`photo_dedup.sh` defaults to dry-run: it prints every operation without touching files. Passing `--live` executes the plan, but only if `config.ini` also has `change_source_directory = True` (double-gating).

---

## Duplicate Resolution Flow

For each unique file signature (`stripped_filename + "~|~" + size`) found in multiple locations, the scanner applies this decision tree to decide what goes into the copy plan:

```mermaid
flowchart TD
  A([File signature found in multiple locations]) --> B{Any copy in a\npreferred directory?}
  B -->|Yes| C[Skip entirely — already home\nNo entry in files_to_copy.txt]
  B -->|No| D[Select source: non-preferred dir\nwith the highest file count]
  D --> E[Compute target_subdir:\nrelative path from source root]
  E --> F{Target filename\nalready exists?}
  F -->|No| G[COPY/MOVE entry added]
  F -->|Yes| H[Append -2, -3 suffix\nCOPY/MOVE entry added]
```
