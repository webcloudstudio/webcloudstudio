# MyRAG — Architecture

## Directory Layout

```
myrag/
├── main.py                    # Entry point — wires ConfigManager and launches App
├── config.ini                 # User config (gitignored)
├── config.ini.sample          # Config template (committed)
├── pyproject.toml             # Dependencies and ruff config
├── uv.lock                    # Locked dependency tree (committed)
├── PIPELINE_DIAGRAM.txt       # ASCII data-flow reference
├── src/
│   ├── app.py                 # Tkinter root window, tab wiring, session restore
│   ├── config_manager.py      # config.ini reader/writer
│   ├── scanner.py             # Incremental file discovery with mtime caching
│   ├── extractor.py           # PDF/TXT text extraction with OCR fallback
│   ├── chunker.py             # Sentence-aware word-count chunker
│   ├── embedder.py            # Singleton sentence-transformers wrapper
│   ├── vector_store.py        # ChromaDB interface — upsert, query, delete
│   ├── indexer.py             # Orchestrates extract → chunk → embed → store
│   ├── rag_pipeline.py        # Orchestrates embed → retrieve → generate
│   ├── providers/
│   │   ├── base.py            # LLMProvider ABC
│   │   ├── claude_provider.py # Claude via subprocess claude -p
│   │   └── openai_provider.py # OpenAI via openai SDK
│   └── tabs/
│       ├── tab_scan.py        # Tab 1 — directory picker and scan trigger
│       ├── tab_select.py      # Tab 2 — file tree with checkboxes
│       ├── tab_index.py       # Tab 3 — indexing progress and stats
│       └── tab_ask.py         # Tab 4 — query input, provider selector, response
├── bin/
│   ├── start.sh / start.bat   # Launch GUI via uv run
│   ├── reset_index.sh/.bat    # Wipe data/chroma/ and data/scan_index.json
│   ├── inspect_chunks.sh/.bat # Interactive chunk search by keyword
│   ├── inspect_chunks.py      # ChromaDB chunk dump implementation
│   └── test.sh                # Run test suite
└── data/                      # Generated at runtime (gitignored)
    ├── scan_index.json         # Cached directory mtimes and file list
    ├── selection.json          # Persisted file selection
    ├── index_manifest.json     # Per-file size/mtime/chunk-count fingerprints
    └── chroma/                 # ChromaDB persistent collection files
```

## Modules

| Module / File | Purpose |
|---------------|---------|
| `main.py` | Entry point; reads `config.ini`, sets up `data/` dir, creates and runs `App` |
| `src/app.py` | Tkinter root window; instantiates all pipeline objects; wires 4-tab notebook; restores session state on launch |
| `src/config_manager.py` | Reads and writes `config.ini`; exposes typed accessors for scan, provider, and RAG settings |
| `src/scanner.py` | Walks source directories; caches directory mtimes to skip unchanged subtrees; persists file list to `scan_index.json` |
| `src/extractor.py` | Extracts text from PDF (pdfplumber primary, PyMuPDF fallback) and TXT; auto-detects image-only PDFs and runs Tesseract OCR |
| `src/chunker.py` | Splits text into ~512-word chunks with 50-word sentence-boundary-aware overlap |
| `src/embedder.py` | Singleton wrapper around `sentence-transformers all-MiniLM-L6-v2`; lazy-loads model on first use |
| `src/vector_store.py` | Wraps ChromaDB persistent collection; deterministic chunk IDs enable idempotent upserts |
| `src/indexer.py` | Coordinates extract → chunk → embed → upsert; maintains `index_manifest.json` to skip unchanged files |
| `src/rag_pipeline.py` | Embeds query, retrieves top-N chunks, filters by similarity threshold, calls LLM provider; returns `RAGResponse` with per-step timings |
| `src/providers/base.py` | `LLMProvider` ABC defining `generate(query, context_chunks) → str` |
| `src/providers/claude_provider.py` | Calls `claude -p <prompt>` via subprocess; no Anthropic SDK tokens used |
| `src/providers/openai_provider.py` | Calls OpenAI chat completion API using `OPENAI_API_KEY` env var |
| `src/tabs/tab_scan.py` | GUI for directory picker, scan button, progress display, and index reset |
| `src/tabs/tab_select.py` | Treeview checkboxes grouped by directory; saves selection to `selection.json` |
| `src/tabs/tab_index.py` | Triggers `Indexer.index_files()`; shows per-file progress bar and summary stats |
| `src/tabs/tab_ask.py` | Query input with provider radio buttons; displays answer, per-step timing, chunk count, and source filenames |
| `bin/inspect_chunks.py` | Dumps all indexed chunks for any file matching a keyword; useful for debugging index quality |

## Configuration

| Field | Default | Description |
|-------|---------|-------------|
| `[SCAN] source_directories` | — | Comma-separated root paths to scan for documents |
| `[SCAN] directories_to_skip` | `.venv, node_modules, .git, …` | Directory names to exclude from scanning |
| `[SCAN] file_types` | `.pdf` | File extensions to collect (e.g. `.pdf, .txt`) |
| `[PROVIDERS] default_provider` | `claude` | Default LLM: `claude` or `openai` |
| `[CLAUDE] model` | `claude-sonnet-4-6` | Claude model name passed to the CLI |
| `[OPENAI] model` | `gpt-4o` | OpenAI model for chat completions |
| `[OPENAI] api_key_env` | `OPENAI_API_KEY` | Environment variable that holds the OpenAI key |
| `[RAG] similarity_threshold` | `0.7` | Minimum cosine similarity for a chunk to enter the prompt |
| `[RAG] max_context_chunks` | `5` | Maximum chunks injected into each LLM prompt |
| `[RAG] chunk_size` | `512` | Approximate words per chunk |
| `[RAG] chunk_overlap` | `50` | Overlap words between consecutive chunks |
