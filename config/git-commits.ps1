# conventional-stats — commit shortcuts (PowerShell)

function _print_commit_help {
    Write-Host "Usage: <type> `"message`"  ->  git add . && git commit -m `"<type>: message.`""
    Write-Host "Trailing period is added automatically if missing."
    Write-Host ""
    Write-Host "-- TDD flow ------------------------------------------"
    Write-Host "  red      `"msg`"   Work in progress / broken test"
    Write-Host "  green    `"msg`"   Tests pass / working state"
    Write-Host "  refactor `"msg`"   Refactor without behaviour change"
    Write-Host ""
    Write-Host "-- Conventional Commits ------------------------------"
    Write-Host "  feat     `"msg`"   New feature"
    Write-Host "  fix      `"msg`"   Bug fix"
    Write-Host "  hotfix   `"msg`"   Urgent production fix"
    Write-Host "  docs     `"msg`"   Documentation"
    Write-Host "  style    `"msg`"   Formatting, no logic change"
    Write-Host "  tests    `"msg`"   Tests added or fixed  (prefix: test:)"
    Write-Host "  chore    `"msg`"   Maintenance, deps, tooling"
    Write-Host "  perf     `"msg`"   Performance improvement"
    Write-Host "  ci       `"msg`"   CI/CD configuration"
    Write-Host "  build    `"msg`"   Build system"
}

function _execute_commit {
    param([string]$CommitType, [string]$CommitMessage)
    if (-not $CommitMessage.EndsWith('.')) { $CommitMessage = "$CommitMessage." }
    git add .
    git commit -m "${CommitType}: ${CommitMessage}"
}

function _dispatch_commit {
    param([string]$CommitType, [string]$CommitMessage)
    if ([string]::IsNullOrWhiteSpace($CommitMessage) -or $CommitMessage -eq '-h' -or $CommitMessage -eq '--help') {
        _print_commit_help; return
    }
    if ($CommitMessage.StartsWith('-')) {
        Write-Error "Opción desconocida '$CommitMessage' para $CommitType. Ejecuta '$CommitType -h' o '$CommitType' para ver la ayuda."
        return
    }
    if ($args.Count -gt 0) {
        Write-Error "El mensaje debe ir entre comillas: $CommitType `"tu mensaje`""
        return
    }
    _execute_commit $CommitType $CommitMessage
}

function red      { _dispatch_commit "red"      @args }
function green    { _dispatch_commit "green"    @args }
function refactor { _dispatch_commit "refactor" @args }
function feat     { _dispatch_commit "feat"     @args }
function fix      { _dispatch_commit "fix"      @args }
function hotfix   { _dispatch_commit "hotfix"   @args }
function docs     { _dispatch_commit "docs"     @args }
function style    { _dispatch_commit "style"    @args }
function tests    { _dispatch_commit "test"     @args }  # 'tests' not 'test': avoids conflict with Test-* cmdlets
function chore    { _dispatch_commit "chore"    @args }
function perf     { _dispatch_commit "perf"     @args }
function ci       { _dispatch_commit "ci"       @args }
function build    { _dispatch_commit "build"    @args }
