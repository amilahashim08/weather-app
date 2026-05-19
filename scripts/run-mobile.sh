#!/usr/bin/env bash
# Run on Android from Git Bash — after Android Studio is installed
set -e
cd "$(dirname "$0")/.."
source scripts/flutter-env.sh

if ! command -v flutter >/dev/null 2>&1; then
  echo "ERROR: Flutter not found. Install: https://docs.flutter.dev/get-started/install/windows"
  exit 1
fi

if [ ! -d "$ANDROID_HOME" ]; then
  echo ""
  echo "ERROR: Android SDK not installed."
  echo "  1. Install Android Studio: https://developer.android.com/studio"
  echo "  2. Open SDK Manager and install SDK + Platform-Tools"
  echo "  3. Run: flutter doctor --android-licenses"
  echo ""
  echo "See RUN-ON-PHONE.md for full guide."
  exit 1
fi

flutter pub get
echo ""
echo "Connected devices:"
flutter devices
echo ""

if ! flutter devices 2>&1 | grep -qi android; then
  echo "No Android phone/emulator found."
  echo "  - Start an emulator in Android Studio Device Manager, OR"
  echo "  - Connect phone with USB debugging enabled"
  exit 1
fi

echo "Building and launching on Android (first time may take 10+ min)..."
flutter run
