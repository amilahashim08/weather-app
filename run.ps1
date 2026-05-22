# Run weather app - Gradle/cache on E: so D: does not fill up.
# PowerShell:  .\run.ps1 -DeviceId emulator-5554
# Git Bash:    ./run.sh -d emulator-5554

param(
    [Alias("d")]
    [string]$DeviceId
)

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
$env:ANDROID_HOME = if ($env:ANDROID_HOME) { $env:ANDROID_HOME } else { "D:\Android\Sdk" }
$env:GRADLE_USER_HOME = "E:\gradle"
$env:PUB_CACHE = "E:\pub-cache"
$env:TEMP = "E:\temp"
$env:TMP = "E:\temp"
$buildLink = Join-Path $PSScriptRoot "build"
$buildTarget = "E:\weather-app-build"
New-Item -ItemType Directory -Force -Path $env:GRADLE_USER_HOME, $env:PUB_CACHE, $env:TEMP, $buildTarget | Out-Null
if (-not (Test-Path $buildLink)) {
    cmd /c mklink /J "`"$buildLink`"" "`"$buildTarget`"" 2>$null | Out-Null
}

$drive = (Get-Item $PSScriptRoot).PSDrive.Name
$freeGb = [math]::Round((Get-PSDrive $drive).Free / 1GB, 2)
if ($freeGb -lt 0.5) {
    Write-Host "ERROR: ${drive}: has only about $freeGb GB free. Run .\scripts\free-d-drive-for-android.ps1" -ForegroundColor Red
    exit 1
}
if ($freeGb -lt 2) {
    Write-Host "Warning: ${drive}: has only ${freeGb} GB free." -ForegroundColor Yellow
}

$env:Path = "C:\Users\hp\AppData\Local\flutter\bin;$env:ANDROID_HOME\platform-tools;$env:JAVA_HOME\bin;" + $env:Path

if ($DeviceId -match "^emulator-\d+$") {
    $adbOut = & adb devices 2>&1 | Out-String
    $pattern = [regex]::Escape($DeviceId) + '\s+device'
    if ($adbOut -notmatch $pattern) {
        Write-Host "ADB does not show $DeviceId as ready. Start the emulator first (AVD Manager Play or .\scripts\start-emulator.ps1 flutter_emulator -Detach)." -ForegroundColor Red
        Write-Host $adbOut.TrimEnd()
        exit 1
    }
}

Write-Host "GRADLE_USER_HOME = $env:GRADLE_USER_HOME" -ForegroundColor Cyan
if ($DeviceId) {
    flutter run -d $DeviceId
} else {
    flutter run
}
