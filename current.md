# conventional-stats — session context

## What this project is

A shell setup toolkit with two main pillars:
1. **Shell aliases and functions** that improve daily terminal UX (navigation, syntax highlighting, autosuggestions)
2. **Commit shortcut functions** that enforce Conventional Commits as you type
3. **A CLI** (`conventional-stats`) that reads a git repo and visualizes commit history by semantic type (feat, fix, chore, etc.)

The project originated from a personal `.zshrc` setup that was being shared — the goal is to make it easy for anyone to install this on Mac, Linux, or Windows with a single script.

---

## File structure

```
conventional-stats/
├── bin/
│   └── conventional-stats       # zsh CLI — analyzes a git repo's conventional commits
├── config/
│   ├── aliases.zsh              # l() tree wrapper, c=clear, zsh plugins sourcing
│   └── git-commits.zsh          # red/green/refactor + all conventional commit functions
├── windows/
│   └── install.ps1              # Windows PowerShell installer (uses Scoop)
├── install.sh                   # Mac + Linux installer (uses Homebrew)
├── uninstall.sh                 # Removes .zshrc block + binary
├── README.md                    # Public-facing article/docs
└── current.md                   # This file
```

---

## What each piece does

### `bin/conventional-stats`
- Shebang: `#!/usr/bin/env zsh` (chosen over bash to avoid macOS bash 3.2 limitation with `declare -A`)
- Usage: `conventional-stats [repo-path] [days]`
- Counts commits by type using `git log --format="%s"` + `grep -ciE "^<type>(\(.+\))?!?:"`
- Renders a bar chart scaled to the most frequent type
- Supports `--help` / `-h`
- Types covered: feat fix hotfix refactor red green docs style test chore perf ci build revert

### `config/aliases.zsh`
- Sources zsh-autosuggestions and zsh-syntax-highlighting via `brew --prefix`
- `c` = `clear`
- `l()` = tree wrapper: `tree -C -L <level> --dirsfirst --gitignore -I '.git|node_modules|__pycache__|.DS_Store'`
  - `l` → depth 1, `l 2` → depth 2, `l 2 -h` → with sizes, `l --help` → usage

### `config/git-commits.zsh`
- `_commit_help()` — shared help text listing all types
- `_do_commit()` — appends `.` if missing, runs `git add . && git commit -m`
- `_commit_fn()` — routes `--help` or empty to help, otherwise calls `_do_commit`
- Functions: `red green refactor feat fix hotfix docs style tests chore perf ci build revert`
- Note: function is named `tests` (not `test`) to avoid shadowing the zsh builtin; commit message uses `test:` prefix

### `install.sh`
- Detects Mac vs Linux via `uname -s`
- Installs Homebrew if missing
- Installs: tree, bat, zsh-autosuggestions, zsh-syntax-highlighting
- Copies `bin/conventional-stats` → `~/.local/bin/`
- Appends a guarded block to `~/.zshrc` between markers `# >>> conventional-stats >>>` and `# <<< conventional-stats <<<`

### `uninstall.sh`
- Removes the guarded block from `~/.zshrc` using `sed`, saves `.zshrc.bak`
- Removes `~/.local/bin/conventional-stats`

---

## Current state

- Install / uninstall cycle tested and working on macOS (Apple Silicon, Homebrew at `/opt/homebrew`)
- `conventional-stats` CLI tested against the repo itself — bar chart renders correctly
- README written in English (public repo standard)
- Git repo initialized with sample commits
- Windows installer written but NOT tested

---

## Known gaps / things to decide before publishing

1. **`git add .` is implicit** — every commit function stages everything. Some users may want to stage selectively first and only commit. Should there be a `--no-add` flag or a separate staged-only mode?

2. **No scope support** — Conventional Commits supports `feat(auth): message` scopes. Currently not supported in the shortcut functions.

3. **`conventional-stats` only counts, doesn't show authors or timeline** — could add `--by-author` or `--timeline` flags later.

4. **Windows installer not tested** — PowerShell script written but unverified.

5. **`install.sh` sources config files by absolute path** (the cloned repo path) — if the user moves the repo folder, sourcing breaks. Alternative: copy config files to `~/.config/conventional-stats/`.

6. **No version pinning** — the install script always installs latest brew packages.

7. **README has placeholder GitHub URL** (`your-username`) — needs real URL before publishing.

---

## Next step

Run a code-review to surface correctness issues, UX gaps, and anything that should be resolved before the repo goes public.
