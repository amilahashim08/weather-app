# Fixes AVD Manager / sdkmanager / avdmanager failures when JAVA_HOME points to a missing JDK.
# Sets your *User* JAVA_HOME to Android Studio's bundled JDK (JBR). Restart Cursor after running.
#
#   powershell -ExecutionPolicy Bypass -File .\scripts\set-user-java-home-jbr.ps1

$ErrorActionPreference = "Stop"
$jbr = "C:\Program Files\Android\Android Studio\jbr"
if (-not (Test-Path -LiteralPath "$jbr\bin\java.exe")) {
    Write-Error "Android Studio JBR not found at: $jbr — install Android Studio or edit this script."
    exit 1
}

$current = [Environment]::GetEnvironmentVariable("JAVA_HOME", "User")
Write-Host "Previous User JAVA_HOME: $(if ($current) { $current } else { '(not set)' })" -ForegroundColor Gray
[Environment]::SetEnvironmentVariable("JAVA_HOME", $jbr, "User")
Write-Host "User JAVA_HOME is now: $jbr" -ForegroundColor Green
Write-Host ""
Write-Host "Quit Cursor completely and open it again so the AVD Manager extension sees the new JAVA_HOME." -ForegroundColor Cyan
