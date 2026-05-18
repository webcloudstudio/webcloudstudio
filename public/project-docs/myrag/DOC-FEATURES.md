# MyRAG — Features

## Launch GUI

**Trigger:** `./bin/start.sh` (WSL/Linux) or `bin\start.bat` (Windows)

Opens the Tkinter desktop window with a 4-tab notebook. Tabs 2–4 are unlocked progressively as data becomes available; prior session state (scan index, file selection, and indexed chunks) is restored automatically on launch so you can continue where you left off.

## Scan Directories (Tab 1)

**Trigger:** Click **Scan** in the Scan tab after configuring source directories.

Walks all configured source directories recursively, collecting PDF (and optionally TXT) file paths. Uses directory mtime caching: subtrees unchanged since the last scan are skipped in milliseconds. Results are persisted to `data/scan_index.json` and the Select tab is populated automatically.

## Select Files (Tab 2)

**Trigger:** Populated automatically after a scan completes.

Displays discovered files in a treeview grouped by directory, with per-file and per-directory checkboxes. Checking a directory selects all files beneath it. The saved selection is written to `data/selection.json` and persists across sessions.

## Index Selected Files (Tab 3)

**Trigger:** Click **Index** in the Index tab after making a selection.

Runs the full indexing pipeline for every selected file: text extraction → chunking → embedding → ChromaDB upsert. Files that haven't changed since the last index run are skipped via `index_manifest.json` fingerprints (size + mtime). Progress is shown file-by-file with a summary on completion.

## PDF Text Extraction with OCR Fallback

**Trigger:** Automatically during indexing.

Extracts text from PDFs using pdfplumber first, falling back to PyMuPDF if pdfplumber fails. If neither yields text (image-based scanned PDFs), rasterises each page at 200 DPI using PyMuPDF and runs Tesseract OCR, logging per-page timing and character counts so progress is visible for long documents.

## Ask Questions (Tab 4)

**Trigger:** Type a question and press Enter or click **Ask**.

Embeds the query using the local all-MiniLM-L6-v2 model, retrieves the top-N chunks from ChromaDB by cosine similarity, filters by the configured threshold (default 0.7), and sends the matching context to the selected LLM. If no chunks pass the threshold, the LLM is queried directly without fabricated sources. The answer, source filenames, chunk count, and per-step latencies (embed / retrieve / LLM) are displayed.

## Switch LLM Provider

**Trigger:** Select Claude or OpenAI radio button in the Ask tab before submitting.

Switches the active LLM mid-session without restarting. Claude uses the `claude -p` CLI subprocess (subscription-billed, no API token). OpenAI uses the official SDK with the key from `OPENAI_API_KEY`.

## Reset Index

**Trigger:** `./bin/reset_index.sh` (WSL/Linux) or `bin\reset_index.bat` (Windows), or the Reset button in the Scan tab.

Prompts for confirmation then deletes `data/chroma/` and `data/scan_index.json`, returning the app to a clean state. The file selection (`data/selection.json`) and `config.ini` are preserved.

## Inspect Chunks

**Trigger:** `./bin/inspect_chunks.sh` (WSL/Linux) or `bin\inspect_chunks.bat` (Windows)

Prompts for a search term, then dumps every indexed chunk for files whose path contains that term — including chunk index, character positions, and raw text. Useful for verifying extraction quality or debugging why a question isn't retrieving expected passages.
