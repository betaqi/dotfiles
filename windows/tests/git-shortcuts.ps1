# Run in a fresh PowerShell session: pwsh -NoProfile -File windows/tests/git-shortcuts.ps1
$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "../aliases.ps1")

foreach ($name in "gc", "gcm", "gp") {
    if ((Get-Command $name).CommandType -ne "Function") {
        throw "$name is still hidden by a PowerShell alias."
    }
}

$script:gitCalls = @()
$script:failAdd = $false
function git {
    $script:gitCalls += $args[0]
    $global:LASTEXITCODE = [int]($script:failAdd -and $args[0] -eq "add")
}

gc
gcm "test"
gp
gcam "test"
if (($gitCalls -join " ") -ne "commit commit push add commit") { throw "Wrong Git subcommands." }

$script:gitCalls = @()
$script:failAdd = $true
try { gcam "test" } catch { if ($LASTEXITCODE -ne 1) { throw } }
if (($gitCalls -join " ") -ne "add") { throw "gcam must stop after a failed add." }
