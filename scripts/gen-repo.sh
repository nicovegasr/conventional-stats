#!/usr/bin/env bash
# Generate a synthetic git repo for benchmarking / perf regression tests.
# Uses `git fast-import` so thousands of commits are created in well under a
# second (a real `git commit` loop would take minutes).
#
# Usage: gen-repo.sh <commits> <files> <dir>
#   commits  number of commits to synthesize
#   files    number of distinct files to spread changes across
#   dir      target directory (created; must not already be a repo)
set -euo pipefail

COMMITS="${1:?commits required}"
FILES="${2:?files required}"
DIR="${3:?dir required}"

mkdir -p "$DIR"
git -C "$DIR" init -q

# Emit a fast-import stream: rotate commit types (so some are fix/hotfix) and
# spread changes over $FILES files in a handful of module directories.
awk -v n="$COMMITS" -v files="$FILES" '
  BEGIN {
    split("feat fix hotfix refactor docs chore test perf", types, " ")
    nt = 8
    for (i = 1; i <= n; i++) {
      t = types[(i % nt) + 1]
      f = "src/mod" (i % 10) "/file" (i % files) ".txt"
      print "commit refs/heads/main"
      print "committer Bench <bench@test> " (1700000000 + i) " +0000"
      print "data <<EOM"
      print t ": change " i
      print "EOM"
      print "M 100644 inline " f
      print "data <<EOB"
      print "line " i " of " f
      print "EOB"
      print ""
    }
  }
' | git -C "$DIR" fast-import --quiet

git -C "$DIR" reset -q --hard main
