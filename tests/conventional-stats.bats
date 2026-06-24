#!/usr/bin/env bats

# Tests for bin/conventional-stats

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

# ── Help ──────────────────────────────────────────────────────────────────────

@test "--help exits 0 and prints usage" {
  run zsh "$BIN" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Uso:"* ]]
}

@test "-h is an alias for --help" {
  run zsh "$BIN" -h
  [ "$status" -eq 0 ]
  [[ "$output" == *"Uso:"* ]]
}

# ── Error handling ─────────────────────────────────────────────────────────────

@test "exits 1 on non-git directory" {
  run zsh "$BIN" /tmp
  [ "$status" -eq 1 ]
  [[ "$output" == *"no es un repositorio git"* ]]
}

# ── Empty repo ────────────────────────────────────────────────────────────────

@test "shows empty message when repo has no conventional commits" {
  git -C "$TMPDIR" commit --allow-empty -m "initial" -q
  run zsh "$BIN" "$TMPDIR"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Sin commits conventional"* ]]
}

@test "exits 0 on empty repo with no commits" {
  run zsh "$BIN" "$TMPDIR"
  [ "$status" -eq 0 ]
}

# ── Commit counting ───────────────────────────────────────────────────────────

@test "counts feat commits" {
  git -C "$TMPDIR" commit --allow-empty -m "feat: add login" -q
  git -C "$TMPDIR" commit --allow-empty -m "feat: add signup" -q
  run zsh "$BIN" "$TMPDIR"
  [ "$status" -eq 0 ]
  [[ "$output" == *"feat"* ]]
  [[ "$output" == *"2"* ]]
}

@test "counts multiple types independently" {
  git -C "$TMPDIR" commit --allow-empty -m "feat: add login" -q
  git -C "$TMPDIR" commit --allow-empty -m "fix: null check" -q
  git -C "$TMPDIR" commit --allow-empty -m "fix: crash on logout" -q
  run zsh "$BIN" "$TMPDIR"
  [ "$status" -eq 0 ]
  [[ "$output" == *"feat"* ]]
  [[ "$output" == *"fix"* ]]
}

@test "supports scoped commits (feat(scope): msg)" {
  git -C "$TMPDIR" commit --allow-empty -m "feat(auth): add OAuth" -q
  run zsh "$BIN" "$TMPDIR"
  [ "$status" -eq 0 ]
  [[ "$output" == *"feat"* ]]
}

@test "supports breaking change commits (feat!: msg)" {
  git -C "$TMPDIR" commit --allow-empty -m "feat!: remove v1 API" -q
  run zsh "$BIN" "$TMPDIR"
  [ "$status" -eq 0 ]
  [[ "$output" == *"feat"* ]]
}

@test "ignores non-conventional commits" {
  git -C "$TMPDIR" commit --allow-empty -m "feat: real one" -q
  git -C "$TMPDIR" commit --allow-empty -m "WIP messy commit" -q
  git -C "$TMPDIR" commit --allow-empty -m "another irregular one" -q
  run zsh "$BIN" "$TMPDIR"
  [ "$status" -eq 0 ]
  # Total must be 1 (only the feat commit)
  [[ "$output" == *"Total    1"* ]]
}

# ── --since filter ────────────────────────────────────────────────────────────

@test "--since filter returns 0 for commits outside window" {
  # Commit everything today but ask for 0-day window (no results expected)
  git -C "$TMPDIR" commit --allow-empty -m "feat: add login" -q
  run zsh "$BIN" "$TMPDIR" 0
  [ "$status" -eq 0 ]
}

@test "--since=30 correctly passes multi-word since arg to git" {
  git -C "$TMPDIR" commit --allow-empty -m "feat: add login" -q
  run zsh "$BIN" "$TMPDIR" 30
  [ "$status" -eq 0 ]
  [[ "$output" == *"feat"* ]]
}

# ── Default to current dir ────────────────────────────────────────────────────

@test "defaults to current directory when no args" {
  git -C "$TMPDIR" commit --allow-empty -m "feat: add login" -q
  cd "$TMPDIR" && run zsh "$BIN"
  [ "$status" -eq 0 ]
}

# ── Output format ─────────────────────────────────────────────────────────────

@test "output includes repo name" {
  git -C "$TMPDIR" commit --allow-empty -m "feat: add login" -q
  REPONAME="$(basename "$TMPDIR")"
  run zsh "$BIN" "$TMPDIR"
  [ "$status" -eq 0 ]
  [[ "$output" == *"$REPONAME"* ]]
}

@test "output includes total count" {
  git -C "$TMPDIR" commit --allow-empty -m "feat: add login" -q
  git -C "$TMPDIR" commit --allow-empty -m "fix: crash" -q
  run zsh "$BIN" "$TMPDIR"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Total    2"* ]]
}
