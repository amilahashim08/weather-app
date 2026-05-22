# Frees space on D: so the Android emulator can start (needs roughly 1–2+ GB free on the AVD drive).
# Safe targets: Gradle cache on D:, AVD snapshots (cold boot next time), local .dart_tool, android/.gradle.
#
#   powershell -ExecutionPolicy Bypass -File .\scripts\free-d-drive-for-android.ps1

$ErrorActionPreference = "Continue"
Write-Host "Stopping Gradle daemons..." -ForegroundColor Cyan
$gradleUser = "E:\gradle"
if (Test-Path "D:\react-native-project\weather-app\android\gradlew.bat") {
    Push-Location "D:\react-native-project\weather-app\android"
    $env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
    $env:GRADLE_USER_HOME = $gradleUser
    & .\gradlew.bat --stop 2>$null
    Pop-Location
}
Get-Process -Name "java" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Milliseconds 800

$targets = @(
    "D:\gradle",
    "D:\Android\avd\flutter_emulator.avd\snapshots",
    "D:\react-native-project\weather-app\.dart_tool",
    "D:\react-native-project\weather-app\android\.gradle"
)
foreach ($t in $targets) {
    if (Test-Path $t) {
        Write-Host "Removing: $t" -ForegroundColor Yellow
        Remove-Item $t -Recurse -Force -ErrorAction SilentlyContinue
    }
}

$d = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='D:'"
$gb = [math]::Round($d.FreeSpace / 1GB, 2)
Write-Host ""
Write-Host "D: free space now: ~$gb GB" -ForegroundColor $(if ($gb -ge 1.5) { "Green" } else { "Yellow" })
if ($gb -lt 1) {
    Write-Host "Still low — delete large files on D: or move the project to another drive." -ForegroundColor Red
}
