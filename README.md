# opensim-nunit3  
NUnit 3.0 tests  

## NUnit 3 Multi-Target Test Setup (net6.0, net8.0, net10.0)  

This repository now uses a central NUnit 3 test project:  

- `OpenSim/Tests/OpenSim.NUnit3.Tests.csproj`  

The project is configured for the following target frameworks:  

- `net6.0`  
- `net8.0`  
- `net10.0`  

## Goal  

A central, stable NUnit 3 runner for `net6.0`, `net8.0`, and `net10.0` that runs via `dotnet test` and serves as a compatible entry point for further migration.  

## What has been migrated  

1. NUnit 3 test project with the following packages:  
   - `Microsoft.NET.Test.Sdk`  
   - `NUnit` (3.x)  
   - `NUnit3TestAdapter`  
2. Legacy attributes in test sources have been updated to NUnit 3 names:  
   - `[TestFixtureSetUp]` -> `[OneTimeSetUp]`  
   - `[TestFixtureTearDown]` -> `[OneTimeTearDown]`  
3. A compatible smoke test (`NUnitCompatibilitySmokeTests.cs`) runs on all three target frameworks.  
4. For `net10.0`, the following legacy test blocks have also been actively migrated:  
   - `OpenSim/Framework/Tests`  
   - `OpenSim/Framework/Serialization/Tests`  
   - `OpenSim/Data/Tests`  
5. Legacy custom constraints have been updated to the NUnit 3 API (`ApplyTo<TActual>`):  
   - `DoubleToleranceConstraint`  
   - `VectorToleranceConstraint`  
   - `QuaternionToleranceConstraint`  
   - `PropertyCompareConstraint`  

## Running tests  

Execute from the `opensim` folder (solution root):  

```powershell
dotnet restore OpenSim/Tests/OpenSim.NUnit3.Tests.csproj
```

Recommended entry point (NUnit3-only, with coverage/RunSettings):  

```powershell
run-nunit3-tests.bat quick
```

Additional modes:  

```powershell
run-nunit3-tests.bat full
run-nunit3-tests.bat matrix
run-nunit3-tests.bat compat
```

Where:  

- `quick`: net10, without `Long*` and `Database`  
- `full`: net10 without category filters  
- `matrix`: net8 + net10, without `Long*` and `Database`  
- `compat`: net6 + net8 + net10 compatibility run (net6 is automatically skipped if the runtime is missing)  

The central configuration is located in:  

- `OpenSim/Tests/OpenSim.NUnit3.runsettings`  

It enables XPlat Code Coverage by default, making test runs easier to evaluate for vulnerability analysis.  

## Dedicated test INI configuration  

For reproducible integration runs, dedicated test INI files are now available:  

- `bin/OpenSim.Tests.ini`  
- `bin/config-include/Standalone.Tests.ini`  
- `bin/config-include/StandaloneCommon.Tests.ini`  
- `bin/Robust.Tests.ini` (already present)  

Starting OpenSim with test configuration:  

```powershell
cd bin
OpenSim.exe -inifile OpenSim.Tests.ini
```

Starting Robust with test configuration:  

```powershell
cd bin
Robust.exe -inifile Robust.Tests.ini
```

Testing all targets:  

```powershell
dotnet test OpenSim/Tests/OpenSim.NUnit3.Tests.csproj -c Release
```

Testing a specific framework:  

```powershell
dotnet test OpenSim/Tests/OpenSim.NUnit3.Tests.csproj -c Release -f net6.0
dotnet test OpenSim/Tests/OpenSim.NUnit3.Tests.csproj -c Release -f net8.0
dotnet test OpenSim/Tests/OpenSim.NUnit3.Tests.csproj -c Release -f net10.0
```

Using an explicit RunSettings file:  

```powershell
dotnet test OpenSim/Tests/OpenSim.NUnit3.Tests.csproj -c Release -f net10.0 --settings OpenSim/Tests/OpenSim.NUnit3.runsettings
```

Notes on the frameworks on this machine:  

- The .NET 6 runtime is installed locally (`Microsoft.NETCore.App 6.0.36`) and the net6 test run has been successfully verified.  
- `net8.0` runs successfully in the current environment.  
- `net10.0` runs successfully in the current environment, including the migrated legacy blocks.  

Note on Data tests:  

- Many Data tests expect optional DB connection data from the resource file `TestDataConnections.ini`.  
- If this resource is missing, the affected DB tests are now marked as `Skipped` (instead of failing), so local runs without DB test infrastructure remain stable.  

## Important operational/configuration notes  

### WebRtcVoiceServiceModule on Windows  

The `WebRtcVoiceServiceModule` requires a Janus gateway.  
On Windows, no Janus gateway is available in this environment.  

Consequence:  

- WebRTC voice functionality is not usable here.  
- Corresponding module messages in the log are expected and not part of the NUnit test migration.  

### Groups and SQLite  

The Groups module is not active here because the Groups backends are not run with SQLite in this configuration.  

Consequence:  

- Warnings such as `Could not get IGroupsModule` may appear in the runtime log.  
- This is expected behavior for this standalone/SQLite configuration.  

## Scope  

This migration delivers a working NUnit 3 multi-target runner with actively migrated legacy test blocks under `net10.0`, a stable smoke test under `net8.0`, and build-capable `net6.0` (runtime 6.0 required for execution).  

Important notes on framework compatibility:  

- The runner itself is compatible with `net6.0`, `net8.0`, and `net10.0`.  
- The broad legacy suite (Data/Framework/Serialization) is intentionally tied to `net10.0` because the underlying OpenSim projects are currently net10-only.  
- For net6/net8, the stable smoke/baseline path remains active as long as the affected dependency projects are not multi-targeted again.  
Runtime warnings from optional add-ons (e.g., Janus/WebRTC or Groups backends) are documented here but are not "configured away" as part of the NUnit migration.  

## Note on prebuild.xml and the old NUnit flow  

NUnit3 execution is done via `dotnet test` on `OpenSim.NUnit3.Tests.csproj`.  

The legacy Prebuild test path in `prebuild.xml` is not required for this and is no longer needed for the standard NUnit3 run.
