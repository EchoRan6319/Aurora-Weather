@echo off
echo Setting up environment variables...
set PATH=C:\Windows\System32;C:\Windows\System32\WindowsPowerShell\v1.0;C:\Program Files\Git\bin;D:\Flutter\bin
echo PATH=%PATH%

echo.
echo Cleaning build cache...
flutter clean

echo.
echo Getting dependencies...
flutter pub get

echo.
echo Building Android Debug APK...
flutter build apk --debug
if %ERRORLEVEL% EQU 0 (
  echo Android Debug APK built successfully!
) else (
  echo Failed to build Android Debug APK!
  exit /b 1
)

echo.
echo Building Android Release APK...
flutter build apk --release --target-platform android-arm64
if %ERRORLEVEL% EQU 0 (
  echo Android Release APK built successfully!
) else (
  echo Failed to build Android Release APK!
  exit /b 1
)

echo.
echo Building Windows...
flutter build windows --release
if %ERRORLEVEL% EQU 0 (
  echo Windows build completed successfully!
) else (
  echo Failed to build Windows!
  exit /b 1
)

echo.
echo All builds completed successfully!
pause
