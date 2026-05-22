# Verifies SDK layout for VS Code "AVD Manager" (toroxx.vscode-avdmanager).
# Run: powershell -File scripts/verify-android-sdk-for-avd.ps1
# Or:  .\scripts\verify-android-sdk-for-avd.ps1

$ErrorActionPreference = "Stop"
$sdk = if ($env:ANDROID_HOME) { $env:ANDROID_HOME } else { "D:\Android\Sdk" }
$checks = @(
    @{ Path = Join-Path $sdk "cmdline-tools\latest\bin\avdmanager.bat"; Name = "avdmanager (cmdline-tools)" }
    @{ Path = Join-Path $sdk "cmdline-tools\latest\bin\sdkmanager.bat"; Name = "sdkmanager (cmdline-tools)" }
    @{ Path = Join-Path $sdk "emulator\emulator.exe"; Name = "emulator" }
    @{ Path = Join-Path $sdk "platform-tools\adb.exe"; Name = "adb" }
)
$ok = $true
foreach ($c in $checks) {
    $exists = Test-Path -LiteralPath $c.Path
    if ($exists) {
        Write-Host "[OK]   $($c.Name)" -ForegroundColor Green
        Write-Host "       $($c.Path)"
    } else {
        Write-Host "[MISS] $($c.Name)" -ForegroundColor Red
        Write-Host "       $($c.Path)"
        $ok = $false
    }
}
$avdHome = if ($env:ANDROID_AVD_HOME) { $env:ANDROID_AVD_HOME } else { "D:\Android\avd" }
Write-Host ""
if (Test-Path -LiteralPath $avdHome) {
    Write-Host "[OK]   AVD home: $avdHome" -ForegroundColor Green
} else {
    Write-Host "[WARN] AVD home missing (create or set ANDROID_AVD_HOME): $avdHome" -ForegroundColor Yellow
}
Write-Host ""
Write-Host "Workspace uses these in .vscode/settings.json (avdmanager.sdkPath / avdHome)." -ForegroundColor Cyan
if (-not $ok) {
    Write-Host ""
    Write-Host "Fix: Android Studio -> SDK Manager -> SDK Tools -> Android SDK Command-line Tools (latest)" -ForegroundColor Yellow
    exit 1
}
