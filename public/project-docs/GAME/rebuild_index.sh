#!/bin/bash
# Rebuilds index.html from the spec_v4 markdown files.
# Run this any time a .md file changes.
# Usage: bash rebuild_index.sh (from any directory)

set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"

python3 - <<'PYEOF'
import json, os

docs = {
    'GAME/CONTROL-PANEL':            'GAME/CONTROL-PANEL.md',
    'GAME/PROJECT-DISCOVERY':        'GAME/PROJECT-DISCOVERY.md',
    'GAME/OPERATIONS-ENGINE':        'GAME/OPERATIONS-ENGINE.md',
    'GAME/PROCESS-MONITOR':          'GAME/PROCESS-MONITOR.md',
    'GAME/GITHUB-PUBLISHER':         'GAME/GITHUB-PUBLISHER.md',
    'GAME/TAG-MANAGEMENT':           'GAME/TAG-MANAGEMENT.md',
    'GAME/USAGE-ANALYTICS':          'GAME/USAGE-ANALYTICS.md',
    'GAME/CONFIGURATION-MANAGEMENT': 'GAME/CONFIGURATION-MANAGEMENT.md',
    'GAME/GIT-INTEGRATION':          'GAME/GIT-INTEGRATION.md',
    'GAME/WORKFLOW-STATES':          'GAME/WORKFLOW-STATES.md',
    'GAME/MONITORING-HEARTBEATS':    'GAME/MONITORING-HEARTBEATS.md',
    'GAME/PROJECT-DOCUMENTATION':    'GAME/PROJECT-DOCUMENTATION.md',
}

content = {}
for key, path in docs.items():
    with open(path, 'r', encoding='utf-8') as f:
        content[key] = f.read()

docs_js = "const DOCS = {\n"
for key, text in content.items():
    docs_js += f"  {json.dumps(key)}: {json.dumps(text)},\n"
docs_js += "};"

html = open('index.html', 'r', encoding='utf-8').read()

# Splice in the new DOCS block (regex fails on unicode in replacement strings)
marker_start = 'const DOCS = {'
marker_end = '};'
start_idx = html.index(marker_start)
end_idx = html.index(marker_end, start_idx) + len(marker_end)
html = html[:start_idx] + docs_js + html[end_idx:]

with open('index.html', 'w', encoding='utf-8') as f:
    f.write(html)

print(f"index.html updated ({len(html):,} bytes)")
PYEOF
