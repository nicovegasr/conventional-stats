# Instalación y estructura

[← Volver al README](../README.md)

## Requisitos

| Herramienta | Mac | Linux | Windows |
|-------------|-----|-------|---------|
| zsh | integrado | `apt install zsh` | WSL2 |
| git | integrado | integrado | integrado |
| curl | integrado | integrado | — |
| PowerShell 5+ | — | — | integrado |

La CLI necesita zsh (usa arrays asociativos, que bash 3.2 de macOS no tiene). Los atajos de commit en Windows corren sobre PowerShell 5+.

---

## Qué instala y dónde

El instalador no toca nada fuera de tu directorio de usuario. Deja exactamente tres cosas:

```
~/.local/bin/conventional-stats          ← la CLI (script zsh ejecutable)
~/.config/conventional-stats/
└── git-commits.zsh                       ← los atajos de commit (feat, fix, …)
~/.zshrc                                  ← + un bloque marcado:

    # >>> conventional-stats >>>
    source "$HOME/.config/conventional-stats/git-commits.zsh"
    export PATH="$HOME/.local/bin:$PATH"
    # <<< conventional-stats <<<
```

---

## Por qué así

| Decisión | Motivo |
|----------|--------|
| Config copiada a `~/.config/conventional-stats/` | Una vez instalado, mover o borrar el repo clonado no rompe tu shell — los atajos se cargan desde tu home, no desde el clon. |
| CLI en `~/.local/bin` + `PATH` exportado | Ruta estándar de binarios de usuario; no requiere `sudo` ni tocar rutas del sistema. |
| Bloque marcado en `.zshrc` (`>>>` / `<<<`) | El desinstalador localiza y elimina **exactamente** el bloque inyectado con `sed`, sin tocar el resto de tu `.zshrc`. |
| Instalación de un comando (`curl \| bash`) | `install.sh` detecta si hay un clon local al lado: si lo hay, copia los archivos; si no, los descarga desde `main`. El mismo script sirve para ambos casos. |

---

## Instalación de un comando vs. clon local

```bash
# Sin clonar — descarga los archivos desde el repo
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/nicovegasr/conventional-stats/main/install.sh)"

# Desde un clon local — copia los archivos del clon
git clone https://github.com/nicovegasr/conventional-stats
cd conventional-stats && ./install.sh
```

Ambas rutas dejan el sistema en el mismo estado. Tras instalar:

```bash
source ~/.zshrc
```

---

## Windows

El instalador de Windows inyecta los atajos de commit (`config/git-commits.ps1`) en tu perfil de PowerShell:

```powershell
git clone https://github.com/nicovegasr/conventional-stats
cd conventional-stats
.\windows\install.ps1
```

La **CLI** `conventional-stats` es un script zsh y no corre nativamente en Windows: usa WSL2 con zsh para acceder a ella.

> ✅ Los atajos de PowerShell (`git-commits.ps1`) se testean con Pester en CI (windows-latest, PowerShell 5.1 y 7) y localmente vía `./run-ps-tests.sh`. La **CLI** sí sigue siendo solo zsh/WSL2. Ver [testing.md](testing.md).

---

## Desinstalación

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/nicovegasr/conventional-stats/main/uninstall.sh)"
source ~/.zshrc
```

Revierte el bloque de `.zshrc` (deja un backup en `.zshrc.bak`), borra el binario y el directorio de configuración. Desde un clon local: `./uninstall.sh`.
