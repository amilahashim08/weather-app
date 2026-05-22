# Enables Windows Developer Mode (symlinks for Flutter Windows / plugin builds).
# Flutter shows "Building with plugins requires symlink support" without this when using `flutter run` with Windows (or when no Android device is selected).
#
# Option A — GUI (easiest): run this to open Settings
#   start ms-settings:developers
#   Turn ON "Developer Mode"
#
# Option B — this script (needs Administrator PowerShell once):
#   Right-click PowerShell → Run as administrator, then:
#   cd D:\react-native-project\weather-app
#   Set-ExecutionPolicy -Scope Process Bypass -File .\scripts\enable-windows-developer-mode.ps1
#
# For Android-only: you can skip this — use  .\run.ps1 -d emulator-5554  instead of plain  flutter run

$ErrorActionPreference = "Stop"
$key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
$name = "AllowDevelopmentWithoutDevLicense"

function Get-DevMode {
    if (-not (Test-Path $key)) { return $false }
    $v = Get-ItemProperty -Path $key -Name $name -ErrorAction SilentlyContinue
    return ($null -ne $v -and $v.$name -eq 1)
}

if (Get-DevMode) {
    Write-Host "Developer Mode is already enabled (registry)." -ForegroundColor Green
    exit 0
}

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "Developer Mode is OFF. Flutter needs it for Windows builds with plugins (symlinks)." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "EASIEST: Opening Settings — turn ON 'Developer Mode'..." -ForegroundColor Cyan
    Start-Process "ms-settings:developers"
    Write-Host ""
    Write-Host "Or run this script again from an elevated (Run as administrator) PowerShell to set the registry automatically." -ForegroundColor Gray
    exit 1
}

if (-not (Test-Path $key)) {
    New-Item -Path $key -Force | Out-Null
}
New-ItemProperty -Path $key -Name $name -PropertyType DWord -Value 1 -Force | Out-Null
Write-Host "Developer Mode registry flag set. Reboot if Flutter still complains; then try: flutter run -d windows" -ForegroundColor Green
