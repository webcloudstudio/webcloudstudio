# Features

## Startup Scanner

**Trigger:** Application startup (background daemon thread).

Scans `$PROJECTS_DIR` for project directories. Phase 1 reads each project's `METADATA.md`, `AGENTS.md`/`CLAUDE.md`, and the first 20 lines of every `bin/` script to populate the `projects` and `operations` tables. Phase 2 calls `gh api --paginate /user/repos` to sync all GitHub repos into `github_repos`. Phase 3 cross-links local projects to GitHub repos by name match. Phase 4 writes aggregate counts to `platform_stats`. All phases are non-fatal — a failure in one does not abort the others.

**Reads:** `$PROJECTS_DIR` filesystem, `METADATA.md`, `AGENTS.md`/`CLAUDE.md`, `bin/` script headers, GitHub API via `gh` CLI.
**Writes:** `projects`, `operations`, `github_repos`, `platform_stats` tables.

---

## Service Catalog API

**Trigger:** `GET /api/catalog` (external callers, agents, scripts).

Returns every active project's identity, port, health path, registered scripts, links, REST endpoints, and MCP tools as JSON. Script execution uses `POST /api/{name}/run/{script}` which returns a `run_id` immediately (202); callers poll `GET /api/runs/{run_id}` for status. Log content available at `GET /api/runs/{run_id}/log`. Stop via `POST /api/runs/{run_id}/stop`. No new process management code — delegates entirely to the existing process engine.

**Reads:** `projects`, `operations`, `op_runs`, `service_tools` tables; script files on demand (script content endpoint).
**Writes:** `op_runs` (new row on fire), `events` (operation_started, operation_completed).

---

## Homepage Publisher

**Trigger:** `POST /publisher/build` (Rebuild button) or `bin/homepage_build.sh` directly.

Builds a static portfolio site from project `METADATA.md` fields using Jinja2 templates — no Astro, no npm. Reads `config/site_config.md` for branding, scans `$PROJECTS_DIR` for projects with `show_on_homepage = true`, resolves tag colors from `data/tag_colors.json`, renders three templates (`index.html.j2`, `projects.html.j2`, `resume.html.j2`), and copies static assets. `POST /publisher/publish` commits and pushes the output to GitHub Pages via `git push origin main`.

**Reads:** `config/site_config.md`, `$PROJECTS_DIR/*/METADATA.md`, `data/tag_colors.json`, Jinja2 templates, `projects` table.
**Writes:** `$PUBLISHER_TARGET/publish/` static files; GitHub Pages branch on publish.

---

## Health Check & Event Ingestor

**Trigger:** Scheduler every `health_check_interval` seconds per project; `POST /api/health/poll` for on-demand; log ingestor on 60-second scheduler tick or `POST /api/logs/ingest`.

The service health poller performs HTTP GET or TCP connect against each project's port and health endpoint, upserts one row in `heartbeats`, appends to `health_check_log`, and fires an `alert_fired` or `state_transition` event on state change. The log ingestor incrementally reads new bytes from `{project}/data/logs/*.log` using byte-offset cursors, classifies lines against `log_filter` rules (start/stop/critical/error/warning/junk), and writes matched lines to `events`. The heartbeat API (`POST /api/heartbeat`, `POST /api/events`) lets `bin/` scripts report operational state without raising exceptions if GAME is unreachable.

**Reads:** `projects` (port, health_endpoint, desired_state), `log_positions`, `log_filter`, project log files.
**Writes:** `heartbeats`, `health_check_log`, `log_positions`, `events`.

---

## Workflow Service

**Trigger:** `POST /api/services/workflow/create`, `POST /api/services/workflow/transition`, or Kanban board drag.

Generic state machine service. Creates workflow instances from configurable templates (`specification-ticket`, `deployment`, `review`), validates and executes state transitions, records full transition history, and emits `workflow_transition` events. Templates define allowed states and transitions in JSON; new templates can be added via YAML files in `{project}/workflows/`. The existing spec_tickets Kanban board uses the `specification-ticket` template.

**Reads:** `workflow_instances`, `workflow_templates` tables.
**Writes:** `workflow_instances` (state update), `workflow_history` (append), `events` (append).

---

## MCP Server Hosting

**Trigger:** Discovery during project scan (reads `mcp/*.service.yaml`); lifecycle via `POST /api/mcp/{id}/expose` and `POST /api/mcp/{id}/unexpose`.

Discovers developer-created MCP servers from `mcp/` directories in managed projects, registers them in the `mcp_servers` table, and manages their process lifecycle. Unexposed servers are stdio-only (started by Claude via `.mcp.json`). Clicking Expose starts the server on an assigned port from the configurable range (default 9100-9199) using SSE or streamable-HTTP transport. A Copy Config button generates the ready-to-paste `.mcp.json` snippet for coworkers.

**Reads:** `mcp/*.service.yaml` manifests, `mcp_servers`, `services` tables.
**Writes:** `mcp_servers` (status, pid, assigned_port), `services`, `service_tools`.

---

## Batch Runner Service

**Trigger:** `POST /api/{project}/run/{script}` (REST), `game-cli batch-runner run_script` (CLI), or MCP tool call.

Wraps the existing process engine with a formal service manifest, making script execution available through all five transports. Tools: `run_script`, `run_status`, `run_log`, `run_stop`, `list_runs`. All tools delegate to existing `ops.py` functions — no new process management code. Available via the generic service route `POST /api/services/batch-runner/{tool}`.

**Reads:** `projects`, `operations`, `op_runs` tables.
**Writes:** `op_runs` (via process engine), `events`.

---

## CLI Gateway

**Trigger:** Calling `bin/game-cli.sh` from any project's `bin/` scripts.

Thin bash client for GAME's REST API. Resolves the GAME server URL from `$GAME_URL`, `$GAME_PORT`, `~/.game_port`, or defaults to `localhost:5000`. Supports: `catalog`, `run {name} {script}` (with optional `--no-wait`), `status`, `log`, `stop`, `health`, `heartbeat`, `event`. The `run` command polls every 2 seconds and exits 0 on done, 1 on error. Requires only bash and curl — does not source `common.sh`.

**Reads:** GAME REST API endpoints.
**Writes:** `op_runs`, `heartbeats`, `events` (via API calls).

---

## AsyncQueue Service

**Trigger:** Producer appends to a JSONL file directly (works without GAME running), `POST /api/services/async-queue/submit` (REST), or `services.async_queue.submit()` via `common.py`.

File-based store-and-forward message queue. Each queue is a JSONL file at `data/queues/{queue-name}.queue.jsonl`. Producers append a line with service, tool, payload, and priority. GAME drains queues on startup (after scan), on `POST /api/services/async-queue/drain`, or on a scheduler cron job. The drain loop processes messages in priority-then-age order, dispatches to the service registry's `dispatch_tool()`, and writes status back to the file. Completed messages rotate to `data/queues/archive/` when the queue exceeds 1000 lines or 1 MB.

**Reads:** Queue JSONL files, `queue_config.yaml`, `services` table.
**Writes:** Queue JSONL files (status updates), archive files, `events`.

---

## VoiceForward

**Trigger:** `POST /api/voice/upload` (phone browser uploads audio after recording stops).

Mobile voice recorder that transcribes audio and appends text to configured project files. The `/voice` page renders buttons from the `voice_buttons` table. After a button tap-and-release, the browser sends an audio blob and label to the server. The server validates the label, saves audio to a temp file, transcribes with Whisper `base` model (lazy-loaded, cached in memory), and appends a dated entry to the target file at `$PROJECTS_DIR/{target_file}`. Returns transcribed text and target path as JSON.

**Reads:** `voice_buttons` table (label → target_file mapping).
**Writes:** Target files in `$PROJECTS_DIR`; temp audio file (deleted after transcription).
