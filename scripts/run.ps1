# Run on default device (emulator, Chrome, or connected phone)
param([string]$Device = "")

$ProjectRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $ProjectRoot

$flutter = if (Get-Command flutter -ErrorAction SilentlyContinue) { "flutter" }
           else { "C:\flutter\bin\flutter.bat" }

if (-not (Get-Command $flutter -ErrorAction SilentlyContinue) -and -not (Test-Path $flutter)) {
    Write-Error "Flutter not found. Run .\scripts\setup.ps1"
}

if (-not (Test-Path "android")) {
    & $flutter create . --project-name weather_app
}

& $flutter pub get
if ($Device) {
    & $flutter run -d $Device
} else {
    & $flutter run
}
