# Atajos de commit

[← Volver al README](../README.md)

Funciones de shell que convierten un tipo + mensaje en un commit convencional completo. Cada función sigue el mismo patrón:

```
<tipo> "mensaje"  →  git add . && git commit -m "<tipo>: mensaje."
```

El punto final se añade automáticamente si falta.

---

## Regla de uso: el mensaje va siempre entre comillas

```bash
feat "añadir flujo de login"     # ✓ correcto
feat añadir flujo de login       # ✗ error: el mensaje debe ir entre comillas
```

Un mensaje de varias palabras sin comillas se rechaza con un error en lugar de crear un commit truncado.

> **Detalle técnico:** `feat hola` y `feat "hola"` son indistinguibles para la función — la shell quita las comillas antes de que la función vea los argumentos, así que solo se puede detectar el número de palabras, no si una palabra suelta venía entrecomillada. Por eso la convención (siempre comillas) se sostiene con el guard de varias-palabras más esta documentación.

---

## Flujo TDD

| Comando | Mensaje de commit |
|---------|------------------|
| `red "test de auth fallando"` | `red: test de auth fallando.` |
| `green "test de auth pasa"` | `green: test de auth pasa.` |
| `refactor "extraer helper de auth"` | `refactor: extraer helper de auth.` |

## Conventional Commits

| Comando | Tipo | Cuándo usarlo |
|---------|------|---------------|
| `feat "añadir OAuth login"` | `feat` | Nueva funcionalidad |
| `fix "null check en logout"` | `fix` | Corrección de bug |
| `hotfix "parchear XSS en input"` | `hotfix` | Corrección urgente en producción |
| `docs "actualizar referencia API"` | `docs` | Documentación |
| `style "formatear controladores"` | `style` | Formato, sin cambio de lógica |
| `tests "cubrir casos borde"` | `test` | Tests añadidos o corregidos |
| `chore "actualizar dependencias"` | `chore` | Mantenimiento, tooling |
| `perf "cachear consultas BD"` | `perf` | Mejora de rendimiento |
| `ci "añadir paso de lint"` | `ci` | Configuración de CI/CD |
| `build "migrar a esbuild"` | `build` | Sistema de build |

El comando se llama `tests` (no `test`) para no hacer shadowing del builtin `test` de zsh, pero el prefijo del commit es `test:`.

---

## Ayuda y opciones desconocidas

```bash
feat            # sin mensaje → muestra la ayuda
feat -h         # → muestra la ayuda
feat --help     # → muestra la ayuda
feat -x         # → error: opción desconocida '-x' para feat
feat -hacd      # → error: opción desconocida '-hacd' para feat
```

Cualquier token que empiece por `-` y no sea `-h`/`--help` se rechaza como opción desconocida (con un mensaje que apunta a `feat -h`), en lugar de acabar dentro del mensaje del commit (`feat: -x.`).

---

## Cómo funciona

```
feat "añadir login"
  └─ _dispatch_commit "feat" "añadir login"
       └─ _execute_commit "feat" "añadir login."
            └─ git add . && git commit -m "feat: añadir login."
```

Tres capas:

- **Comandos públicos** (`feat`, `fix`, …) fijan el tipo de commit y delegan.
- **`_dispatch_commit`** gestiona la ayuda (sin mensaje / `-h` / `--help`), rechaza opciones desconocidas y mensajes multi-palabra sin comillas.
- **`_execute_commit`** añade el punto final si falta y ejecuta `git add . && git commit`.

La misma estructura está replicada en `config/git-commits.ps1` para PowerShell (ver la nota de Windows en [testing.md](testing.md)).
