# conventional-stats

![CI](https://github.com/nicovegasr/conventional-stats/actions/workflows/ci.yml/badge.svg)

Un toolkit de shell minimalista para desarrolladores — haz commits más rápido con atajos de teclado y visualiza el historial de tus [Conventional Commits](https://www.conventionalcommits.org/) directamente desde la terminal.

![Demo de conventional-stats en un repo real](assets/demo.png)

---

## Instalación

### Mac / Linux

Un solo comando, sin clonar el repo:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/nicovegasr/conventional-stats/main/install.sh)"
source ~/.zshrc
```

El instalador descarga la CLI a `~/.local/bin` y los atajos de commit a `~/.config/conventional-stats/`, y añade un bloque marcado a tu `.zshrc`. No deja nada más en tu sistema. Si prefieres clonar el repo, `./install.sh` funciona igual desde el clon local.

### Windows (PowerShell)

```powershell
git clone https://github.com/nicovegasr/conventional-stats
cd conventional-stats
.\windows\install.ps1
```

> **Nota:** La CLI (`conventional-stats`) es un script zsh y no funciona de forma nativa en Windows — usa WSL2 con zsh para acceder a ella. Los atajos de commit sí funcionan en PowerShell sin WSL2 y **se testean en CI** (Pester en windows-latest, PowerShell 5.1 y 7 — ver [docs/testing.md](docs/testing.md)).

---

## Desinstalación

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/nicovegasr/conventional-stats/main/uninstall.sh)"
source ~/.zshrc
```

Elimina el bloque añadido a tu `.zshrc` (con backup en `.zshrc.bak`), el binario `conventional-stats` y el directorio de configuración. Desde un clon local, `./uninstall.sh` hace lo mismo.

---

## Documentación

| Documento | Contenido |
|-----------|-----------|
| [docs/installation.md](docs/installation.md) | Requisitos, qué instala y dónde (esquema), y por qué cada decisión |
| [docs/cli.md](docs/cli.md) | La CLI `conventional-stats`: uso, salida JSON y cómo funciona por dentro |
| [docs/shortcuts.md](docs/shortcuts.md) | Los atajos de commit (`feat`, `fix`, …): uso, reglas y flujo interno |
| [docs/testing.md](docs/testing.md) | Qué se testea, cómo ejecutar los tests y el pipeline de CI |

---

## Qué te da

1. **Atajos de shell** que refuerzan Conventional Commits mientras escribes — `feat "añadir login"` → `git add . && git commit -m "feat: añadir login."`
2. **Una CLI** para auditar el historial de cualquier repo por tipo semántico, directamente desde la terminal.
