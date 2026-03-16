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
    'METHODOLOGY':                       'METHODOLOGY.md',
    'THE-CONTRACT':                      'THE-CONTRACT.md',
    'PERSISTENCE':                       'PERSISTENCE.md',
    'OPERATIONS':                        'OPERATIONS.md',
    'LOGGING':                           'LOGGING.md',
    'features/CONTROL-PANEL':            'features/CONTROL-PANEL.md',
    'features/PROJECT-DISCOVERY':        'features/PROJECT-DISCOVERY.md',
    'features/OPERATIONS-ENGINE':        'features/OPERATIONS-ENGINE.md',
    'features/PROCESS-MONITOR':          'features/PROCESS-MONITOR.md',
    'features/GITHUB-PUBLISHER':         'features/GITHUB-PUBLISHER.md',
    'features/TAG-MANAGEMENT':           'features/TAG-MANAGEMENT.md',
    'features/USAGE-ANALYTICS':          'features/USAGE-ANALYTICS.md',
    'features/CONFIGURATION-MANAGEMENT': 'features/CONFIGURATION-MANAGEMENT.md',
    'features/GIT-INTEGRATION':          'features/GIT-INTEGRATION.md',
    'features/WORKFLOW-STATES':          'features/WORKFLOW-STATES.md',
    'features/MONITORING-HEARTBEATS':    'features/MONITORING-HEARTBEATS.md',
    'features/PROJECT-DOCUMENTATION':    'features/PROJECT-DOCUMENTATION.md',
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
