---
title: Ed Barlow's PC Setup
header_title: Ed Barlow / PC Setup
eyebrow: Operating Environment Reference
subtitle: If I document it, it will become accurate.
author: Ed Barlow
studio: Web Cloud Studio
year: 2026
cover_logo: assets/ed_setup_bulb.svg
nav_active: ed_barlow_setup.html
---

## Philosophy

> **TODO:** Tighten this section. Core claim to land: this is a bash-first, monitor-space-first,
> AI-in-the-loop setup — not a GUI workflow with AI bolted on.

I have tried to set up my workstation for easy navigation between projects - and for me that means a pane of large colored terminals divided into set layouts.  I configure each window ideal and the colors make it easy to navigate - on a large monitor surface.  I focus on LLM Code development entirely from the command line.

The hardware is sized for it. The primary display is a 48 × 14-inch Samsung superultrawide — wide enough to run six or eight terminal panes without switching desktops. The `newwin` utility assigns each project its own 3-pane Windows Terminal tab: editor, runner, and a free shell. Context-switching between projects is a single keypress.

LLM development runs through Claude Code and Codex, both from the CLI. Code in one pane, a Claude session in another, a second project open in a third — all visible at the same time. That simultaneity is the point. The environment exists to make it cheap.


## Platform Architecture

The environment splits responsibilities between Windows and WSL2 (Ubuntu 22.04). The rule is simple: GUI applications and heavyweight runtimes live on Windows; all development tooling and scripts run in WSL bash.

| Layer | What lives there |
|-------|-----------------|
| Windows | Docker Desktop, Ollama (GPU access), Anaconda, Windows Terminal |
| WSL2 (Ubuntu 22.04) | bash, `uv`, `ruff`, `pytest`, `playwright`, `node`, all `bin/*.sh` scripts |

`$MYPROJECTS` (`/mnt/c/Users/barlo/projects`) is the root for all git repositories. All scripts assume it is set.

The RTX 4060 laptop GPU (8 GB) is accessible from WSL via `nvidia-smi`. Ollama uses it for local model inference.

### Docker

Docker Desktop runs on Windows; the `docker` CLI reaches it from bash through WSL integration.

```bash
# Enable once: Settings → Resources → WSL Integration → enable Ubuntu → Apply & Restart
docker version
docker run --rm hello-world

# Update from bash (winget works from bash, not PowerShell):
winget.exe upgrade --id Docker.DockerDesktop
```

When WSL integration is off, `docker` resolves to the Windows binary but the daemon is unreachable.

### Local models (Ollama + GPU)

Ollama is installed on Windows and called from WSL through the `ollama` alias.

```bash
export OLLAMA_HOST=127.0.0.1:11434    # in .bashrc
ollama serve &                         # or start the Windows tray app
ollama pull llama3.1:8b
curl localhost:11434/api/tags          # confirm the API is up
```

The RTX 4060 (8 GB) runs 7–8B quantised models comfortably for local experimentation.


## The AI Layer

### LLM call primitive

Every script that invokes a model goes through `run_llm_agent.sh`. No script calls `claude` or `codex` directly.

| Tool | Location | Purpose |
|------|----------|---------|
| **`run_llm_agent.sh`** | `Prototyper/bin/run_llm_agent.sh` | The single seam for all batched AI calls. Wraps Claude by default; Codex via `USE_CODEX=1` / `LLM_PROVIDER=codex`. Prompt on stdin, final text to stdout, events and token usage to `$RAW_LOG` / `$LOG_FILE`. `--stream` runs the streaming pipeline. |

### Interactive workflow

AI development happens in the terminal, not an IDE chat panel. Claude Code and Codex run in dedicated panes alongside the code they are modifying. The typical layout across the ultrawide:

- **Pane 1** — active code file or file browser
- **Pane 2** — Claude Code or Codex session
- **Pane 3** — test runner, log tail, or a second project

The wide monitor means the session and the code it is modifying are both readable simultaneously. Review does not require alt-tab.

### Skills

Three skills drive the AI planning and implementation loop:

**`think-through`** — Planning mode. Puts the agent into a no-action state: it plans a single feature without writing any code. The plan persists to its own memory file; sub-features and documentation tasks are tracked separately. Close the session with the word `closeout` to commit the plan and exit.

**`apply-now`** — Implementation mode. Q&As through the outstanding features from `think-through` and asks which to implement next. Recovers plans made in previous sessions without re-establishing context. The Q&A is interactive — it can surface constraints or ambiguities before any code is written.

> **TODO:** Name and describe the third skill.

The two-skill loop (`think-through` → `apply-now`) keeps brainstorming and implementation separate. A session can be entirely planning; the next session picks up where it left off. This makes the workflow context-friendly across days.

### Agent contract

`~/.claude/CLAUDE.md` and `~/.codex/AGENTS.md` define the agent contract.

| Rule | Detail |
|------|--------|
| **Commit immediately** | After any error-free task completion. |
| **Commit message style** | Descriptive. No "OpenAI", "Claude", "Anthropic", or "AI" mentions. |
| **No push** | Local commits only. |
| **No co-authored-by lines** | |
| **Route through primitive** | Model calls via `run_llm_agent.sh`; no metered API keys in scripts. |
| **Directory scope** | Read/write under `$MYPROJECTS` only, unless explicitly permitted. |

### Response voice (BRANDING_EDSVOICE)

How agents respond in interactive sessions — `RulesEngine/BRANDING_EDSVOICE.md`:

- Lead with the answer or decision, then the why, then the key tradeoff. No preamble.
- Terse and professional; no hedging; own the recommendation.
- Formal English in written artifacts — no contractions.
- Use the word **specification**, not "spec" (except in code itself).
- End every response with `----------- REQUEST COMPLETED -----------`.
- Before the terminator, include **`NEXT STEPS`** and **`QUESTIONS`** (decisions only Ed can make). Carry unresolved items forward.


## Development Workflow

### The `newwin` utility

`newwin` (`Developer-Tooling/newwin`) is the entry point to each project. It opens a named 3-pane Windows Terminal tab in the window `BASE`, creating the window on first call and adding a tab on subsequent calls. Each project is locked to one of ten colour schemes so tabs are visually distinct at a glance.

```bash
newwin ProjectName    # opens or activates the project's 3-pane tab
```

State is stored in `newwin.json`. Requires `$MYPROJECTS`.

### Shell

bash, configured in `~/.bashrc` (login shells source `~/.profile`). Dated backups: `~/.bashrc.YYYYMMDD`.

- **`set -o vi`** — vi editing mode on the command line; `EDITOR`/`VISUAL` set to `vi`.
- Shared history across all open terminals:

  ```bash
  shopt -s histappend
  HISTSIZE=100000
  HISTFILESIZE=200000
  HISTTIMEFORMAT='%F %T  '
  PROMPT_COMMAND="history -a; history -c; history -r${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
  ```

- PATH — adds `$MYPROJECTS/Developer-Tooling`, `~/bin`, and `~/.local/bin`. `nvm` loads Node.

### Key utilities (installed)

| Tool | Install | What it does |
|------|---------|-------------|
| `fzf` | `sudo apt-get install -y fzf` | Fuzzy finder — `Ctrl-R` history, `Ctrl-T` file picker, `Alt-C` cd. Key bindings sourced in `.bashrc`. |
| `fd` | `sudo apt-get install -y fd-find` | Fast, ergonomic `find` replacement. Aliased `fd → fdfind`. |
| `bat` | `sudo apt-get install -y bat` | `cat` with syntax highlighting and git gutter. Aliased `bat → batcat`. |
| `entr` | `sudo apt-get install -y entr` | Re-run a command when files change (`-r` reload, `-c` clear). |
| `ncdu` | `sudo apt-get install -y ncdu` | Interactive disk-usage browser. |
| `direnv` | `sudo apt-get install -y direnv` | Per-directory env / auto venv on `cd`. Add `eval "$(direnv hook bash)"` to `.bashrc`. |
| `tree` | `sudo apt-get install -y tree` | Directory structure at a glance. |
| `shellcheck` | `sudo apt-get install -y shellcheck` | Lint `bin/*.sh` before committing. |

To audit what is installed:

```bash
apt-mark showmanual | sort
snap list
uv tool list
npm -g ls --depth=0
ls "/mnt/c/Users/barlo/AppData/Local/Programs"
```

### Platform utilities

| Tool | Purpose |
|------|---------|
| **`log_entry`** (`Developer-Tooling/log_entry.py`) | Platform LEARNINGS log; backs the `slearn`/`stodo`/… shell functions. |
| **`build_documentation.sh`** (`Prototyper/bin/`) | The only documentation command. Builds docs and cascades to the white-paper renderer when `docs/whitepapers/*.md` exist. |
| **`build_pdf.sh`** (`Prototyper/bin/`) | Converts `.md` or `.html` to PDF in the current directory via headless Chromium. |

### Language toolchains

| Tool | Use |
|------|-----|
| `uv` | Virtual environments and dependency management in WSL. |
| `ruff` | Python linting and formatting. |
| `pytest` | Test runner; `bin/test.sh` wraps it and must pass before commit. |
| `playwright` | Headless Chromium — drives the white-paper → PDF render. |
| `node` (via `nvm`) | Node 20 toolchain. |

Anaconda lives on the Windows side; `uv` is the WSL standard. They do not overlap.

### SQLite access pattern

SQLite is the default persistent store, reached directly with the `sqlite3` client for inspection:

```bash
sqlite3 data/app.db                                                        # interactive shell
sqlite3 data/app.db '.tables'                                              # list tables
sqlite3 data/app.db '.schema users'                                        # inspect a table
sqlite3 -header -column data/app.db 'SELECT * FROM users LIMIT 20;'       # readable query output
sqlite3 data/app.db '.mode csv' '.import in.csv users'                    # bulk load
```

`-header -column` is the standard pair for legible ad-hoc queries. Application code reaches the database only through its typed access class — the `sqlite3` client is for inspection, not for production writes.


## Project Standards

A **Conformed Project** meets the platform standard: it carries a generated `CLAUDE_RULES.md` block in `AGENTS.md` (markers `CLAUDE_RULES_START` … `CLAUDE_RULES_END`) and a `METADATA.md` as its authoritative identity file.

Conformance is enforced by `bin/ProjectInitialize.sh` (assess → mechanical fixes → agent conformance → validate). It is idempotent.

| Standard | Rule |
|----------|------|
| **Python environment** | `uv` for virtual environments and dependencies in WSL. |
| **Lint / format** | `ruff`. |
| **Testing** | `pytest`; `bin/test.sh` must pass before commit. |
| **Scripts** | Executables in `bin/` (bash); `# CommandCenter Operation` header registers them with the platform. |
| **Shared libs** | `common.sh` / `common.py` — source or import; do not re-implement. |
| **Line endings** | Linux (`\n` only); `chmod +x bin/*.sh`. |

### Standard directory layout

No `.py` or `.sh` files in the project root.

```
<project>/
  bin/        code execution (start.sh, test.sh, …)
  src/        source
  docs/        documentation
  data/        data
  inbound/     inbound raw data
  Prompts/     prompts
```

`METADATA.md` is authoritative for `name`, `display_name`, `short_description`, `git_repo`. Never infer these from directory names.

The `CLAUDE_RULES.md` block in `AGENTS.md` is generated from `RulesEngine/BUSINESS_RULES.md` by Prototyper tooling — replaceable, do not hand-edit it.


## Documentation and Voices

`build_documentation.sh` is the single documentation entry point. Voice is tooling: each output type carries its own register, independent of the others. All inherit brand from `RulesEngine/BRANDING_MAIN.md`.

| Output | Voice file |
|--------|------------|
| Chat to Ed | `RulesEngine/BRANDING_EDSVOICE.md` |
| Documentation site | `RulesEngine/BRANDING_DOCUMENTATION.md` |
| White papers | `RulesEngine/BRANDING_WHITEPAPERS.md` |
| Website / portfolio | `RulesEngine/BRANDING_WEBSITE.md` |
| Social / blog posts | `RulesEngine/BRANDING_POSTS.md` |

> **TODO:** Define the proposals voice (client-facing) — not yet authored.

---

```bash
bash Prototyper/bin/build_documentation.sh
bash Prototyper/bin/build_pdf.sh docs/whitepapers/ed_barlow_setup.md
```
