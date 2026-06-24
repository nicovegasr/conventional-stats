#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZSHRC="$HOME/.zshrc"
MARKER_START="# >>> conventional-stats >>>"
MARKER_END="# <<< conventional-stats <<<"

GREEN='\033[0;32m' YELLOW='\033[1;33m' RED='\033[0;31m' NC='\033[0m'
ok()   { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}!${NC} $1"; }
fail() { echo -e "${RED}✗${NC} $1"; exit 1; }

echo ""
echo "🚀 conventional-stats — instalación"
echo "────────────────────────────────────"

# ── OS detection ──────────────────────────────────────────────────────────────
OS="$(uname -s)"
case "$OS" in
  Darwin|Linux) ;;
  *) fail "Sistema no soportado: $OS. Usa windows/install.ps1 en Windows." ;;
esac

# ── conventional-stats CLI ────────────────────────────────────────────────────
BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"
cp "$SCRIPT_DIR/bin/conventional-stats" "$BIN_DIR/conventional-stats"
chmod +x "$BIN_DIR/conventional-stats"
ok "conventional-stats → $BIN_DIR/conventional-stats"

# ── Config files ──────────────────────────────────────────────────────────────
CONFIG_DIR="$HOME/.config/conventional-stats"
mkdir -p "$CONFIG_DIR"
cp "$SCRIPT_DIR/config/git-commits.zsh" "$CONFIG_DIR/git-commits.zsh"
ok "config → $CONFIG_DIR"

# ── .zshrc ────────────────────────────────────────────────────────────────────
touch "$ZSHRC"

if grep -q "$MARKER_START" "$ZSHRC"; then
  warn ".zshrc ya configurado. Ejecuta uninstall.sh primero si quieres reinstalar."
else
  cat >> "$ZSHRC" <<EOF

${MARKER_START}
source "\$HOME/.config/conventional-stats/git-commits.zsh"
export PATH="\$HOME/.local/bin:\$PATH"
${MARKER_END}
EOF
  ok ".zshrc actualizado"
fi

echo ""
echo "✅ Instalación completada."
echo "   Ejecuta: source ~/.zshrc"
echo ""
