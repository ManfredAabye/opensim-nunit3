@echo off
setlocal

set "MODE=%~1"
if "%MODE%"=="" set "MODE=quick"

set "ROOT=%~dp0"
set "PROJ=%ROOT%OpenSim\Tests\OpenSim.NUnit3.Tests.csproj"
set "SETTINGS=%ROOT%OpenSim\Tests\OpenSim.NUnit3.runsettings"
set "CONFIG=Release"
set "FILTER_FAST=TestCategory!~Long&TestCategory!=Database"

if not exist "%PROJ%" (
  echo [ERROR] Project not found: "%PROJ%"
  exit /b 1
)

if not exist "%SETTINGS%" (
  echo [ERROR] Runsettings not found: "%SETTINGS%"
  exit /b 1
)

echo [INFO] Restoring NUnit3 test project...
dotnet restore "%PROJ%"
if errorlevel 1 exit /b 1

if /I "%MODE%"=="quick" goto :quick
if /I "%MODE%"=="full" goto :full
if /I "%MODE%"=="matrix" goto :matrix
if /I "%MODE%"=="help" goto :help

echo [ERROR] Unknown mode: %MODE%
goto :help

:quick
echo [INFO] QUICK mode: net10, excludes long-running-like and database categories.
dotnet test "%PROJ%" -c %CONFIG% -f net10.0 --settings "%SETTINGS%" --filter "%FILTER_FAST%" --logger "trx;LogFileName=nunit3-quick-net10.trx"
exit /b %ERRORLEVEL%

:full
echo [INFO] FULL mode: net10, no category filter.
dotnet test "%PROJ%" -c %CONFIG% -f net10.0 --settings "%SETTINGS%" --logger "trx;LogFileName=nunit3-full-net10.trx"
exit /b %ERRORLEVEL%

:matrix
echo [INFO] MATRIX mode: net8 + net10, excludes long-running-like and database categories.
dotnet test "%PROJ%" -c %CONFIG% -f net8.0 --settings "%SETTINGS%" --filter "%FILTER_FAST%" --logger "trx;LogFileName=nunit3-matrix-net8.trx"
if errorlevel 1 exit /b 1
dotnet test "%PROJ%" -c %CONFIG% -f net10.0 --settings "%SETTINGS%" --filter "%FILTER_FAST%" --logger "trx;LogFileName=nunit3-matrix-net10.trx"
exit /b %ERRORLEVEL%

:help
echo Usage: run-nunit3-tests.bat [quick^|full^|matrix^|help]
echo   quick  - net10 fast baseline (no Long*, no Database)
echo   full   - net10 complete set in current project scope
echo   matrix - net8 + net10 fast baseline
exit /b 1
