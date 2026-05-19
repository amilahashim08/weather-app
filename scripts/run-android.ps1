# Run Weather App on Android (phone or emulator)
# Prerequisites: Android Studio + SDK — see README "Run on mobile"

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $ProjectRoot

$sdk = if ($env:ANDROID_HOME) { $env:ANDROID_HOME } else { "D:\Android\Sdk" }
$avdHome = if ($env:ANDROID_AVD_HOME) { $env:ANDROID_AVD_HOME } else { "D:\Android\avd" }
$env:ANDROID_HOME = $sdk
$env:ANDROID_AVD_HOME = $avdHome
$env:GRADLE_USER_HOME = if ($env:GRADLE_USER_HOME) { $env:GRADLE_USER_HOME } else { "D:\gradle" }
$env:PUB_CACHE = if ($env:PUB_CACHE) { $env:PUB_CACHE } else { "D:\pub-cache" }
$env:TEMP = "D:\temp"
$env:TMP = "D:\temp"
New-Item -ItemType Directory -Force -Path $env:GRADLE_USER_HOME, $env:PUB_CACHE, $env:TEMP | Out-Null
$env:Path = "C:\Users\hp\AppData\Local\flutter\bin;$sdk\platform-tools;$sdk\emulator;" + $env:Path

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Error "Flutter not found. Install Flutter or add it to PATH. See RUN-ON-PHONE.md"
}

if (-not (Test-Path $env:ANDROID_HOME)) {
    Write-Host ""
    Write-Host "Android SDK not installed at:" $env:ANDROID_HOME -ForegroundColor Red
    Write-Host "Install Android Studio: https://developer.android.com/studio" -ForegroundColor Yellow
    Write-Host "Full guide: RUN-ON-PHONE.md" -ForegroundColor Cyan
    exit 1
}

Write-Host "Checking devices..." -ForegroundColor Cyan
& $flutter devices

$android = (& $flutter devices 2>&1 | Select-String "android")
if (-not $android) {
    Write-Host ""
    Write-Host "No Android device found." -ForegroundColor Yellow
    Write-Host "  1. Install Android Studio: https://developer.android.com/studio" -ForegroundColor Gray
    Write-Host "  2. Open Device Manager → Create Virtual Device (e.g. Pixel 7)" -ForegroundColor Gray
    Write-Host "     OR plug in a phone with USB debugging enabled" -ForegroundColor Gray
    Write-Host "  3. Run: flutter doctor --android-licenses" -ForegroundColor Gray
    Write-Host "  4. Run this script again" -ForegroundColor Gray
    exit 1
}

Write-Host ""
Write-Host "Starting app on Android..." -ForegroundColor Green
& $flutter pub get
& $flutter run
