#!/bin/bash
# CommandCenter Operation
# Name: Preview Server
# Port: 4173

# My_Github preview server
# Runs Vite in preview mode on port 4173
# Builds and serves the production preview locally

PORT=${1:-4173}
cd "$(dirname "$0")/.."

npm run preview -- --host 0.0.0.0 --port ${PORT}
