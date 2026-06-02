@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
set "SOURCE_ROOT=%SCRIPT_DIR%opensim"
set "DEST_ROOT=%SCRIPT_DIR%NUnit3"

if not exist "%SOURCE_ROOT%" (
  echo [ERROR] Source folder not found: "%SOURCE_ROOT%"
  exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ErrorActionPreference = 'Stop';" ^
  "$sourceRoot = Join-Path $env:SCRIPT_DIR 'opensim';" ^
  "$destRoot = Join-Path $env:SCRIPT_DIR 'NUnit3';" ^
  "Set-Location $sourceRoot;" ^
  "if (-not (Test-Path $destRoot)) { New-Item -ItemType Directory -Path $destRoot | Out-Null };" ^
  "Get-ChildItem -Path $destRoot -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force;" ^
  "$status = git status --porcelain;" ^
  "$changed = @();" ^
  "foreach ($line in $status) {" ^
  "  if ($line.Length -lt 4) { continue }" ^
  "  $path = $line.Substring(3).Trim().Trim('""');" ^
  "  if ($line.StartsWith('D ')) { continue }" ^
  "  $changed += $path;" ^
  "}" ^
  "$selected = $changed | Where-Object {" ^
  "  ($_ -match '(^|[\\/])Tests([\\/]|$)') -or" ^
  "  ($_ -eq 'NUnit-readme.md') -or" ^
  "  ($_ -eq 'run-nunit3-tests.bat') -or" ^
  "  ($_ -eq 'bin/OpenSim.Tests.ini') -or" ^
  "  ($_ -eq 'bin/config-include/Standalone.Tests.ini') -or" ^
  "  ($_ -eq 'bin/config-include/StandaloneCommon.Tests.ini') -or" ^
  "  ($_ -eq 'OpenSim/Tests/OpenSim.NUnit3.Tests.csproj') -or" ^
  "  ($_ -eq 'OpenSim/Tests/OpenSim.NUnit3.runsettings') -or" ^
  "  ($_ -eq 'OpenSim/Tests/NUnitCompatibilitySmokeTests.cs')" ^
  "} | Sort-Object -Unique;" ^
  "foreach ($must in @('NUnit-readme.md','run-nunit3-tests.bat','bin/OpenSim.Tests.ini','bin/config-include/Standalone.Tests.ini','bin/config-include/StandaloneCommon.Tests.ini','OpenSim/Tests/OpenSim.NUnit3.Tests.csproj','OpenSim/Tests/OpenSim.NUnit3.runsettings')) {" ^
  "  if (Test-Path -Path $must -PathType Leaf) { $selected += $must }" ^
  "}" ^
  "$selected = $selected | Sort-Object -Unique;" ^
  "$count = 0;" ^
  "foreach ($rel in $selected) {" ^
  "  if (-not (Test-Path -Path $rel -PathType Leaf)) { continue }" ^
  "  $target = Join-Path $destRoot $rel;" ^
  "  $targetDir = Split-Path -Path $target -Parent;" ^
  "  New-Item -ItemType Directory -Path $targetDir -Force | Out-Null;" ^
  "  Copy-Item -Path $rel -Destination $target -Force;" ^
  "  $count++;" ^
  "}" ^
  "Write-Host ('Mirrored files: ' + $count);" ^
  "Write-Host ('Destination: ' + $destRoot);"

if errorlevel 1 (
  echo [ERROR] Mirror update failed.
  exit /b 1
)

echo [OK] NUnit3 mirror updated successfully.
exit /b 0
