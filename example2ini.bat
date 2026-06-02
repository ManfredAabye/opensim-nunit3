@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem *.ini.example in *.ini umbenennen im Verzeichnis opensim und allen unterverzeichnissen.
set "EXAMPLE_INI_PATTERN=*.ini.example"

pushd "opensim\bin" || (
    echo Fehler: Verzeichnis "opensim\bin" wurde nicht gefunden.
    exit /b 1
)

for /r %%i in (%EXAMPLE_INI_PATTERN%) do (
    set "NEW_NAME=%%~nxi"
    set "NEW_NAME=!NEW_NAME:.example=!"
    set "TARGET_FILE=%%~dpi!NEW_NAME!"
    if not exist "!TARGET_FILE!" (
        echo Renaming "%%~fi" to "!TARGET_FILE!"
        ren "%%~fi" "!NEW_NAME!"
    ) else (
        echo Skipping "%%~fi" because "!TARGET_FILE!" already exists.
    )
)
popd
endlocal
pause