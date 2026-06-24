# conventional-stats

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

The installer handles dependencies automatically (Homebrew, tree, bat, zsh-autosuggestions, zsh-syntax-highlighting).

---

## Shell shortcuts

Every function follows the same pattern:

```
<type> "message"  →  git add . && git commit -m "<type>: message."
```

The trailing period is added automatically if missing.

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
| `revert "feat: add OAuth login"` | `revert` | Revert a previous commit |

Run `feat --help` (or any type + `--help`) to see the full list in your terminal.

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
```

Works with any repo that uses Conventional Commits — yours, a colleague's, or an open source project.

---

## Uninstall

```bash
./uninstall.sh
source ~/.zshrc
```

This removes the block added to your `.zshrc` and the `conventional-stats` binary. A `.zshrc.bak` backup is created automatically.

---

## Requirements

| Tool | Mac | Linux | Windows |
|------|-----|-------|---------|
| zsh | built-in | `apt install zsh` | WSL2 |
| git | built-in | built-in | built-in |
| PowerShell 5+ | — | — | built-in |
