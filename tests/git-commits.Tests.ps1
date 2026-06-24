# Pester tests for config/git-commits.ps1 (the feat/fix/tests/... shortcuts)
# Run inside the official PowerShell container; see docs/testing.md.

BeforeAll {
    . "$PSScriptRoot/../config/git-commits.ps1"

    function Last-Subject { (git log -1 --format=%s) }
    function Commit-Count { [int](git rev-list --count HEAD) }
    function Make-Change  { "change" | Add-Content -Path file.txt }
}

Describe "commit shortcuts" {
    BeforeEach {
        $script:repo = Join-Path ([System.IO.Path]::GetTempPath()) ([System.Guid]::NewGuid().ToString())
        New-Item -ItemType Directory -Path $script:repo | Out-Null
        Push-Location $script:repo
        git init -q
        git config user.email "test@test.com"
        git config user.name "Test"
        "base" | Out-File -FilePath file.txt
        git add .
        git commit -q -m "chore: init"
    }

    AfterEach {
        Pop-Location
        Remove-Item -Recurse -Force $script:repo
    }

    # ── Happy path ────────────────────────────────────────────────────────────
    It "feat creates a feat: commit with trailing period" {
        Make-Change
        feat "add login"
        Last-Subject | Should -Be "feat: add login."
    }

    It "does not duplicate a trailing period" {
        Make-Change
        fix "null check."
        Last-Subject | Should -Be "fix: null check."
    }

    It "tests maps to a test: prefix (not tests:)" {
        Make-Change
        tests "cover edge cases"
        Last-Subject | Should -Be "test: cover edge cases."
    }

    It "red maps to a red: prefix" {
        Make-Change
        red "failing auth test"
        Last-Subject | Should -Be "red: failing auth test."
    }

    # ── Help paths create no commit ───────────────────────────────────────────
    It "no message prints help and creates no commit" {
        feat
        Commit-Count | Should -Be 1
    }

    It "--help creates no commit" {
        feat --help
        Commit-Count | Should -Be 1
    }

    It "-h is an alias for --help and creates no commit" {
        Make-Change
        feat -h
        Commit-Count | Should -Be 1
    }

    # ── Unknown options ───────────────────────────────────────────────────────
    It "rejects an unknown short option (-x) with a help hint and no commit" {
        Make-Change
        $ErrorActionPreference = 'Continue'
        $err = feat -x 2>&1 | Out-String
        $err | Should -Match "desconocida '-x'"
        $err | Should -Match "feat -h"
        Commit-Count | Should -Be 1
    }

    It "rejects an unknown clustered option (-hacd) with no commit" {
        Make-Change
        $ErrorActionPreference = 'Continue'
        $err = feat -hacd 2>&1 | Out-String
        $err | Should -Match "desconocida '-hacd'"
        Commit-Count | Should -Be 1
    }

    It "rejects an unknown long option (--bogus) with no commit" {
        Make-Change
        $ErrorActionPreference = 'Continue'
        $err = feat --bogus 2>&1 | Out-String
        $err | Should -Match "desconocida '--bogus'"
        Commit-Count | Should -Be 1
    }

    # ── Quoting enforcement ───────────────────────────────────────────────────
    It "rejects a multi-word message without quotes" {
        Make-Change
        feat add login flow 2>&1 | Out-Null
        Commit-Count | Should -Be 1
    }

    It "commits a single bare word (indistinguishable from quoted)" {
        Make-Change
        feat hola
        Last-Subject | Should -Be "feat: hola."
    }
}
