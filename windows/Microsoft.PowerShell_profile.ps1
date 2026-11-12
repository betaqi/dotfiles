# Windows PowerShell profile entrypoint managed by this dotfiles repo.

$profileRoot = Split-Path -Parent $PSCommandPath
$profileItem = Get-Item -LiteralPath $PSCommandPath -ErrorAction SilentlyContinue

if ($profileItem -and $profileItem.LinkType -eq "SymbolicLink" -and $profileItem.Target) {
    $profileRoot = Split-Path -Parent $profileItem.Target
}

$global:DotfilesPowerShellProfile = Join-Path $profileRoot "Microsoft.PowerShell_profile.ps1"

$profileParts = @(
    "starship.ps1",
    "aliases.ps1",
    "dotfiles.ps1",
    "proxy.ps1",
    "npm.ps1",
    "tools.ps1"
)

foreach ($part in $profileParts) {
    $path = Join-Path $profileRoot $part
    if (Test-Path $path) {
        . $path
    }
}
