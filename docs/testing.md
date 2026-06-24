# Testing

[← Volver al README](../README.md)

El proyecto se testea con [BATS](https://github.com/bats-core/bats-core) (Bash Automated Testing System) y se valida con [ShellCheck](https://www.shellcheck.net/) en CI.

---

## Qué se testea

### `tests/conventional-stats.bats` — la CLI (24 tests)

Ejecuta el binario real contra repos git temporales y comprueba:

- **Ayuda y errores:** `--help` / `-h` salen con 0 e imprimen el uso; un directorio que no es git sale con 1.
- **Conteo de commits:** cuenta `feat`, `fix`, etc. de forma independiente; reconoce los 14 tipos.
- **Variantes de Conventional Commits:** scopes (`feat(auth):`), breaking changes (`feat!:`, `feat(auth)!:`).
- **Filtrado:** `--since` por días pasa correctamente el argumento multi-palabra a git; los tipos con 0 commits no se imprimen.
- **Salida JSON:** `--json` produce `repo`, `period`, `commits[]` y `total`; funciona con filtro de días y en cualquier posición del argumento.

### `tests/git-commits.bats` — los atajos de commit (14 tests)

Sourcea `config/git-commits.zsh` dentro de un repo temporal y comprueba:

- **Happy path:** `feat "msg"` crea `feat: msg.`; el punto final no se duplica; los 13 atajos mapean a su prefijo (incluyendo `tests` → `test:`); el commit registra el cambio real.
- **Ayuda sin commit:** sin mensaje, `-h` y `--help` imprimen ayuda y no crean ningún commit.
- **Opciones desconocidas:** `feat -x`, `feat -hacd`, `feat --bogus` se rechazan con código 1 y sin commit.
- **Comillas:** un mensaje multi-palabra sin comillas se rechaza; una palabra suelta (indistinguible de entrecomillada) sí commitea.

---

## Cómo ejecutarlos

Necesitas `zsh` y `bats`:

```bash
# macOS
brew install bats-core

# Ubuntu/Debian
sudo apt-get install -y zsh bats
```

Desde la raíz del repo:

```bash
bats tests/                       # toda la suite
bats tests/conventional-stats.bats   # solo la CLI
bats tests/git-commits.bats          # solo los atajos
```

---

## Pipeline de CI

`.github/workflows/ci.yml` se ejecuta en cada push y pull request a `main`, con dos jobs:

| Job | Qué hace |
|-----|----------|
| **ShellCheck** | Analiza todos los scripts (`severity: error`) en ubuntu-latest. |
| **BATS** | Corre `bats tests/` en una matriz de **ubuntu-latest** y **macos-latest** (instalando zsh + bats en cada uno). |

Que la matriz incluya macOS importa: la CLI usa `#!/usr/bin/env zsh` precisamente porque el bash de macOS es la versión 3.2.

---

## Windows / PowerShell — no testeado

`config/git-commits.ps1` replica la lógica de los atajos de zsh (mismo comportamiento: comillas obligatorias, ayuda con `-h`/`--help`, rechazo de opciones desconocidas), pero:

- **No hay pwsh en la matriz de CI** — esa rama no se ejecuta en cada push.
- El binding de argumentos con guion de PowerShell tiene reglas propias que **no están verificadas** en este entorno.

Tómalo como "best effort" hasta que se añada un job de PowerShell a CI.
