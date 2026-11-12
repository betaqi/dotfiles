# Resolve the checkout from this file so the commands work from any directory.
function dot { Set-Location -LiteralPath (Split-Path -Parent $PSScriptRoot) }
function dots { git -C "$PSScriptRoot/.." status --short }

function dotpull {
    git -C "$PSScriptRoot/.." pull --ff-only
    if ($LASTEXITCODE -ne 0) { throw "Could not fast-forward the dotfiles checkout." }
}

function sync-dotfiles {
    param([string]$Message = "update dotfiles")

    $repo = Split-Path -Parent $PSScriptRoot
    git -C $repo add -A
    if ($LASTEXITCODE -ne 0) { throw "Could not stage dotfiles." }
    $staged = git -C $repo diff --cached --name-only
    if ($LASTEXITCODE -ne 0) { throw "Could not read staged changes." }
    if ($staged) {
        git -C $repo commit -m $Message
        if ($LASTEXITCODE -ne 0) { throw "Could not commit dotfiles." }
    }
    git -C $repo push
    if ($LASTEXITCODE -ne 0) { throw "Push failed. Retry sync-dotfiles after resolving the error." }
}

function pull-skills {
    param([switch]$IncludeLockfile)

    $ErrorActionPreference = "Stop"
    $repo = Split-Path -Parent $PSScriptRoot
    $beforePull = git -C $repo rev-parse HEAD
    if ($LASTEXITCODE -ne 0) { throw "Could not read the current dotfiles commit." }
    dotpull
    # Show upstream removals for manual cleanup; Windows-only files stay in place.
    git -C $repo diff --no-renames --diff-filter=D --name-status $beforePull HEAD -- skills/cc-switch skills/agents
    if ($LASTEXITCODE -ne 0) { throw "Could not compare skill snapshots." }

    $backup = Join-Path $repo "skills"
    foreach ($group in "cc-switch", "agents") {
        $source = Join-Path $backup $group
        $destination = Join-Path $HOME ".$group/skills"
        $items = Get-ChildItem -LiteralPath $source -Force
        New-Item -ItemType Directory -Path $destination -Force | Out-Null
        foreach ($item in $items) {
            Copy-Item -LiteralPath $item.FullName -Destination $destination -Recurse -Force
        }
    }

    $lock = Join-Path $HOME ".agents/.skill-lock.json"
    if ($IncludeLockfile -or -not (Test-Path -LiteralPath $lock)) {
        Copy-Item -LiteralPath (Join-Path $backup "agents-lock.json") -Destination $lock -Force
    }
}
