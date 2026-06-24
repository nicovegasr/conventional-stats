#!/usr/bin/env bash
set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/nicovegasr/conventional-stats/main"
ZSHRC="$HOME/.zshrc"
MARKER_START="# >>> conventional-stats >>>"
MARKER_END="# <<< conventional-stats <<<"

GREEN='\033[0;32m' YELLOW='\033[1;33m' RED='\033[0;31m' NC='\033[0m'
ok()   { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}!${NC} $1"; }
fail() { echo -e "${RED}✗${NC} $1"; exit 1; }

# Resolve the dir of this script when run from a clone; empty when piped from curl
SOURCE_PATH="${BASH_SOURCE[0]:-}"
if [[ -n "$SOURCE_PATH" && -f "$SOURCE_PATH" ]]; then
  INSTALLER_DIR="$(cd "$(dirname "$SOURCE_PATH")" && pwd)"
else
  INSTALLER_DIR=""
fi

# Copy from the local clone if present, otherwise download from the repo
fetch_file() {
  local rel_path="$1" dest="$2"
  if [[ -n "$INSTALLER_DIR" && -f "$INSTALLER_DIR/$rel_path" ]]; then
    cp "$INSTALLER_DIR/$rel_path" "$dest"
  else
    curl -fsSL "$REPO_RAW/$rel_path" -o "$dest" || fail "No se pudo descargar $rel_path"
  fi
}

echo ""
echo "🚀 conventional-stats — instalación"
echo "────────────────────────────────────"

# ── OS detection ──────────────────────────────────────────────────────────────
OS="$(uname -s)"
case "$OS" in
  Darwin|Linux) ;;
  *) fail "Sistema no soportado: $OS. Usa windows/install.ps1 en Windows." ;;
esac

# curl is only required when not installing from a local clone
if [[ -z "$INSTALLER_DIR" || ! -f "$INSTALLER_DIR/bin/conventional-stats" ]]; then
  command -v curl >/dev/null 2>&1 || fail "Se necesita curl para la instalación de un comando."
fi

# ── conventional-stats CLI ────────────────────────────────────────────────────
USER_BIN_DIR="$HOME/.local/bin"
mkdir -p "$USER_BIN_DIR"
fetch_file "bin/conventional-stats" "$USER_BIN_DIR/conventional-stats"
chmod +x "$USER_BIN_DIR/conventional-stats"
ok "conventional-stats → $USER_BIN_DIR/conventional-stats"

# ── Config files ──────────────────────────────────────────────────────────────
# Copied to ~/.config so moving or deleting the cloned repo doesn't break the shell
USER_CONFIG_DIR="$HOME/.config/conventional-stats"
mkdir -p "$USER_CONFIG_DIR"
fetch_file "config/git-commits.zsh" "$USER_CONFIG_DIR/git-commits.zsh"
ok "config → $USER_CONFIG_DIR"

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
