# Testing

[← Volver al README](../README.md)

El proyecto se testea con [BATS](https://github.com/bats-core/bats-core) (los scripts de shell) y [Pester](https://pester.dev/) (los atajos de PowerShell), y se valida con [ShellCheck](https://www.shellcheck.net/) en CI.

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

### `tests/git-commits.Tests.ps1` — los atajos de PowerShell (12 tests, Pester)

Espejo de la suite de zsh, sobre `config/git-commits.ps1`: happy path y prefijos, ayuda (sin mensaje / `-h` / `--help`) sin commit, rechazo de opciones desconocidas (`-x`, `-hacd`, `--bogus`) y de mensajes multi-palabra sin comillas.

> Estos tests destaparon un bug real: las wrappers usaban splat `@args`, que hace que PowerShell interprete los tokens con guion como nombres de parámetro antes de llegar a la validación. Se arregló pasando `$args` como un único array (sin splat). Ver [shortcuts.md](shortcuts.md).

---

## Cómo ejecutarlos

### BATS (shell)

Necesitas `zsh` y `bats`:

```bash
# macOS
brew install bats-core

# Ubuntu/Debian
sudo apt-get install -y zsh bats
```

Desde la raíz del repo:

```bash
bats tests/                          # toda la suite de shell
bats tests/conventional-stats.bats   # solo la CLI
bats tests/git-commits.bats          # solo los atajos zsh
```

### Pester (PowerShell)

Si tienes PowerShell + Pester instalados:

```bash
pwsh -Command "Invoke-Pester -Path tests/git-commits.Tests.ps1 -Output Detailed"
```

Si no, hay un runner que lo corre dentro de un contenedor (requiere Docker):

```bash
./run-ps-tests.sh
```

> Usa la imagen `mcr.microsoft.com/dotnet/sdk` porque trae `pwsh` + `git` nativos para arm64. La imagen suelta `mcr.microsoft.com/powershell` es solo amd64 y **segfaultea bajo emulación QEMU en Apple Silicon**.

---

## Pipeline de CI

`.github/workflows/ci.yml` se ejecuta en cada push y pull request a `main`, con tres jobs:

| Job | Qué hace |
|-----|----------|
| **ShellCheck** | Analiza todos los scripts (`severity: error`) en ubuntu-latest. |
| **BATS** | Corre `bats tests/` en una matriz de **ubuntu-latest** y **macos-latest** (instalando zsh + bats en cada uno). |
| **Pester** | Corre `Invoke-Pester` en **windows-latest**, en matriz de **Windows PowerShell 5.1** (`powershell`) y **PowerShell 7** (`pwsh`). |

Que la matriz de BATS incluya macOS importa: la CLI usa `#!/usr/bin/env zsh` precisamente porque el bash de macOS es la versión 3.2. Y que el job de Pester cubra 5.1 **y** 7 importa porque el binding de argumentos con guion es justo donde PowerShell puede diferir entre versiones.

> ℹ️ Los tests de Pester pasan en pwsh 7 (verificado localmente vía Docker). El job de `windows-latest` los valida además en Windows PowerShell 5.1, el runtime real de la mayoría de usuarios de Windows. Los runners de Windows facturan 2× minutos en GitHub-hosted, pero la suite es pequeña.
