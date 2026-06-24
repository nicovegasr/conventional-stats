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
