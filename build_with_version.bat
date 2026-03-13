@echo off
chcp 65001 >nul
echo ==========================================
echo   PureWeather Build with Version Sync
echo ==========================================
echo.

REM Update version from Git tag
echo [1/2] Updating version from Git tag...
powershell -ExecutionPolicy Bypass -File "%~dp0scripts\update_version.ps1"
if %ERRORLEVEL% NEQ 0 (
    echo Failed to update version!
    pause
    exit /b 1
)

echo.
echo [2/2] Building Flutter app...
flutter build %*

echo.
echo ==========================================
echo   Build Complete
echo ==========================================
pause
