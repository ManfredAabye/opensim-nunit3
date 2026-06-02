param(
    [Parameter(Position = 0)]
    [string]$TargetRoot,

    [switch]$DryRun,
    [switch]$NoBackup,
    [switch]$Help
)

$ErrorActionPreference = 'Stop'

function Get-Sha256Hex {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $stream = [System.IO.File]::OpenRead($Path)
        try {
            $hashBytes = $sha.ComputeHash($stream)
            return [System.BitConverter]::ToString($hashBytes).Replace('-', '')
        }
        finally {
            $stream.Dispose()
        }
    }
    finally {
        $sha.Dispose()
    }
}

function Show-Usage {
    Write-Host 'Usage:'
    Write-Host '  apply-nunit3-mirror.bat <target-opensim-root> [--dry-run] [--no-backup]'
    Write-Host ''
    Write-Host 'Examples:'
    Write-Host '  apply-nunit3-mirror.bat D:\opensim-other\opensim'
    Write-Host '  apply-nunit3-mirror.bat D:\opensim-other\opensim --dry-run'
    Write-Host '  apply-nunit3-mirror.bat D:\opensim-other\opensim --no-backup'
    Write-Host ''
    Write-Host 'Defaults:'
    Write-Host '  - Backup enabled (changed target files are copied to .\NUnit3-Backup\<timestamp>)'
}

if ($Help -or [string]::IsNullOrWhiteSpace($TargetRoot)) {
    Show-Usage
    exit 1
}

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$mirrorRoot = Join-Path $scriptRoot 'NUnit3'

if (-not (Test-Path -LiteralPath $mirrorRoot)) {
    throw "Mirror folder not found: $mirrorRoot"
}

$resolvedTarget = (Resolve-Path -LiteralPath $TargetRoot).Path
if (-not (Test-Path -LiteralPath $resolvedTarget)) {
    throw "Target path not found: $TargetRoot"
}

if (-not (Test-Path -LiteralPath (Join-Path $resolvedTarget 'OpenSim'))) {
    Write-Warning "Target does not contain an OpenSim subfolder: $resolvedTarget"
}

$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backupRoot = Join-Path $scriptRoot (Join-Path 'NUnit3-Backup' $timestamp)
$useBackup = -not $NoBackup

$files = Get-ChildItem -LiteralPath $mirrorRoot -Recurse -File
if (-not $files) {
    throw "No files found in mirror folder: $mirrorRoot"
}

$copied = 0
$backedUp = 0
$unchanged = 0
$newFiles = 0
$updatedFiles = 0

foreach ($src in $files) {
    $rel = $src.FullName.Substring($mirrorRoot.Length).TrimStart([char[]]@('\', '/'))
    $dst = Join-Path $resolvedTarget $rel

    $dstExists = Test-Path -LiteralPath $dst
    $same = $false

    if ($dstExists) {
        $srcHash = Get-Sha256Hex -Path $src.FullName
        $dstHash = Get-Sha256Hex -Path $dst
        $same = ($srcHash -eq $dstHash)
    }

    if ($same) {
        $unchanged++
        continue
    }

    if ($dstExists) {
        $updatedFiles++
        if ($useBackup) {
            $backupPath = Join-Path $backupRoot $rel
            if (-not $DryRun) {
                $backupDir = Split-Path -Parent $backupPath
                if ($backupDir -and -not (Test-Path -LiteralPath $backupDir)) {
                    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
                }
                Copy-Item -LiteralPath $dst -Destination $backupPath -Force
            }
            $backedUp++
        }
    }
    else {
        $newFiles++
    }

    if (-not $DryRun) {
        $dstDir = Split-Path -Parent $dst
        if ($dstDir -and -not (Test-Path -LiteralPath $dstDir)) {
            New-Item -ItemType Directory -Path $dstDir -Force | Out-Null
        }
        Copy-Item -LiteralPath $src.FullName -Destination $dst -Force
    }

    $copied++
}

Write-Host ('Mode: ' + ($(if ($DryRun) { 'DRY-RUN' } else { 'APPLY' })))
Write-Host ('Source mirror: ' + $mirrorRoot)
Write-Host ('Target root:   ' + $resolvedTarget)
if ($useBackup) {
    Write-Host ('Backup root:   ' + $backupRoot)
}
else {
    Write-Host 'Backup root:   disabled (--no-backup)'
}
Write-Host ('Files in mirror: ' + $files.Count)
Write-Host ('Unchanged:       ' + $unchanged)
Write-Host ('To copy/apply:   ' + $copied)
Write-Host ('  New files:     ' + $newFiles)
Write-Host ('  Updated files: ' + $updatedFiles)
if ($useBackup) {
    Write-Host ('Backups made:    ' + $backedUp)
}

if ($DryRun) {
    Write-Host '[OK] Dry-run completed. No files were changed.'
}
else {
    Write-Host '[OK] Mirror applied successfully.'
}
