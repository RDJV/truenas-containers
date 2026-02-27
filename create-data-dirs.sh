#!/usr/bin/env bash
set -euo pipefail

BASE="/mnt/z1/truenas-containers/data"

mkdir -p \
  "$BASE/ollama" \
  "$BASE/openwebui" \
  "$BASE/comfyui/workspace" \
  "$BASE/searxng/cache" \
  "$BASE/searxng/redis" \
  "$BASE/letsencrypt"

chmod -R 755 "$BASE"

echo "Created data directories under $BASE"
