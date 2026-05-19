# Flutter Weather App — first-time setup (Windows)
# Run from project root: .\scripts\setup.ps1

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $ProjectRoot

function Find-Flutter {
    if (Get-Command flutter -ErrorAction SilentlyContinue) {
        return "flutter"
    }
    $paths = @(
        "$env:LOCALAPPDATA\flutter\bin\flutter.bat",
        "C:\flutter\bin\flutter.bat",
        "D:\flutter\bin\flutter.bat",
        "$env:USERPROFILE\flutter\bin\flutter.bat"
    )
    foreach ($p in $paths) {
        if (Test-Path $p) { return $p }
    }
    return $null
}

$flutter = Find-Flutter
if (-not $flutter) {
    Write-Host ""
    Write-Host "Flutter SDK not found." -ForegroundColor Yellow
    Write-Host "Install: https://docs.flutter.dev/get-started/install/windows" -ForegroundColor Cyan
    Write-Host "  Option A: winget install Google.Flutter" -ForegroundColor Gray
    Write-Host "  Option B: Download zip, extract to C:\flutter, add C:\flutter\bin to PATH" -ForegroundColor Gray
    Write-Host ""
    exit 1
}

Write-Host "Using Flutter: $flutter" -ForegroundColor Green

# Generate android/ios/web folders if missing
if (-not (Test-Path "android")) {
    Write-Host "Generating platform folders (flutter create)..." -ForegroundColor Cyan
    & $flutter create . --project-name weather_app
}

Write-Host "Fetching dependencies..." -ForegroundColor Cyan
& $flutter pub get

Write-Host "Running doctor (optional checks)..." -ForegroundColor Cyan
& $flutter doctor

Write-Host ""
Write-Host "Setup complete. Run the app:" -ForegroundColor Green
Write-Host "  .\scripts\run-web.ps1     # Browser / web server" -ForegroundColor White
Write-Host "  .\scripts\run.ps1         # Default device" -ForegroundColor White
