# Photo Organizer/Deduplicator — Architecture

## Directory Layout

```
ezdocs/
  src/
    WcsPhotoOrganizer.py   GUI entry point
    scanner.py             Scan and dedup engine
    drive_detection.py     Windows drive enumeration
    cli_config.py          Config reader + WSL path translator
    cli_scan.py            CLI scan step
    cli_analyze.py         CLI analyze step
    cli_dedup.py           CLI dedup/execute step
  bin/
    start.sh               Launch GUI
    photo_scan.sh          CLI: run scan step
    photo_analyze.sh       CLI: run analyze step
    photo_dedup.sh         CLI: run dedup step
    build.sh               Build Windows EXE
    build_documentation.sh Generate docs/index.html
    build_installer.sh     Build Inno Setup installer
    remove_build_artifacts.sh  Clean build output
    common.sh              Shared bash functions
    common.py              Shared Python OperationContext
    test.sh                Test runner
  data/                    Runtime-generated data files
  docs/                    Markdown documentation + generated index.html
  logs/                    Application log files
  config.ini               Live config (gitignored)
  config.ini.sample        Config template
  WcsPhotoOrganizer.spec   PyInstaller spec
  installer.iss            Inno Setup installer script
```

## Modules

| Module / File | Purpose |
|---|---|
| `src/WcsPhotoOrganizer.py` | Tkinter GUI; orchestrates Scan → Analyze → Review → ReOrganize 4-tab state machine; spawns background threads for each operation |
| `src/scanner.py` | Core scan engine; builds `filedict` and `filesignature` indexes; detects duplicates; manages preferred-directory list; persists results to `data/` |
| `src/drive_detection.py` | Enumerates available Windows drive letters; proposes default `final_photo_folder` and `source_photo_folders` on first run |
| `src/cli_config.py` | Reads `config.ini`; translates Windows-style paths to WSL mountpoints when running on Linux |
| `src/cli_scan.py` | Headless scan step; reads config, invokes scanner, writes `data/scan_data.pkl` and `data/scan_summary.txt` |
| `src/cli_analyze.py` | Headless analyze step; loads scan pickle, applies preferred-directory rules, writes `data/files_to_copy.txt` |
| `src/cli_dedup.py` | Headless execute step; parses `files_to_copy.txt`; dry-run by default; `--live` + `change_source_directory = True` required to modify files |
| `bin/common.sh` | Shared bash: project path setup, venv activation, env loading, log helpers, SIGTERM trap |
| `bin/common.py` | Shared Python `OperationContext`: METADATA.md parsing, env loading, structured logging, heartbeat |

## Configuration

| Field | Default | Description |
|---|---|---|
| `final_photo_folder` | *(auto-detected Pictures folder)* | Destination folder where consolidated photos are written |
| `source_photo_folders` | *(auto-detected drives)* | Comma-separated list of folders to scan for photos |
| `strings_to_strip` | *(empty)* | Substrings removed from computed target subdirectory paths (e.g. `My Drive`, `Pictures`) |
| `directories_to_skip` | *(empty)* | Folders excluded from scanning |
| `change_source_directory` | `False` | `False` = simulation mode; `True` = live file operations |
| `delete_after_move` | `False` | When `True`, source files are deleted after successful copy |
| `log_file_folder` | `./logs` | Directory for application log files |
| `product_name` | `Disk Cleaner` | Application display name shown in the GUI title bar |
| `company_name` | `Web Cloud Studios` | Company name shown in copyright splash |
| `show_copyright_splash` | `True` | Whether to show the copyright splash screen on launch |
