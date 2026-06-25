#!/usr/bin/env bats

# Tests for `conventional-stats audit` (change-frequency hotspots)

BIN="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)/bin/conventional-stats"

setup() {
  TMPDIR="$(mktemp -d)"
  git -C "$TMPDIR" init -q
  git -C "$TMPDIR" config user.email "test@test.com"
  git -C "$TMPDIR" config user.name "Test"
}

teardown() {
  rm -rf "$TMPDIR"
}

# commit_file PATH CONTENT — writes a file (creating dirs) and commits it.
commit_file() {
  local rel="$1" content="$2"
  mkdir -p "$TMPDIR/$(dirname "$rel")"
  echo "$content" >> "$TMPDIR/$rel"
  git -C "$TMPDIR" add -A
  git -C "$TMPDIR" commit -qm "feat: touch $rel"
}

# ── Help ──────────────────────────────────────────────────────────────────────

@test "audit --help exits 0 and prints usage" {
  run zsh "$BIN" audit --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Uso: conventional-stats audit"* ]]
}

# ── Error handling ─────────────────────────────────────────────────────────────

@test "audit exits 1 on non-git directory" {
  run zsh "$BIN" audit --repo /tmp
  [ "$status" -eq 1 ]
  [[ "$output" == *"no es un repositorio git"* ]]
}

@test "audit rejects unknown options" {
  run zsh "$BIN" audit --repo "$TMPDIR" --bogus
  [ "$status" -eq 1 ]
  [[ "$output" == *"opción desconocida"* ]]
}

# ── Empty repo ────────────────────────────────────────────────────────────────

@test "audit shows empty message when repo has no changes" {
  git -C "$TMPDIR" commit --allow-empty -m "feat: empty" -q
  run zsh "$BIN" audit --repo "$TMPDIR"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Sin cambios en este rango"* ]]
}

# ── Ranking ────────────────────────────────────────────────────────────────────

@test "audit ranks the most-changed file first" {
  commit_file "hot.txt" "a"
  commit_file "hot.txt" "b"
  commit_file "hot.txt" "c"
  commit_file "cold.txt" "x"
  run zsh "$BIN" audit --repo "$TMPDIR"
  [ "$status" -eq 0 ]
  # hot.txt must appear before cold.txt in the output
  [[ "$output" == *hot.txt*cold.txt* ]]
}

@test "audit reports commit count per file" {
  commit_file "a.txt" "1"
  commit_file "a.txt" "2"
  run zsh "$BIN" audit --repo "$TMPDIR"
  [ "$status" -eq 0 ]
  [[ "$output" == *"a.txt"* ]]
  [[ "$output" == *"2"* ]]
}

# ── Default ignores ─────────────────────────────────────────────────────────────

@test "audit ignores lockfiles by default" {
  commit_file "pnpm-lock.yaml" "lock"
  commit_file "src.js" "code"
  run zsh "$BIN" audit --repo "$TMPDIR"
  [ "$status" -eq 0 ]
  [[ "$output" == *"src.js"* ]]
  [[ "$output" != *"pnpm-lock.yaml"* ]]
}

@test "audit ignores build/ directory by default at any depth" {
  commit_file "app/build/out.o" "bin"
  commit_file "main.c" "code"
  run zsh "$BIN" audit --repo "$TMPDIR"
  [ "$status" -eq 0 ]
  [[ "$output" == *"main.c"* ]]
  [[ "$output" != *"out.o"* ]]
}

# ── --ignore ────────────────────────────────────────────────────────────────────

@test "audit --ignore excludes by glob pattern" {
  commit_file "lib.gradle" "g"
  commit_file "main.kt" "k"
  run zsh "$BIN" audit --repo "$TMPDIR" --ignore '*.gradle'
  [ "$status" -eq 0 ]
  [[ "$output" == *"main.kt"* ]]
  [[ "$output" != *"lib.gradle"* ]]
}

@test "audit --ignore excludes by directory pattern" {
  commit_file "gen/a.txt" "g"
  commit_file "main.kt" "k"
  run zsh "$BIN" audit --repo "$TMPDIR" --ignore 'gen/'
  [ "$status" -eq 0 ]
  [[ "$output" == *"main.kt"* ]]
  [[ "$output" != *"gen/a.txt"* ]]
}

@test "audit --ignore accepts multiple patterns" {
  commit_file "lib.gradle" "g"
  commit_file "gen/a.txt" "x"
  commit_file "main.kt" "k"
  run zsh "$BIN" audit --repo "$TMPDIR" --ignore '*.gradle' 'gen/'
  [ "$status" -eq 0 ]
  [[ "$output" == *"main.kt"* ]]
  [[ "$output" != *"lib.gradle"* ]]
  [[ "$output" != *"gen/a.txt"* ]]
}

# ── --set-ignore ────────────────────────────────────────────────────────────────

@test "audit --set-ignore persists patterns in .auditignore" {
  run zsh "$BIN" audit --repo "$TMPDIR" --set-ignore '*.gradle' '/build/*'
  [ "$status" -eq 0 ]
  [ -f "$TMPDIR/.auditignore" ]
  run cat "$TMPDIR/.auditignore"
  [[ "$output" == *'*.gradle'* ]]
  [[ "$output" == *'/build/*'* ]]
}

@test "audit --set-ignore does not duplicate existing patterns" {
  zsh "$BIN" audit --repo "$TMPDIR" --set-ignore '*.gradle'
  zsh "$BIN" audit --repo "$TMPDIR" --set-ignore '*.gradle'
  run grep -c '\*.gradle' "$TMPDIR/.auditignore"
  [ "$output" -eq 1 ]
}

@test "audit honours patterns saved in .auditignore" {
  commit_file "lib.gradle" "g"
  commit_file "main.kt" "k"
  zsh "$BIN" audit --repo "$TMPDIR" --set-ignore '*.gradle'
  run zsh "$BIN" audit --repo "$TMPDIR"
  [ "$status" -eq 0 ]
  [[ "$output" == *"main.kt"* ]]
  [[ "$output" != *"lib.gradle"* ]]
}

# ── Fix counting & instability ───────────────────────────────────────────────────

@test "audit counts fix and hotfix commits per file" {
  mkdir -p "$TMPDIR"
  echo "a" >> "$TMPDIR/a.txt";  git -C "$TMPDIR" add -A; git -C "$TMPDIR" commit -qm "feat: add a"
  echo "b" >> "$TMPDIR/a.txt";  git -C "$TMPDIR" add -A; git -C "$TMPDIR" commit -qm "fix: bug in a"
  echo "c" >> "$TMPDIR/a.txt";  git -C "$TMPDIR" add -A; git -C "$TMPDIR" commit -qm "hotfix(a): urgent"
  run zsh "$BIN" audit --repo "$TMPDIR" --json
  [ "$status" -eq 0 ]
  [[ "$output" == *'"fixes": 2'* ]]
}

@test "audit does not count feat as a fix" {
  commit_file "a.txt" "1"
  commit_file "a.txt" "2"
  run zsh "$BIN" audit --repo "$TMPDIR" --json
  [ "$status" -eq 0 ]
  [[ "$output" == *'"fixes": 0'* ]]
}

# ── Renames ────────────────────────────────────────────────────────────────────

@test "audit attributes a renamed file to its new name (no '=>' phantom path)" {
  echo "x" >> "$TMPDIR/old.txt"; git -C "$TMPDIR" add -A; git -C "$TMPDIR" commit -qm "feat: add old"
  git -C "$TMPDIR" mv old.txt new.txt
  echo "y" >> "$TMPDIR/new.txt"; git -C "$TMPDIR" add -A; git -C "$TMPDIR" commit -qm "refactor: rename"
  run zsh "$BIN" audit --repo "$TMPDIR"
  [ "$status" -eq 0 ]
  [[ "$output" == *"new.txt"* ]]
  [[ "$output" != *"=>"* ]]
}

# ── JSON ─────────────────────────────────────────────────────────────────────────

@test "audit --json outputs repo, period and hotspots" {
  commit_file "a.txt" "1"
  commit_file "a.txt" "2"
  run zsh "$BIN" audit --repo "$TMPDIR" --json
  [ "$status" -eq 0 ]
  [[ "$output" == *'"repo"'* ]]
  [[ "$output" == *'"hotspots"'* ]]
  [[ "$output" == *'"file": "a.txt"'* ]]
  [[ "$output" == *'"commits": 2'* ]]
}

@test "audit --json includes a per-type breakdown" {
  echo "a" >> "$TMPDIR/a.txt"; git -C "$TMPDIR" add -A; git -C "$TMPDIR" commit -qm "feat: add a"
  echo "b" >> "$TMPDIR/a.txt"; git -C "$TMPDIR" add -A; git -C "$TMPDIR" commit -qm "fix: a"
  run zsh "$BIN" audit --repo "$TMPDIR" --json
  [ "$status" -eq 0 ]
  [[ "$output" == *'"types"'* ]]
  [[ "$output" == *'"feat": 1'* ]]
  [[ "$output" == *'"fix": 1'* ]]
}

@test "audit --json is valid parseable JSON" {
  command -v jq >/dev/null || skip "jq not installed"
  commit_file "a.txt" "1"
  commit_file "b.txt" "2"
  run bash -c "zsh '$BIN' audit --repo '$TMPDIR' --json | jq -e '.hotspots | length >= 2'"
  [ "$status" -eq 0 ]
}

# ── Period label ─────────────────────────────────────────────────────────────────

@test "audit shows period label when DAYS arg is given" {
  commit_file "a.txt" "1"
  run zsh "$BIN" audit --repo "$TMPDIR" --days 30
  [ "$status" -eq 0 ]
  [[ "$output" == *"últimos 30 días"* ]]
}

# ── Performance regression guard ─────────────────────────────────────────────────
# Not a benchmark — a catastrophe guard. Synthesizes a large history and asserts
# audit still finishes well within a generous ceiling, so an accidental O(n²)
# regression (e.g. reverting the awk pass to a shell loop) is caught. The ceiling
# is deliberately loose to avoid flaking on shared CI runners.

@test "audit handles a large history within a generous time budget" {
  command -v git >/dev/null || skip "git required"
  GEN="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)/scripts/gen-repo.sh"
  BIG="$(mktemp -d)"
  bash "$GEN" 3000 200 "$BIG" >/dev/null 2>&1 || { rm -rf "$BIG"; skip "fast-import unavailable"; }

  start=$SECONDS
  run zsh "$BIN" audit --repo "$BIG"
  elapsed=$((SECONDS - start))
  rm -rf "$BIG"

  [ "$status" -eq 0 ]
  echo "audit over 3000 commits took ${elapsed}s (budget 20s)"
  [ "$elapsed" -lt 20 ]
}
