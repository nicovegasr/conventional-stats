# shellcheck shell=bash
_print_commit_help() {
  echo "Uso: <tipo> \"mensaje\"  →  git add . && git commit -m \"<tipo>: mensaje.\""
  echo "El punto final se añade automáticamente si falta."
  echo ""
  echo "── Flujo TDD ─────────────────────────────────────────"
  echo "  red      \"msg\"   Trabajo en progreso / test roto"
  echo "  green    \"msg\"   Tests pasan / estado funcional"
  echo "  refactor \"msg\"   Refactorización sin cambio de comportamiento"
  echo ""
  echo "── Conventional Commits ──────────────────────────────"
  echo "  feat     \"msg\"   Nueva funcionalidad"
  echo "  fix      \"msg\"   Corrección de bug"
  echo "  hotfix   \"msg\"   Corrección urgente en producción"
  echo "  docs     \"msg\"   Documentación"
  echo "  style    \"msg\"   Formato, sin cambio de lógica"
  echo "  tests    \"msg\"   Tests añadidos o corregidos  (prefijo: test:)"
  echo "  chore    \"msg\"   Mantenimiento, dependencias, tooling"
  echo "  perf     \"msg\"   Mejora de rendimiento"
  echo "  ci       \"msg\"   Configuración de CI/CD"
  echo "  build    \"msg\"   Sistema de build"
}

_execute_commit() {
  local commit_type="$1" commit_message="$2"
  [[ "$commit_message" != *. ]] && commit_message="${commit_message}."
  git add . && git commit -m "${commit_type}: ${commit_message}"
}

_dispatch_commit() {
  local commit_type="$1" message_input="${2:-}"
  if [[ -z "$message_input" || "$message_input" == "-h" || "$message_input" == "--help" ]]; then
    _print_commit_help; return 0
  fi
  if [[ "$message_input" == -* ]]; then
    echo "Error: opción desconocida '$message_input' para $commit_type. Ejecuta '$commit_type -h' o '$commit_type' para ver la ayuda." >&2
    return 1
  fi
  if [[ $# -gt 2 ]]; then
    echo "Error: el mensaje debe ir entre comillas: $commit_type \"tu mensaje\"" >&2
    return 1
  fi
  _execute_commit "$commit_type" "$message_input"
}

red()      { _dispatch_commit "red"      "$@"; }
green()    { _dispatch_commit "green"    "$@"; }
refactor() { _dispatch_commit "refactor" "$@"; }
feat()     { _dispatch_commit "feat"     "$@"; }
fix()      { _dispatch_commit "fix"      "$@"; }
hotfix()   { _dispatch_commit "hotfix"   "$@"; }
docs()     { _dispatch_commit "docs"     "$@"; }
style()    { _dispatch_commit "style"    "$@"; }
tests()    { _dispatch_commit "test"     "$@"; }  # 'tests' not 'test' to avoid shadowing zsh builtin
chore()    { _dispatch_commit "chore"    "$@"; }
perf()     { _dispatch_commit "perf"     "$@"; }
ci()       { _dispatch_commit "ci"       "$@"; }
build()    { _dispatch_commit "build"    "$@"; }
