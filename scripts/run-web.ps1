# Run Weather App on web (good for server / CI / quick demo)
# Usage: .\scripts\run-web.ps1
#        .\scripts\run-web.ps1 -Port 8080

param([int]$Port = 8080)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $ProjectRoot

$flutter = if (Get-Command flutter -ErrorAction SilentlyContinue) { "flutter" }
           elseif (Test-Path "$env:LOCALAPPDATA\flutter\bin\flutter.bat") {
               "$env:LOCALAPPDATA\flutter\bin\flutter.bat"
           }
           elseif (Test-Path "C:\flutter\bin\flutter.bat") { "C:\flutter\bin\flutter.bat" }
           else { $null }

if (-not $flutter) {
    Write-Error "Flutter not found. Run .\scripts\setup.ps1 after installing Flutter."
}

if (-not (Test-Path "web")) {
    & $flutter create . --platforms=web
}

Write-Host "Starting web server at http://localhost:$Port" -ForegroundColor Green
& $flutter run -d web-server --web-hostname=0.0.0.0 --web-port=$Port
