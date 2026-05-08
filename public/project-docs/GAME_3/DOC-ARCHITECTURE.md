# Architecture

## Directory Layout

```
GAME/
  app.py                 App factory (create_app)
  routes.py              All routes (single blueprint: cc)
  scanner.py             Project discovery
  ops.py                 Operation launch/stop/status
  spawn.py               Subprocess management
  publisher.py           Portfolio builder
  monitoring.py          Health poller + log ingestor (background threads)
  scheduler.py           Cron loop for scheduled operations
  service_registry.py    Service discovery and tool dispatch
  mcp_host.py            MCP server lifecycle management
  workflow_engine.py     Generic state machine service
  async_queue.py         File-based store-and-forward queue
  models.py              PROJECT_TYPES registry
  db.py                  Database access helpers
  claude_convention.py   CLAUDE.md / AGENTS.md parsing
  templates/             Flask/Jinja2 templates
    base.html            Layout shell (includes nav partials)
    _nav_top.html        Top navigation bar partial
    _nav_sub.html        Sub-navigation bar partial
    partials/            HTMX response fragments
  static/
    style.css            Custom styles (light-body dark-nav)
  bin/
    common.sh            Shared script functions
    common.py            Shared Python functions
    start.sh             Start Flask dev server
    stop.sh              Stop server
    build_documentation.sh  Generate docs/
    game-cli.sh          CLI gateway client
  services/
    batch-runner.service.yaml
    workflow.service.yaml
    async-queue.service.yaml
  data/
    game.db              SQLite database
    tag_colors.json      Tag color assignments
    queues/              AsyncQueue JSONL files
  docs/                  Generated documentation
  logs/                  Operation log files
  .env                   Local environment config (gitignored)
  .env.sample            Environment variable reference template
```

## Modules

| Module | Purpose |
|--------|---------|
| `app.py` | App factory (`create_app`): load config, init DB, register blueprints, start async scan |
| `routes.py` | All HTTP routes in a single `cc` blueprint on `/` |
| `scanner.py` | Scans `$PROJECTS_DIR`, reads METADATA.md / AGENTS.md / bin/ headers, upserts DB, syncs GitHub repos |
| `ops.py` | Launch/stop/status for bin/ script operations |
| `spawn.py` | Subprocess fork, log capture, PID tracking |
| `publisher.py` | Jinja2-based static site builder — delegates to `bin/homepage_build.py` |
| `monitoring.py` | Background threads: HTTP/TCP health poller and incremental log ingestor |
| `scheduler.py` | 60-second cron loop; evaluates cron expressions, fires operations, handles startup catch-up |
| `service_registry.py` | Discovers service manifests from `services/*.service.yaml` and `{project}/mcp/*.service.yaml`; dispatches tool calls to handlers |
| `mcp_host.py` | Manages MCP server process lifecycle: start, stop, expose (network port), unexpose |
| `workflow_engine.py` | Generic state machine: create instances from templates, validate transitions, record history, emit events |
| `async_queue.py` | JSONL file queue: submit messages, drain pending items via service registry dispatch, rotate archives |
| `db.py` | SQLite access layer — the only module that calls `sqlite3` directly; runs standalone to initialize schema |
| `models.py` | `PROJECT_TYPES` registry constant |
| `claude_convention.py` | Parses `## Bookmarks` and `## Endpoints` tables from AGENTS.md / CLAUDE.md |

## Configuration

Environment variables loaded from `.env` at startup via `python-dotenv`. Only `SECRET_KEY` and `PROJECTS_DIR` are required to start.

| Variable | Required | Default | Purpose |
|----------|----------|---------|---------|
| `SECRET_KEY` | Yes | — | Flask session signing key |
| `PROJECTS_DIR` | Yes | — | Absolute path to the directory containing managed projects |
| `FLASK_ENV` | No | `development` | Flask environment |
| `FLASK_DEBUG` | No | `1` | Enable auto-reloader and debugger |
| `SPECIFICATIONS_PATH` | No | — | Path to Specifications repo (enables `has_specs` detection) |
| `GITHUB_USERNAME` | No | — | GitHub username for Project Setup screen |
| `GITHUB_TOKEN` | No | — | GitHub PAT (required for private repos) |
| `GAME_PORT` | No | `5000` | Server listen port |
| `DATABASE_PATH` | No | `data/game.db` | SQLite file path |
| `MCP_PORT_RANGE_START` | No | `9100` | First port in MCP server range |
| `MCP_PORT_RANGE_END` | No | `9199` | Last port in MCP server range |
| `PUBLISHER_TARGET` | No | sibling `My_Github/` | Target directory for portfolio build |
| `GITHUB_PAGES_BASE_URL` | No | `""` | Full portfolio URL; drives `base_path` derivation |
