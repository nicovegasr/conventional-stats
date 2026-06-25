# CLI `conventional-stats`

[← Volver al README](../README.md)

Analiza cualquier repo git por tipo de commit y renderiza un gráfico de barras proporcional en la terminal. Funciona con cualquier repo que use Conventional Commits — el tuyo, el de un compañero o un proyecto open source.

---

## Uso

```bash
# Directorio actual
conventional-stats

# Repo específico
conventional-stats ~/proyectos/mi-app

# Filtrar por rango de fechas (últimos N días)
conventional-stats ~/proyectos/mi-app 90

# Salida JSON (pipeable a jq, scripts, etc.)
conventional-stats --json ~/proyectos/mi-app
conventional-stats --json ~/proyectos/mi-app 90
```

La flag `--json` puede ir en cualquier posición; el resto de argumentos son posicionales: `[ruta-repo] [días]`. Ejecuta `conventional-stats -h` (o `--help`) para ver la ayuda.

---

## Subcomando `audit` — hotspots / code smells

Lista los archivos **conflictivos**: los que reciben muchos cambios y grandes. Inspirado en el método de hotspots de Adam Tornhill (*Your Code as a Crime Scene*), con dos dimensiones visuales:

- **Barra = magnitud**: `commits × líneas modificadas (+/-)`. Un archivo que cambia a menudo *y* de forma pesada tiene la barra más larga (posible god object / imán de cambios).
- **Color = inestabilidad**: el ratio de commits `fix`/`hotfix` sobre el archivo. Gris = estable; **amarillo** = se rompe a menudo (ratio ≥ 15 %); **rojo** = vive roto (ratio ≥ 40 %). Solo se colorea a partir de **2 fixes** (un único `fix` no dispara la alarma).

Lectura rápida: **barra larga + roja** = el peor cuadrante (dividir/refactorizar); **larga + gris** = grande pero estable.

Audita el **repositorio actual** por defecto; no hace falta pasar la ruta.

```bash
# Repo actual, todo el historial
conventional-stats audit

# Solo los últimos N días
conventional-stats audit --days 90

# Auditar otro repo sin entrar en él
conventional-stats audit --repo ~/proyectos/mi-app --days 90

# Excluir archivos de forma puntual (globs y directorios)
conventional-stats audit --ignore '*.gradle' '/build/*'

# Guardar exclusiones en el proyecto (.auditignore) y salir
conventional-stats audit --set-ignore '*.gradle' '/build/*'

# JSON completo, pipeable a jq
conventional-stats audit --json
conventional-stats audit --json | jq '.hotspots[] | select(.fixes >= 3)'
```

### Exclusiones

Se aplican, en este orden y de forma acumulativa:

1. **Defaults internos**: `*.lock`, `package-lock.json`, `pnpm-lock.yaml`, `yarn.lock`, `go.sum`, `dist/`, `build/`, `node_modules/`, `vendor/` — high-churn por diseño, no son code smells.
2. **`.auditignore`** del repo (un patrón por línea, `#` para comentarios). Se crea/actualiza con `--set-ignore`.
3. **`--ignore`** puntual para esa ejecución.

Patrones soportados: glob sobre el nombre (`*.gradle`), glob sobre ruta completa (`src/**/*.kt`) y directorio (`build/`, que coincide a cualquier profundidad). Un `/` inicial es tolerado (`/build/*`).

### Salida JSON

A diferencia del render de terminal (top 20, con color), el JSON es **completo y sin color**, con el desglose de commits por tipo:

```json
{
  "repo": "mi-app",
  "period": "últimos 90 días",
  "hotspots": [
    {
      "file": "src/app.kt",
      "commits": 18,
      "churn": 1240,
      "fixes": 7,
      "score": 22320,
      "types": { "feat": 6, "fix": 7, "refactor": 5 }
    }
  ]
}
```

`score = commits × churn` es la clave de orden (descendente).

### Notas de implementación

- **Rendimiento**: la agregación se hace en una sola pasada de `awk` sobre `git log --numstat` (rápido en repos con miles de commits). El filtrado por glob y el render quedan en zsh.
- **Renames**: se usa `git log --no-renames`, así un fichero renombrado aparece por su nombre actual sin paths fantasma `a => b`. Limitación: la historia anterior al rename no se fusiona con el nombre nuevo.
- **Merges**: `--numstat` no muestra el diff de los commits de merge, así que no se doble-cuentan.
- **Color**: solo se emite en una terminal real y si `NO_COLOR` no está definida (los pipes y `--json` salen limpios).

---

## Salida JSON

```json
{
  "repo": "mi-app",
  "period": "últimos 90 días",
  "commits": [
    { "type": "feat", "count": 12 },
    { "type": "fix", "count": 8 }
  ],
  "total": 20
}
```

Solo se incluyen los tipos con al menos un commit. `period` refleja el filtro de días (o "todo el historial" si no se pasa).

---

## Cómo funciona

### Pipeline de datos

```
conventional-stats ~/mi-app 90
  └─ git log --format="%s" --since="90 days ago"   (un único subproceso)
       └─ regex match por subject de commit          (en memoria, sin forks extra)
            └─ gráfico de barras proporcional → stdout
```

Un único `git log` lee todos los subjects; los conteos por tipo se construyen en un array asociativo en memoria. El ancho de las barras escala para que el tipo con más commits siempre ocupe la columna completa de 24 caracteres.

Tipos reconocidos: `feat fix hotfix refactor red green docs style test chore perf ci build revert`. El regex acepta scopes y breaking changes: `feat:`, `feat(auth):`, `feat!:` y `feat(auth)!:`.

### Decisiones de diseño clave

| Decisión | Motivo |
|----------|--------|
| Un único `git log` para todos los tipos | Evita un subproceso por tipo (14 forks vs. 1). |
| `--since` almacenado como array | Previene word-splitting en `"30 days ago"` durante la expansión. |
| `#!/usr/bin/env zsh` | macOS incluye bash 3.2 (sin arrays asociativos); zsh viene integrado en Apple Silicon. |
| `--json` separada de los args posicionales | Se filtra en un loop, así puede aparecer en cualquier posición. |

---

## Revertir commits

Usa `git revert <hash>` directamente — git genera el mensaje convencional correcto de forma automática (`Revert "feat: ..."`), y `conventional-stats` lo cuenta en la categoría `revert`. Por eso no hay un atajo `revert` entre las funciones de shell.
