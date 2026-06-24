# conventional-stats — Plan de hardening pre-publicación

Fases derivadas del code review del 2026-06-24. Cada fase termina con un commit.

---

## Phase 1 — Critical CLI bugs `[x]`

Dos bugs silenciosos en `bin/conventional-stats` que producen resultados incorrectos.

| Issue | Línea | Descripción |
|-------|-------|-------------|
| #1 | 47 | `${=SINCE}` word-splits `--since=30 days ago` en tres args; git falla en silencio y todos los conteos devuelven 0 cuando se pasa `[days]` |
| #5 | 53 | `{1..0}` en zsh desciende (`1 0`), imprimiendo 2 bloques de barra para el tipo menos frecuente en lugar de 0 |

**Criterio de éxito:** `conventional-stats . 30` muestra conteos reales; tipos con n=1 y max=100 muestran barra proporcional correcta.

---

## Phase 2 — Shell function UX `[x]`

Tres problemas en `config/git-commits.zsh` que confunden o pierden datos silenciosamente.

| Issue | Línea | Descripción |
|-------|-------|-------------|
| #4 | 38 | Wrappers solo pasan `$1`; mensaje sin comillas se trunca al primer palabra sin avisar |
| #6 | 46 | Función `tests` genera prefijo `test:` pero el help dice `tests`; incoherente |
| #7 | 38 | Llamar sin argumento en shell con `set -u` lanza "unbound variable" en vez del help |

**Criterio de éxito:** `feat add user login` (sin comillas) da error claro; `tests --help` muestra el tipo correcto; `feat` sin args muestra help en cualquier shell.

---

## Phase 3 — Windows installer `[x]`

El instalador de Windows está completamente roto: crea entradas rotas en el perfil y no instala el CLI.

| Issue | Línea | Descripción |
|-------|-------|-------------|
| #2 | 48 | Dot-source de `config\aliases.ps1` y `config\git-commits.ps1` que no existen → cada sesión PS falla al arrancar |
| #3 | 1 | `conventional-stats` CLI nunca se instala ni shimmea en Windows |

**Criterio de éxito:** Crear `config/aliases.ps1` y `config/git-commits.ps1` con equivalentes PowerShell; installer copia o referencia el CLI correctamente.

---

## Phase 4 — Code quality & architecture `[ ]`

Mejoras de mantenibilidad y rendimiento que no bloquean la publicación pero sí la calidad a largo plazo.

| Issue | Línea | Descripción |
|-------|-------|-------------|
| #8 | 34 | Array `LABELS` es un duplicado posicional de `TYPES` con padding manual; un desajuste silencia el label incorrecto |
| #9 | 61 | `install.sh` hardcodea la ruta absoluta del repo en `.zshrc`; mover el repo rompe la shell |
| #10 | 46 | 14 forks de `git log` en serie (uno por tipo) en lugar de una sola llamada |

**Criterio de éxito:** `LABELS` eliminado; configs copiados a `~/.config/conventional-stats/` en install; `git log` llamado una vez.

---

## Phase 5 — Naming, testing & CI/CD `[ ]`

Fase de madurez post-publicación. Se planificará en detalle al llegar.

Áreas candidatas:
- **Naming review**: revisar nombres de funciones, variables y archivos con consistencia cross-platform
- **Test suite**: BATS (Bash Automated Testing System) para `bin/conventional-stats` e `install.sh`
- **CI/CD**: GitHub Actions — lint (shellcheck), tests en ubuntu + macos, badge en README
- **Version pinning**: gestión de versiones de dependencias Homebrew/Scoop
- **README**: reemplazar URL placeholder `your-username`, añadir badge de CI

---

## Progreso

| Phase | Estado | Commit |
|-------|--------|--------|
| 1 | `[x]` completa | fix: correct --since filter and bar chart zero-fill |
| 2 | `[x]` completa | fix: pass full message and clarify tests/test: naming |
| 3 | `[x]` completa | feat: add PowerShell config files and fix Windows installer |
| 4 | `[ ]` pendiente | — |
| 5 | `[ ]` pendiente | — |
