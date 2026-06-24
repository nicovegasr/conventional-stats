#!/usr/bin/env pwsh
# Instala Pester 5 y corre los tests de los atajos de PowerShell.
# Lo usan tanto el job de CI como run-ps-tests.sh.

Set-PSRepository PSGallery -InstallationPolicy Trusted
Install-Module Pester -Force -SkipPublisherCheck -MinimumVersion 5.0.0
Import-Module Pester -MinimumVersion 5.0.0 -Force

$result = Invoke-Pester -Path "$PSScriptRoot/git-commits.Tests.ps1" -Output Detailed -PassThru
exit $result.FailedCount
