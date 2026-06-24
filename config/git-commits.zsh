_commit_help() {
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
  echo "  revert   \"msg\"   Revertir un commit anterior"
}

_do_commit() {
  local type="$1" msg="$2"
  [[ "$msg" != *. ]] && msg="${msg}."
  git add . && git commit -m "${type}: ${msg}"
}

_commit_fn() {
  local type="$1"
  shift
  local arg="${*:-}"
  if [[ "$arg" == "--help" || -z "$arg" ]]; then
    _commit_help; return 0
  fi
  _do_commit "$type" "$arg"
}

red()      { _commit_fn "red"      "$@"; }
green()    { _commit_fn "green"    "$@"; }
refactor() { _commit_fn "refactor" "$@"; }
feat()     { _commit_fn "feat"     "$@"; }
fix()      { _commit_fn "fix"      "$@"; }
hotfix()   { _commit_fn "hotfix"   "$@"; }
docs()     { _commit_fn "docs"     "$@"; }
style()    { _commit_fn "style"    "$@"; }
tests()    { _commit_fn "test"     "$@"; }
chore()    { _commit_fn "chore"    "$@"; }
perf()     { _commit_fn "perf"     "$@"; }
ci()       { _commit_fn "ci"       "$@"; }
build()    { _commit_fn "build"    "$@"; }
revert()   { _commit_fn "revert"   "$@"; }
