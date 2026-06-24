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
  echo "  tests    \"msg\"   Tests añadidos o corregidos"
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
  local type="$1" arg="$2"
  if [[ "$arg" == "--help" || -z "$arg" ]]; then
    _commit_help; return 0
  fi
  _do_commit "$type" "$arg"
}

red()      { _commit_fn "red"      "$1"; }
green()    { _commit_fn "green"    "$1"; }
refactor() { _commit_fn "refactor" "$1"; }
feat()     { _commit_fn "feat"     "$1"; }
fix()      { _commit_fn "fix"      "$1"; }
hotfix()   { _commit_fn "hotfix"   "$1"; }
docs()     { _commit_fn "docs"     "$1"; }
style()    { _commit_fn "style"    "$1"; }
tests()    { _commit_fn "test"     "$1"; }
chore()    { _commit_fn "chore"    "$1"; }
perf()     { _commit_fn "perf"     "$1"; }
ci()       { _commit_fn "ci"       "$1"; }
build()    { _commit_fn "build"    "$1"; }
revert()   { _commit_fn "revert"   "$1"; }
