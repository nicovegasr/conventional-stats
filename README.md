# conventional-stats

![CI](https://github.com/nicovegasr/conventional-stats/actions/workflows/ci.yml/badge.svg)

A lightweight shell toolkit for speed-focused developers — commit faster with shell shortcuts and visualize your [Conventional Commits](https://www.conventionalcommits.org/) history at a glance.

```
📊 conventional-stats — my-app (last 90 days)
──────────────────────────────────────────────────
  feat      ████████████████████████  12
  fix       ████████████████          8
  chore     ████████                  4
  refactor  ████████                  4
  docs      ████                      2
──────────────────────────────────────────────────
  Total    30 commits
```

---

## Why

Most developers already follow Conventional Commits — but almost nobody visualizes them. `conventional-stats` gives you two things:

1. **Shell shortcuts** that enforce the convention as you type — `feat "add login"` → `git add . && git commit -m "feat: add login."`
2. **A CLI** to audit any repo's commit history by semantic type, directly from the terminal

---

## Installation

### Mac / Linux

```bash
git clone https://github.com/nicovegasr/conventional-stats
cd conventional-stats
./install.sh
source ~/.zshrc
```

### Windows (PowerShell)

```powershell
git clone https://github.com/nicovegasr/conventional-stats
cd conventional-stats
.\windows\install.ps1
```

> **Note:** The CLI (`conventional-stats`) is a zsh script and does not run natively on Windows. Use WSL2 with zsh to access it. The shell commit shortcuts work in PowerShell without WSL2.

---

## Shell shortcuts

Every function follows the same pattern:

```
<type> "message"  →  git add . && git commit -m "<type>: message."
```

The trailing period is added automatically if missing. Multi-word messages work without quotes: `feat add login flow`.

#### TDD workflow

| Command | Commit message |
|---------|---------------|
| `red "failing auth test"` | `red: failing auth test.` |
| `green "auth test passes"` | `green: auth test passes.` |
| `refactor "extract auth helper"` | `refactor: extract auth helper.` |

#### Conventional Commits

| Command | Type | When to use |
|---------|------|-------------|
| `feat "add OAuth login"` | `feat` | New feature |
| `fix "null check on logout"` | `fix` | Bug fix |
| `hotfix "patch XSS in input"` | `hotfix` | Urgent production fix |
| `docs "update API reference"` | `docs` | Documentation |
| `style "format controllers"` | `style` | Formatting, no logic change |
| `tests "cover edge cases"` | `test` | Tests added or fixed |
| `chore "upgrade dependencies"` | `chore` | Maintenance, tooling |
| `perf "cache DB queries"` | `perf` | Performance improvement |
| `ci "add lint step"` | `ci` | CI/CD configuration |
| `build "switch to esbuild"` | `build` | Build system |

Run `feat --help` (or any type + `--help`) to see the full list in your terminal.

> **Reverting commits:** use `git revert <hash>` directly — git generates the correct conventional message automatically (`Revert "feat: ..."`), and `conventional-stats` will count it in the `revert` category.

---

## conventional-stats CLI

Analyze any git repo by commit type:

```bash
# Current directory
conventional-stats

# Specific repo
conventional-stats ~/projects/my-app

# Filter by date range
conventional-stats ~/projects/my-app 90

# JSON output (pipeable to jq, scripts, etc.)
conventional-stats --json ~/projects/my-app
conventional-stats --json ~/projects/my-app 90
```

JSON output format:

```json
{
  "repo": "my-app",
  "period": "últimos 90 días",
  "commits": [
    { "type": "feat", "count": 12 },
    { "type": "fix", "count": 8 }
  ],
  "total": 20
}
```

Works with any repo that uses Conventional Commits — yours, a colleague's, or an open source project.

---

## How it works

### Shell shortcut call flow

```
feat "add login"
  └─ _dispatch_commit "feat" "add login"
       └─ _execute_commit "feat" "add login."
            └─ git add . && git commit -m "feat: add login."
```

Three layers: public commands fix the commit type and delegate to `_dispatch_commit`, which handles `--help` and empty-input cases, then calls `_execute_commit` for the actual git operation.

### CLI data pipeline

```
conventional-stats ~/my-app 90
  └─ git log --format="%s" --since="90 days ago"   (single subprocess)
       └─ regex match per commit subject             (in-memory, no extra forks)
            └─ proportional bar chart → stdout
```

A single `git log` reads all subjects; the per-type counts are built in an associative array. Bar width scales so the type with the most commits always fills the full 24-character column.

### Key design decisions

| Decision | Reason |
|----------|--------|
| Single `git log` for all types | Avoids one subprocess per type (14 forks vs. 1) |
| `--since` stored as an array | Prevents word-splitting on `"30 days ago"` during expansion |
| Config copied to `~/.config/conventional-stats/` | Moving or deleting the cloned repo doesn't break the shell |
| Marker blocks in `.zshrc` | `uninstall.sh` can locate and remove exactly the injected block |
| CLI uses `#!/usr/bin/env zsh` | macOS ships bash 3.2 (no associative arrays); zsh is built-in on Apple Silicon |
| Shell command `tests` → commit prefix `test:` | Avoids shadowing the `test` builtin in zsh |

---

## Project structure

```
conventional-stats/
├── bin/conventional-stats      # CLI: reads git history, renders bar chart
├── config/
│   ├── git-commits.zsh         # Commit shortcuts sourced into .zshrc (Unix/macOS)
│   └── git-commits.ps1         # Commit shortcuts dot-sourced into PS profile (Windows)
├── tests/
│   └── conventional-stats.bats # BATS test suite for the CLI
├── install.sh                  # Copies CLI to ~/.local/bin, injects .zshrc block
├── uninstall.sh                # Removes CLI, config dir, and .zshrc block
└── windows/
    └── install.ps1             # Injects git-commits.ps1 into PowerShell profile
```

---

## Uninstall

```bash
./uninstall.sh
source ~/.zshrc
```

This removes the block added to your `.zshrc`, the `conventional-stats` binary, and the config directory. A `.zshrc.bak` backup is created automatically.

---

## Requirements

| Tool | Mac | Linux | Windows |
|------|-----|-------|---------|
| zsh | built-in | `apt install zsh` | WSL2 |
| git | built-in | built-in | built-in |
| PowerShell 5+ | — | — | built-in |
