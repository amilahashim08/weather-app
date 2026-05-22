#!/usr/bin/env bash
# Run the app from Git Bash (MINGW64). Do NOT use .\run.ps1 here — that is PowerShell-only.
#
#   ./run.sh
#   ./run.sh -d emulator-5554
#
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PS_SCRIPT="$HERE/run.ps1"
if command -v cygpath >/dev/null 2>&1; then
  PS_SCRIPT="$(cygpath -w "$PS_SCRIPT")"
fi
exec powershell.exe -ExecutionPolicy Bypass -NoProfile -File "$PS_SCRIPT" "$@"
