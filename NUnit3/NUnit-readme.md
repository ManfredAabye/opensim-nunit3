# NUnit 3 Multi-Target Test Setup (net6.0, net8.0, net10.0)

Dieses Repository verwendet jetzt ein zentrales NUnit-3-Testprojekt:

- `OpenSim/Tests/OpenSim.NUnit3.Tests.csproj`

Das Projekt ist auf folgende Target Frameworks konfiguriert:

- `net6.0`
- `net8.0`
- `net10.0`

## Ziel

Ein zentraler, stabiler NUnit-3-Runner fuer `net6.0`, `net8.0` und `net10.0`, der per `dotnet test` laeuft und als kompatibler Einstiegspunkt fuer weitere Migration dient.

## Was wurde umgestellt

1. NUnit-3 Testprojekt mit folgenden Paketen:
   - `Microsoft.NET.Test.Sdk`
   - `NUnit` (3.x)
   - `NUnit3TestAdapter`
2. Legacy-Attribute in Testquellen wurden auf NUnit-3-Namen umgestellt:
   - `[TestFixtureSetUp]` -> `[OneTimeSetUp]`
   - `[TestFixtureTearDown]` -> `[OneTimeTearDown]`
3. Ein kompatibler Smoke-Test (`NUnitCompatibilitySmokeTests.cs`) wird auf allen drei Target Frameworks ausgefuehrt.
4. Fuer `net10.0` sind zusaetzlich folgende Legacy-Testbloecke aktiv migriert:
   - `OpenSim/Framework/Tests`
   - `OpenSim/Framework/Serialization/Tests`
   - `OpenSim/Data/Tests`
5. Legacy-Custom-Constraints wurden auf die NUnit3-API (`ApplyTo<TActual>`) umgestellt:
   - `DoubleToleranceConstraint`
   - `VectorToleranceConstraint`
   - `QuaternionToleranceConstraint`
   - `PropertyCompareConstraint`

## Testausfuehrung

Im Ordner `opensim` (Solution-Root) ausfuehren:

```powershell
dotnet restore OpenSim/Tests/OpenSim.NUnit3.Tests.csproj
```

Empfohlener Einstieg (NUnit3-only, mit Coverage/RunSettings):

```powershell
run-nunit3-tests.bat quick
```

Weitere Modi:

```powershell
run-nunit3-tests.bat full
run-nunit3-tests.bat matrix
```

Dabei gilt:

- `quick`: net10, ohne `Long*` und `Database`
- `full`: net10 ohne Category-Filter
- `matrix`: net8 + net10, ohne `Long*` und `Database`

Die zentrale Konfiguration liegt in:

- `OpenSim/Tests/OpenSim.NUnit3.runsettings`

Sie aktiviert standardmaessig XPlat Code Coverage, damit Testlaeufe besser fuer Schwachstellenanalyse auswertbar sind.

## Dedizierte Test-INI-Konfiguration

Fuer reproduzierbare Integrationslaeufe gibt es jetzt eigene Test-INI-Dateien:

- `bin/OpenSim.Tests.ini`
- `bin/config-include/Standalone.Tests.ini`
- `bin/config-include/StandaloneCommon.Tests.ini`
- `bin/Robust.Tests.ini` (bereits vorhanden)

OpenSim mit Testkonfiguration starten:

```powershell
cd bin
OpenSim.exe -inifile OpenSim.Tests.ini
```

Robust mit Testkonfiguration starten:

```powershell
cd bin
Robust.exe -inifile Robust.Tests.ini
```

Alle Targets testen:

```powershell
dotnet test OpenSim/Tests/OpenSim.NUnit3.Tests.csproj -c Release
```

Gezielt pro Framework testen:

```powershell
dotnet test OpenSim/Tests/OpenSim.NUnit3.Tests.csproj -c Release -f net6.0
dotnet test OpenSim/Tests/OpenSim.NUnit3.Tests.csproj -c Release -f net8.0
dotnet test OpenSim/Tests/OpenSim.NUnit3.Tests.csproj -c Release -f net10.0
```

Mit expliziter RunSettings-Datei:

```powershell
dotnet test OpenSim/Tests/OpenSim.NUnit3.Tests.csproj -c Release -f net10.0 --settings OpenSim/Tests/OpenSim.NUnit3.runsettings
```

Hinweise zu den Frameworks auf diesem Rechner:

- Der Build funktioniert, die Ausfuehrung des Testhosts benoetigt jedoch lokal die installierte .NET-6-Runtime (`Microsoft.NETCore.App 6.0.x`).
- `net8.0` laeuft in der aktuellen Umgebung erfolgreich.
- `net10.0` laeuft in der aktuellen Umgebung erfolgreich, inklusive der migrierten Legacy-Bloecke.

Hinweis zu Data-Tests:

- Viele Data-Tests erwarten optionale DB-Verbindungsdaten aus der Resource-Datei `TestDataConnections.ini`.
- Ist diese Resource nicht vorhanden, werden die betroffenen DB-Tests jetzt als `Skipped` markiert (statt als Fehler), damit lokale Runs ohne DB-Testinfrastruktur stabil bleiben.

## Wichtige Betriebs-/Konfigurationshinweise

### WebRtcVoiceServiceModule unter Windows

Das `WebRtcVoiceServiceModule` benoetigt ein Janus-Gateway.
Auf Windows ist in dieser Umgebung kein Janus-Gateway verfuegbar.

Folge:

- WebRTC-Voice-Funktionalitaet ist hier nicht nutzbar.
- Entsprechende Modulmeldungen im Log sind erwartbar und nicht Teil der NUnit-Testmigration.

### Groups und SQLite

Das Groups-Modul ist hier nicht aktiv, weil die Groups-Backends in dieser Konfiguration nicht mit SQLite betrieben werden.

Folge:

- Warnungen wie `Could not get IGroupsModule` koennen im Laufzeitlog auftreten.
- Das ist erwartetes Verhalten fuer diese Standalone/SQLite-Konfiguration.

## Scope

Diese Umstellung liefert einen lauffaehigen NUnit-3-Multi-Target-Runner mit aktiv migrierten Legacy-Testbloecken unter `net10.0`, stabilem Smoke-Test unter `net8.0` und build-faehigem `net6.0` (Runtime 6.0 erforderlich fuer Ausfuehrung).
Fachliche Laufzeitwarnungen aus optionalen Addons (z.B. Janus/WebRTC oder Groups-Backends) werden hier dokumentiert, aber nicht als Teil der NUnit-Migration "wegkonfiguriert".

## Hinweis zu prebuild.xml und altem NUnit-Flow

Die NUnit3-Ausfuehrung erfolgt ueber `dotnet test` auf `OpenSim.NUnit3.Tests.csproj`.

Der legacy Prebuild-Testpfad in `prebuild.xml` ist dafuer nicht erforderlich und wird fuer den NUnit3-Standardlauf nicht mehr benoetigt.
