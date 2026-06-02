@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
set "PS_SCRIPT=%SCRIPT_DIR%apply-nunit3-mirror.ps1"
set "ARGS="

if not exist "%PS_SCRIPT%" (
  echo [ERROR] Missing helper script: "%PS_SCRIPT%"
  exit /b 1
)

if "%~1"=="" goto run

:parse_args
if "%~1"=="" goto run
if /I "%~1"=="--dry-run" (
  set "ARGS=%ARGS% -DryRun"
) else if /I "%~1"=="--no-backup" (
  set "ARGS=%ARGS% -NoBackup"
) else if /I "%~1"=="--help" (
  set "ARGS=%ARGS% -Help"
) else (
  set "ARGS=%ARGS% "%~1""
)
shift
goto parse_args

:run
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%" %ARGS%
exit /b %ERRORLEVEL%
