# Photo Organizer/Deduplicator — Development

## Dev Setup

Development happens in WSL. The application itself runs on Windows.

```bash
# Clone and enter project
cd /mnt/c/Users/barlo/projects/ezdocs

# Create Python venv (for linting/tooling — app uses system Python)
python3 -m venv venv
source venv/bin/activate

# Copy config template
cp config.ini.sample config.ini
```

> **WSL vs Windows build:** Running `python3 src/WcsPhotoOrganizer.py` from WSL works for UI development. Building the `.exe` requires Windows Python (`python.exe`) — WSL's Python produces a Linux ELF binary.

## Running

```bash
# Run GUI directly (development)
python3 src/WcsPhotoOrganizer.py

# Run scanner standalone (test scanning logic)
python3 src/scanner.py

# Run from Windows Python (test Windows behavior)
python.exe src/WcsPhotoOrganizer.py
```

## Building

```bash
# Build from WSL (recommended)
./bin/build.sh

# Or call Windows batch directly
/mnt/c/Windows/System32/cmd.exe /c bin\\build_installer.bat

# Clean build artifacts
./bin/remove_build_artifacts.sh
```

`bin/build.sh` invokes `python.exe -m PyInstaller --clean WcsPhotoOrganizer.spec` then Inno Setup (if installed) to produce the full installer.

## Build Outputs

| File | Description |
|---|---|
| `dist/WcsPhotoOrganizer.exe` | Standalone Windows executable — distribute directly or via installer |
| `installer_output/WcsPhotoOrganizer_v*.exe` | Full Windows installer — recommended for end users |

## Installer

`installer.iss` is an Inno Setup script that packages the PyInstaller EXE into a professional Windows installer with Start Menu and Desktop shortcuts, license agreement, and an uninstaller. Requires [Inno Setup 6](https://jrsoftware.org/isdl.php).

```bash
# Build just the EXE (no installer)
python.exe -m PyInstaller --clean WcsPhotoOrganizer.spec

# Full installer build from WSL
./bin/build.sh
```
