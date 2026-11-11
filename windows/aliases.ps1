# Prefer dotfiles functions over built-in compatibility aliases when names collide.
Remove-Item Alias:rm -ErrorAction SilentlyContinue
Remove-Item Alias:cp -ErrorAction SilentlyContinue
Remove-Item Alias:mv -ErrorAction SilentlyContinue
Remove-Item Alias:dir -ErrorAction SilentlyContinue

# Script shortcuts
function d { nr dev @args }
function b { nr build @args }
function t { nr test @args }
function tw { nr test --watch @args }
function lint { nr lint @args }
function lf { nr lint --fix @args }
function fmt { nr format @args }

# Package managers
function nid { ni -D @args }
function nx { nlx @args }

# Python / uv
function py { python @args }
function uvs { uv sync @args }

# Git
function gs { git status @args }
function ga { git add @args }
function gaa { git add -A @args }
function gc { git commit @args }
function gcm { git commit -m @args }
function gcam {
    git add -A
    git commit -m @args
}
function gp { git push @args }
function gpf { git push --force @args }
function gpl { git pull --rebase @args }
function gco { git checkout @args }
function gcob { git checkout -b @args }
function gb { git branch @args }
function gbd { git branch -d @args }
function glo { git log --oneline --graph @args }
function grh1 { git reset HEAD~1 @args }
function gst { git stash @args }
function gx { git clean -df @args }
function gxn { git clean -dn @args }
function main { git checkout main @args }

# Navigation
function .. { Set-Location .. }
function ... { Set-Location ../.. }
function - { Set-Location - }
function dir {
    param([Parameter(Mandatory = $true)][string]$Path)
    New-Item -ItemType Directory -Force -Path $Path | Out-Null
    Set-Location $Path
}

# Listing
function ll { Get-ChildItem -Force @args }
function lt { Get-ChildItem @args | Sort-Object LastWriteTime }

# Safer file operations
function Convert-UnixFileArgs {
    param([object[]]$InputArgs)

    $converted = [ordered]@{
        Args = @()
        Recurse = $false
        Force = $false
        Confirm = $false
    }

    foreach ($arg in $InputArgs) {
        switch -Regex ($arg) {
            "^-rf$|^-fr$" { $converted.Recurse = $true; $converted.Force = $true; continue }
            "^-r$|^-R$" { $converted.Recurse = $true; continue }
            "^-f$" { $converted.Force = $true; continue }
            "^-i$" { $converted.Confirm = $true; continue }
            default { $converted.Args += $arg }
        }
    }

    return [pscustomobject]$converted
}

function Get-FileCommandParams {
    param(
        [Parameter(Mandatory = $true)][pscustomobject]$ConvertedArgs,
        [switch]$DefaultConfirm
    )

    $params = @{}
    if ($ConvertedArgs.Recurse) {
        $params.Recurse = $true
    }
    if ($ConvertedArgs.Force) {
        $params.Force = $true
    }
    if ($ConvertedArgs.Confirm -or ($DefaultConfirm -and -not $ConvertedArgs.Force)) {
        $params.Confirm = $true
    }

    return $params
}

function rm {
    $convertedArgs = Convert-UnixFileArgs $args
    $params = Get-FileCommandParams $convertedArgs -DefaultConfirm
    Remove-Item @params @($convertedArgs.Args)
}

function cp {
    $convertedArgs = Convert-UnixFileArgs $args
    $params = Get-FileCommandParams $convertedArgs -DefaultConfirm
    Copy-Item @params @($convertedArgs.Args)
}

function mv {
    $convertedArgs = Convert-UnixFileArgs $args
    $params = Get-FileCommandParams $convertedArgs -DefaultConfirm
    Move-Item @params @($convertedArgs.Args)
}

# Docker
function dps { docker ps @args }
function dc { docker-compose @args }
function dcu { docker-compose up -d @args }
function dcd { docker-compose down @args }

function reload {
    if ($global:DotfilesPowerShellProfile -and (Test-Path $global:DotfilesPowerShellProfile)) {
        . $global:DotfilesPowerShellProfile
    } else {
        . $PROFILE
    }
}

function glp {
    param([Parameter(Mandatory = $true)][string]$Count)
    git --no-pager log "-$Count"
}

function pr {
    param([string]$Target)

    if ($Target -eq "ls") {
        gh pr list
    } else {
        gh pr checkout $Target
    }
}
