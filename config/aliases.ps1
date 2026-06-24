# conventional-stats — aliases (PowerShell)

Set-Alias c Clear-Host

function l {
    param(
        [string]$Level = "1",
        [Parameter(ValueFromRemainingArguments=$true)]
        [string[]]$Rest
    )
    if ($Level -eq "--help") {
        Write-Host "Usage: l [level] [tree-options] [path]"
        Write-Host ""
        Write-Host "  level    Depth of the tree (default: 1)"
        Write-Host ""
        Write-Host "Useful tree options:"
        Write-Host "  -h       Human-readable file sizes"
        Write-Host "  -a       Include hidden files (dotfiles)"
        Write-Host "  -d       Directories only"
        Write-Host ""
        Write-Host "Examples:"
        Write-Host "  l              Level-1 tree of current dir"
        Write-Host "  l 2            Level-2 tree"
        Write-Host "  l 2 -a         Level 2 including hidden"
        return
    }
    tree /F /A | Select-Object -First 100
    Write-Host "(tip: install 'tree' via scoop for full tree support)"
}
