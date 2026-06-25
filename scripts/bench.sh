#!/usr/bin/env bash
# On-demand performance benchmark for the conventional-stats commands.
# Builds a synthetic repo and times `audit` and the main stats command.
# Uses hyperfine (statistical, warm-up) when available, else falls back to time.
#
# Usage: scripts/bench.sh [commits] [files]
#   defaults: 20000 commits over 500 files
set -euo pipefail

COMMITS="${1:-20000}"
FILES="${2:-500}"

HERE="$(cd "$(dirname "$0")/.." && pwd)"
BIN="$HERE/bin/conventional-stats"
REPO="$(mktemp -d)"
trap 'rm -rf "$REPO"' EXIT

echo "▶ generando repo sintético: ${COMMITS} commits, ${FILES} ficheros…"
time "$HERE/scripts/gen-repo.sh" "$COMMITS" "$FILES" "$REPO" >/dev/null
echo "  commits reales: $(git -C "$REPO" rev-list --count HEAD)"
echo ""

run_bench() {
  local label="$1"; shift
  echo "▶ ${label}"
  if command -v hyperfine >/dev/null 2>&1; then
    hyperfine --warmup 1 --runs 5 "$*"
  else
    echo "  (hyperfine no instalado — usando 'time', una pasada)"
    time eval "$*" >/dev/null
  fi
  echo ""
}

run_bench "conventional-stats audit"        "zsh '$BIN' audit --repo '$REPO'"
run_bench "conventional-stats audit --json" "zsh '$BIN' audit --repo '$REPO' --json"
run_bench "conventional-stats (stats)"      "zsh '$BIN' '$REPO'"
