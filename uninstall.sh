#!/usr/bin/env bash
set -euo pipefail

ZSHRC="$HOME/.zshrc"
MARKER_START="# >>> conventional-stats >>>"
MARKER_END="# <<< conventional-stats <<<"

GREEN='\033[0;32m' YELLOW='\033[1;33m' NC='\033[0m'
ok()   { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}!${NC} $1"; }

echo ""
echo "🗑  conventional-stats — desinstalación"
echo "────────────────────────────────────────"

# ── Eliminar bloque del .zshrc ────────────────────────────────────────────────
if grep -q "$MARKER_START" "$ZSHRC"; then
  sed -i.bak "/${MARKER_START}/,/${MARKER_END}/d" "$ZSHRC"
  ok ".zshrc restaurado (backup en .zshrc.bak)"
else
  warn "No se encontró el bloque en .zshrc"
fi

# ── Eliminar CLI ──────────────────────────────────────────────────────────────
BIN="$HOME/.local/bin/conventional-stats"
if [[ -f "$BIN" ]]; then
  rm "$BIN"
  ok "conventional-stats eliminado de $HOME/.local/bin"
else
  warn "conventional-stats no encontrado en $HOME/.local/bin"
fi

echo ""
echo "✅ Desinstalación completada."
echo "   Ejecuta: source ~/.zshrc"
echo ""
