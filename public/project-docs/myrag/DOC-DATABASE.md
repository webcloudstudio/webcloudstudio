# MyRAG — Database

MyRAG uses ChromaDB as its vector database, stored on disk at `data/chroma/`. All data is local — nothing leaves the machine.

## ChromaDB Collection: `myrag_docs`

Stores embedded text chunks for every indexed document. The collection uses cosine similarity (`hnsw:space: cosine`) for nearest-neighbour retrieval.

| Field | Type | Purpose |
|-------|------|---------|
| `id` | string | Deterministic chunk ID: `sha256(file_path)[:8]_{chunk_index}` — enables idempotent upserts |
| `document` | string | Raw chunk text (~512 words) |
| `embedding` | float[384] | Dense vector from `all-MiniLM-L6-v2` |
| `file_path` | string (metadata) | Absolute path to the source file |
| `chunk_index` | int (metadata) | Zero-based position of this chunk within the document |
| `char_start` | int (metadata) | Character offset where the chunk begins in the extracted text |
| `char_end` | int (metadata) | Character offset where the chunk ends in the extracted text |

## JSON State Files

Three JSON files in `data/` complement the vector store:

### `data/scan_index.json`

Caches the result of the last directory scan.

| Field | Type | Purpose |
|-------|------|---------|
| `version` | int | Schema version |
| `dirs` | object | Map of directory path → last-seen mtime; used to skip unchanged subtrees |
| `files[].path` | string | Absolute file path |
| `files[].mtime` | float | File modification time at scan time |
| `files[].size` | int | File size in bytes |
| `files[].file_type` | string | File extension (e.g. `.pdf`) |

### `data/selection.json`

Persists the user's file selection across sessions — a flat JSON array of absolute file paths.

### `data/index_manifest.json`

Tracks which files have been indexed and their fingerprints, so unchanged files are skipped on re-index.

| Field | Type | Purpose |
|-------|------|---------|
| `<file_path>.size` | int | File size at index time |
| `<file_path>.mtime` | float | File mtime at index time |
| `<file_path>.indexed_at` | string | ISO 8601 timestamp of last indexing |
| `<file_path>.chunks` | int | Number of chunks produced |
