#!/usr/bin/env bash
# Source this before flutter commands in Git Bash:
#   source scripts/flutter-env.sh

export FLUTTER_ROOT="${FLUTTER_ROOT:-$LOCALAPPDATA/flutter}"
export ANDROID_HOME="${ANDROID_HOME:-$LOCALAPPDATA/Android/Sdk}"
export PATH="$FLUTTER_ROOT/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"

echo "Flutter: $(command -v flutter 2>/dev/null || echo 'NOT FOUND — install SDK to %LOCALAPPDATA%\\flutter')"
echo "ANDROID_HOME: $ANDROID_HOME"

if [ -d "$ANDROID_HOME" ]; then
  echo "Android SDK: OK"
else
  echo "Android SDK: NOT INSTALLED (required for phone/emulator)"
fi
