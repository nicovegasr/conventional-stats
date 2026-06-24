# conventional-stats — Windows installer (PowerShell)
# Requiere: winget, PowerShell 5+

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Root = Split-Path -Parent $ScriptDir
$ProfilePath = $PROFILE.CurrentUserAllHosts
$MarkerStart = "# >>> conventional-stats >>>"
$MarkerEnd   = "# <<< conventional-stats <<<"

function ok($msg)   { Write-Host "✓ $msg" -ForegroundColor Green }
function warn($msg) { Write-Host "! $msg" -ForegroundColor Yellow }

Write-Host ""
Write-Host "🚀 conventional-stats — instalación (Windows)" -ForegroundColor Cyan
Write-Host "───────────────────────────────────────────────"

# ── Scoop (gestor de paquetes) ────────────────────────────────────────────────
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
  warn "Scoop no encontrado. Instalando..."
  Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
  Invoke-RestMethod get.scoop.sh | Invoke-Expression
}
ok "Scoop"

# ── Dependencias ──────────────────────────────────────────────────────────────
$packages = @("bat", "tree")
foreach ($pkg in $packages) {
  $installed = scoop list 2>$null | Select-String $pkg
  if ($installed) {
    ok "$pkg (ya instalado)"
  } else {
    scoop install $pkg
    ok $pkg
  }
}

# ── Aliases en perfil de PowerShell ──────────────────────────────────────────
if (-not (Test-Path $ProfilePath)) { New-Item -Path $ProfilePath -Force | Out-Null }
$content = Get-Content $ProfilePath -Raw -ErrorAction SilentlyContinue

if ($content -match [regex]::Escape($MarkerStart)) {
  warn "Perfil ya configurado."
} else {
  $block = @"

$MarkerStart
. "$Root\config\aliases.ps1"
. "$Root\config\git-commits.ps1"
$MarkerEnd
"@
  Add-Content -Path $ProfilePath -Value $block
  ok "Perfil de PowerShell actualizado"
}

Write-Host ""
Write-Host "✅ Instalación completada. Reinicia PowerShell." -ForegroundColor Green
Write-Host ""
Write-Host "ℹ  conventional-stats CLI: el binario es un script zsh y no puede" -ForegroundColor Yellow
Write-Host "   ejecutarse nativamente en Windows. Usa WSL2 con zsh para acceder" -ForegroundColor Yellow
Write-Host "   a 'conventional-stats' desde la línea de comandos." -ForegroundColor Yellow
Write-Host ""
