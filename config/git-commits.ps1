# conventional-stats — commit shortcuts (PowerShell)

function _commit_help {
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
    Write-Host "  revert   `"msg`"   Revert a previous commit"
}

function _do_commit {
    param([string]$Type, [string]$Msg)
    if (-not $Msg.EndsWith('.')) { $Msg = "$Msg." }
    git add .
    git commit -m "${Type}: ${Msg}"
}

function _commit_fn {
    param([string]$Type, [Parameter(ValueFromRemainingArguments=$true)][string[]]$Args)
    $msg = $Args -join ' '
    if ($msg -eq '--help' -or [string]::IsNullOrWhiteSpace($msg)) {
        _commit_help; return
    }
    _do_commit $Type $msg
}

function red      { _commit_fn "red"      @args }
function green    { _commit_fn "green"    @args }
function refactor { _commit_fn "refactor" @args }
function feat     { _commit_fn "feat"     @args }
function fix      { _commit_fn "fix"      @args }
function hotfix   { _commit_fn "hotfix"   @args }
function docs     { _commit_fn "docs"     @args }
function style    { _commit_fn "style"    @args }
function tests    { _commit_fn "test"     @args }
function chore    { _commit_fn "chore"    @args }
function perf     { _commit_fn "perf"     @args }
function ci       { _commit_fn "ci"       @args }
function build    { _commit_fn "build"    @args }
function revert   { _commit_fn "revert"   @args }
