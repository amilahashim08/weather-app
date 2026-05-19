@echo off
REM Double-click or run: run-phone.bat
set "PATH=%LOCALAPPDATA%\flutter\bin;%LOCALAPPDATA%\Android\Sdk\platform-tools;%PATH%"
set "ANDROID_HOME=%LOCALAPPDATA%\Android\Sdk"
cd /d "%~dp0"

echo.
echo === Flutter Weather App - Android ===
echo.

where flutter >nul 2>&1
if errorlevel 1 (
  echo [ERROR] Flutter not in PATH.
  echo Add: %LOCALAPPDATA%\flutter\bin
  pause
  exit /b 1
)

if not exist "%ANDROID_HOME%" (
  echo [ERROR] Android SDK not installed.
  echo.
  echo Install Android Studio first:
  echo   https://developer.android.com/studio
  echo.
  echo Then open SDK Manager and install Android SDK.
  echo Full guide: RUN-ON-PHONE.md
  pause
  exit /b 1
)

flutter pub get
echo.
echo Devices:
flutter devices
echo.
flutter run
pause
