#!/usr/bin/env bash
# Fallback one-shot if postCreate path fails due to trust/path issues
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

ROOT=""
for d in /workspaces/* /workspaces /home/vscode /home/codespace; do
  if [[ -d "$d/custom" ]]; then ROOT="$d"; break; fi
done
if [[ -z "$ROOT" ]]; then ROOT="$(pwd)"; fi
cd "$ROOT"
echo "[bootstrap] root=$ROOT"

git config --global --add safe.directory "*" 2>/dev/null || true
git config --global --add safe.directory "$ROOT" 2>/dev/null || true

bash "$ROOT/.devcontainer/setup.sh"
bash "$ROOT/.devcontainer/start-miner.sh"
