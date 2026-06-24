#!/usr/bin/env bats

# Tests for config/git-commits.zsh (the feat/fix/tests/... commit shortcuts)

CONFIG="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)/config/git-commits.zsh"

setup() {
  TMPDIR="$(mktemp -d)"
  git -C "$TMPDIR" init -q
  git -C "$TMPDIR" config user.email "test@test.com"
  git -C "$TMPDIR" config user.name "Test"
  # A committed base so later `git add . && git commit` has history to build on
  echo "base" > "$TMPDIR/file.txt"
  git -C "$TMPDIR" add .
  git -C "$TMPDIR" commit -q -m "chore: init"
}

teardown() {
  rm -rf "$TMPDIR"
}

# Run a commit shortcut inside the temp repo with the functions sourced.
# Usage: run_fn "feat 'mensaje'"
run_fn() {
  run zsh -c "cd '$TMPDIR' && source '$CONFIG' && $1"
}

commit_count() { git -C "$TMPDIR" rev-list --count HEAD; }
last_subject() { git -C "$TMPDIR" log -1 --format=%s; }

# Stage a pending change so a commit has something to record
make_change() { echo "change" >> "$TMPDIR/file.txt"; }

# ── Happy path ────────────────────────────────────────────────────────────────

@test "feat \"msg\" creates a feat: commit with trailing period" {
  make_change
  run_fn "feat 'add login'"
  [ "$status" -eq 0 ]
  [ "$(last_subject)" = "feat: add login." ]
}

@test "trailing period is not duplicated when message already ends with one" {
  make_change
  run_fn "fix 'null check.'"
  [ "$status" -eq 0 ]
  [ "$(last_subject)" = "fix: null check." ]
}

@test "tests command produces a test: prefix (not tests:)" {
  make_change
  run_fn "tests 'cover edge cases'"
  [ "$status" -eq 0 ]
  [ "$(last_subject)" = "test: cover edge cases." ]
}

@test "TDD shortcut red produces a red: commit" {
  make_change
  run_fn "red 'failing auth test'"
  [ "$status" -eq 0 ]
  [ "$(last_subject)" = "red: failing auth test." ]
}

@test "every commit shortcut maps to its prefix" {
  for pair in "feat:feat" "fix:fix" "hotfix:hotfix" "refactor:refactor" \
              "red:red" "green:green" "docs:docs" "style:style" "tests:test" \
              "chore:chore" "perf:perf" "ci:ci" "build:build"; do
    cmd="${pair%%:*}"
    prefix="${pair##*:}"
    make_change
    run_fn "$cmd 'msg'"
    [ "$status" -eq 0 ]
    [ "$(last_subject)" = "$prefix: msg." ]
  done
}

@test "commit actually records the staged change, not an empty commit" {
  make_change
  run_fn "feat 'real change'"
  [ "$status" -eq 0 ]
  # The new commit must touch file.txt
  run git -C "$TMPDIR" show --stat --format= HEAD
  [[ "$output" == *"file.txt"* ]]
}

# ── Help paths create no commit ───────────────────────────────────────────────

@test "no message prints help and creates no commit" {
  run_fn "feat"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Uso:"* ]]
  [ "$(commit_count)" -eq 1 ]
}

@test "--help prints help and creates no commit" {
  run_fn "feat --help"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Uso:"* ]]
  [ "$(commit_count)" -eq 1 ]
}

@test "-h is an alias for --help and creates no commit even with pending changes" {
  make_change
  run_fn "feat -h"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Uso:"* ]]
  [ "$(commit_count)" -eq 1 ]
}

# ── Unknown options ───────────────────────────────────────────────────────────

@test "unknown short option is rejected with a help hint and no commit" {
  make_change
  run_fn "feat -hacd"
  [ "$status" -eq 1 ]
  [[ "$output" == *"opción desconocida"* ]]
  [[ "$output" == *"'-hacd'"* ]]
  [[ "$output" == *"feat -h"* ]]
  [ "$(commit_count)" -eq 1 ]
}

@test "unknown long option is rejected with no commit" {
  make_change
  run_fn "feat --bogus"
  [ "$status" -eq 1 ]
  [[ "$output" == *"opción desconocida"* ]]
  [ "$(commit_count)" -eq 1 ]
}

@test "single unknown dash flag is rejected with no commit" {
  make_change
  run_fn "feat -x"
  [ "$status" -eq 1 ]
  [[ "$output" == *"opción desconocida"* ]]
  [ "$(commit_count)" -eq 1 ]
}

# ── Quoting enforcement ───────────────────────────────────────────────────────

@test "multi-word message without quotes is rejected with no commit" {
  make_change
  run_fn "feat add login flow"
  [ "$status" -eq 1 ]
  [[ "$output" == *"entre comillas"* ]]
  [ "$(commit_count)" -eq 1 ]
}

@test "single bare word is indistinguishable from quoted and does commit" {
  # `feat hola` and `feat "hola"` produce an identical argv; the shell strips
  # the quotes before the function runs, so a lone word cannot be rejected.
  make_change
  run_fn "feat hola"
  [ "$status" -eq 0 ]
  [ "$(last_subject)" = "feat: hola." ]
}
