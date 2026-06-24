source "$(brew --prefix 2>/dev/null)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" 2>/dev/null
source "$(brew --prefix 2>/dev/null)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" 2>/dev/null

alias c='clear'

l() {
  if [[ "$1" == "--help" ]]; then
    echo "Usage: l [level] [tree-options] [path]"
    echo ""
    echo "  level    Profundidad del árbol (default: 1)"
    echo ""
    echo "Opciones útiles de tree:"
    echo "  -h       Tamaños de archivo legibles (KB, MB…)"
    echo "  -s       Tamaños de archivo en bytes"
    echo "  -D       Fecha de última modificación"
    echo "  -a       Incluir archivos ocultos (dotfiles)"
    echo "  -d       Solo directorios"
    echo "  -f       Rutas completas"
    echo "  --no-gitignore  Deshabilitar filtro .gitignore"
    echo ""
    echo "Ejemplos:"
    echo "  l              Árbol nivel 1 del dir actual"
    echo "  l 2            Árbol nivel 2"
    echo "  l 2 -h         Nivel 2 con tamaños legibles"
    echo "  l 3 -a         Nivel 3 incluyendo ocultos"
    echo "  l 2 ~/Desktop  Árbol de ~/Desktop nivel 2"
    return 0
  fi
  local level=${1:-1}
  shift 2>/dev/null
  tree -C -L "$level" --dirsfirst --gitignore -I '.git|node_modules|__pycache__|.DS_Store' "$@"
}
