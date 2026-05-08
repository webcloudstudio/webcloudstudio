# Screens

## Welcome Summary

`GET /welcome/summary`

Default landing screen for the application. Shows an inline-editable checklist of configuration items (app name, PROJECTS_DIR, SPECIFICATIONS_PATH, homepage URL, GitHub SSH status) with ✅/⚠️/❌ icons. A Startup Scan card below displays GitHub repo counts, downloaded project counts, and a per-status breakdown — all read from `platform_stats`.

---

## Welcome Prototypes

`GET /welcome/prototypes`

Read-only searchable list of all specification directories found in `SPECIFICATIONS_PATH`. Each row shows a status badge, display name, namespace, and short description. Client-side text filter; no actions — navigation only.

---

## Welcome Projects

`GET /welcome/projects`

Read-only searchable list of all discovered projects. Each row shows a status badge, display name, namespace, and short description. Client-side text filter; no actions — navigation only.

---

## Projects Dashboard

`GET /` · `GET /projects/dashboard`

Default Projects view. Shows every discovered project in a sortable, filterable table with status badge, operation buttons, links, and a documentation button. Action bar includes free-text search, status pills, namespace pills, and a Rescan button. Clicking a project name or the settings cog navigates to the project detail screen.

---

## Configuration

`GET /project-config`

Batch metadata editor. Renders one row per project with inline-editable fields: port, show-on-homepage checkbox, stack, and tags. Each field saves independently on change — no Save button. Clicking the cog navigates to the full single-project editor.

---

## Validation

`GET /project-validation`

Compliance check runner for all projects. Each row shows a conformity level badge (IDEA/PROTOTYPE/ACTIVE/PRODUCTION), quality and conformity scores, and a Validate button. Expanding a row shows two check groups: Repo/Project Quality (has_git, has_venv, has_claude, has_docs, has_tests, has_specs) and Workflow Conformity (per-level metadata requirements). A Validate All button runs checks across all projects sequentially.

---

## Maintenance

`GET /project-maintenance`

Project list filtered to show only maintenance-category operations. Each row displays operation buttons for long-running or infrequent scripts (cleanup, backup, rebuild). Separates maintenance scripts from the primary Dashboard action surface.

---

## Project Setup

`GET /project-setup`

Discovers unregistered GitHub repos and brings them into GAME. Requires `GITHUB_USERNAME` in `.env`. Shows an Unregistered table (repos on GitHub but not in PROJECTS_DIR) with a Make A Project button that clones the repo and triggers a rescan. A Registered section shows existing projects with a Conform button to update AGENTS.md and template files.

---

## Project Detail

`GET /project/{id}`

Single-project deep view with all metadata, operations, and recent activity. Left column shows an inline-editable info card (display name, status, stack, port, namespace, tags, health endpoint) and a metadata editor organized by source. Right column shows operation buttons with run history and a recent event log. Previous/Next buttons navigate through the project list alphabetically.

---

## Prototypes List

`GET /prototypes/list`

Lists all specification directories from `SPECIFICATIONS_PATH`. Each row shows a status badge, display name, and short description. A New Prototype button opens a modal to scaffold a new spec directory via `setup.sh`. Standard filter bar with text search, status pills, and namespace dropdown.

---

## Prototypes Configuration

`GET /prototypes/configuration`

Batch metadata editor for prototype specification directories. Each row shows inline-editable fields for display name, short description, namespace, and status. Writes directly to each prototype's `METADATA.md` on save.

---

## Prototypes Validation

`GET /prototypes/validation`

Runs and displays specification validation checks across all prototype directories. Each row shows a conformity level badge and issue count. Expanding a row shows check groups for required files (METADATA.md, README.md, INTENT.md, ARCHITECTURE.md, FUNCTIONALITY.md) and specification conformity levels. A Validate All button runs `bin/validate.sh` for each prototype.

---

## Prototypes Maintenance

`GET /prototypes/maintenance`

Maintenance operation runner for prototype specification directories. Each row shows buttons for Specifications `bin/` scripts tagged `# Category: maintenance` — Scorecard, Spec Iterate, Reference Gaps, Tran Logger. Operation buttons follow the standard idle → running → done/error state machine.

---

## Monitoring

`GET /monitoring`

Service health dashboard and event log. Top section shows a health table (URL, status badge, HTTP code, last polled) for all projects with a port and health endpoint. Bottom section shows an interleaved event log from the `events` table with client-side filters for severity (WARN/ERROR toggles) and text search.

---

## Scheduler

`GET /scheduler`

View and manage all scheduled operations. Top section lists every operation with a `# Schedule:` header, showing cron expression (inline-editable), enabled toggle, last run timestamp, and next run time. Bottom section shows the last 30 `schedule_fired` and `schedule_missed` events. Bulk Enable All / Disable All controls in the action bar.

---

## Processes

`GET /processes`

Live log viewer and process control. Lists all projects with expandable rows showing run history: operation name, status badge, start time, duration, View Log button, and Stop button (when running). The log viewer shows monospace output with auto-scroll while the process is active.

---

## Service Catalog

`GET /servicecatalog`

Read-only reference of every project's callable surface area. One card per project showing operation buttons by category (Operations/Workflow/Global), links, REST endpoints from `AGENTS.md`, and MCP tool names. Clicking a script button opens a Script Viewer modal with full file content and the gateway endpoint. Action bar filters by source (Projects/Prototypes) and type.

---

## Publisher

`GET /publisher`

Portfolio site management screen. Top section has Rebuild and Publish buttons with last-build status. Bottom section shows an editable table of projects with `show_on_homepage = true`, with inline-editable card title, description, tags, and image fields. Changes write to METADATA.md; publishing pushes static HTML to GitHub Pages via `git push`.

---

## Workflow Kanban

`GET /workflow/kanban`

Full-width kanban board of all tickets grouped by state: Idea → Proposed → Ready → In Development → Testing → Done. Cards show title, type badge, project, priority, age, and file status. Dragging a card between columns transitions its state. Clicking a card opens a slide-out detail panel with editable title, description, acceptance criteria, tags, and transition history.

---

## Workflow Add Ticket

`GET /workflow/add`

Simple form to create a new specification ticket. Fields: title (auto-incremented default), project dropdown, description textarea, tags, workflow type, and priority. Saves to `spec_tickets` at state `idea` and redirects to the kanban board with the new card highlighted.

---

## Workflow Manage

`GET /workflow/manage`

CRUD management for workflow types (name, file prefix, color, active toggle) and ticket tags. Inline-edit rows; `+ Add Type` appends a blank row. Delete is blocked when tickets of that type exist.

---

## General Settings

`GET /settings/general`

Application-level configuration form with fields for Application Name and Homepage URL. Application Name updates the top-bar brand label immediately on save with no restart required. A GitHub Pages setup assistant appears inline when Homepage URL is empty.

---

## Tag Settings

`GET /settings/tags`

Assign display colors to all tags found across `projects.tags`. Left panel lists tags with a preset color picker dropdown (12 named palette entries). Right panel shows a live preview of tags as pills and buttons, updating on each selection. Save writes to `data/tag_colors.json` and the `tag_colors` table.

---

## VoiceForward Mobile

`GET /voice`

Standalone dark-themed mobile recorder page for iPhone Safari. Shows one large button per configured voice button. Tapping a button starts recording, tapping again stops and uploads audio to `/api/voice/upload` for Whisper transcription. The result card below the buttons shows the transcribed text, target file, and timestamp.

---

## VoiceForward Button Config

`GET /settings/voiceforward/config`

Manage voice recorder buttons. Inline list shows label, target file (relative to `$PROJECTS_DIR`), color swatch, and reorder/edit/delete controls. An Add Button form captures label, target file path, hex color, and active toggle.

---

## VoiceForward Setup Docs

`GET /settings/voiceforward/docs`

Static setup documentation for connecting an iPhone to VoiceForward. Five sections with copyable code blocks: install ffmpeg and Whisper, configure WSL2 port proxy, find laptop IP, connect from iPhone Safari, and manage buttons. No dynamic data — fully static.
