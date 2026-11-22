#!/usr/bin/env bash
# Regenerate Data/ObservedLevels.lua from a saved BootyBayBroker disenchant page.
# BootyBayBroker returns 403 to scripts: save the page from a browser first.
#
# Usage:
#   ./scripts/update-observed-levels.sh <saved-page.html> [--dry-run] [--no-bump]
set -euo pipefail

if [[ $# -lt 1 || "$1" == "-h" || "$1" == "--help" ]]; then
  sed -n '2,7p' "$0"
  exit 0
fi

command -v lua >/dev/null 2>&1 || { echo "lua not found on PATH" >&2; exit 1; }
cd "$(dirname "$0")/.."
lua scripts/update_observed_levels.lua "$@"
