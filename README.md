# Flutter Weather App

A beginner-friendly **Weather App** built with Flutter core concepts — mapped from React Native patterns.

| React Native            | Flutter (this project)                    |
| ----------------------- | ----------------------------------------- |
| JavaScript / TypeScript | **Dart** (`lib/`)                         |
| JSX                     | **Widgets** (`StatelessWidget`, etc.)     |
| CSS Styling             | **Widget styling** (`BoxDecoration`, theme) |
| Flexbox                 | **Row / Column / Flex**                   |
| React Components        | **Stateless & Stateful Widgets**          |
| Hooks                   | **State + `initState`**                     |
| Redux / Context         | **Provider** (`WeatherProvider`)          |
| fetch / axios           | **`http` + `WeatherService`**             |
| Hot Reload              | **Hot Reload** (`r` in terminal)          |

Uses the free [Open-Meteo](https://open-meteo.com/) API — **no API key** required.

## Project structure

```
lib/
  main.dart              # Entry + Provider root
  app.dart               # MaterialApp
  models/weather.dart    # Data types
  services/            # API calls
  providers/             # App state (ChangeNotifier)
  screens/               # Full pages (StatefulWidget)
  widgets/               # Reusable UI pieces
  utils/                 # Helpers (weather codes)
```

## Prerequisites

1. Install [Flutter SDK](https://docs.flutter.dev/get-started/install/windows)
2. Enable web: `flutter config --enable-web`
3. (Optional) Android Studio / VS Code + Flutter extension

Quick install on Windows (or clone SDK):

```powershell
git clone -b stable https://github.com/flutter/flutter.git $env:LOCALAPPDATA\flutter
# Add to PATH: %LOCALAPPDATA%\flutter\bin
```

Restart the terminal, then verify:

```powershell
flutter doctor
```

## Setup & run

From `flutter-app` folder:

```powershell
.\scripts\setup.ps1
```

### Run in browser (easiest — “on server”)

Binds to all interfaces so you can open from another machine on the LAN:

```powershell
.\scripts\run-web.ps1
# Custom port:
.\scripts\run-web.ps1 -Port 3000
```

Open: `http://localhost:8080` (or your port).

### Run on Chrome / emulator / device

```powershell
.\scripts\run.ps1
# Specific device:
flutter devices
.\scripts\run.ps1 -Device chrome
```

### Manual commands

```powershell
flutter create . --project-name weather_app   # first time only
flutter pub get
flutter run -d web-server --web-hostname=0.0.0.0 --web-port=8080
```

## Features

- Search any city worldwide
- Current temperature, humidity, wind
- 7-day forecast
- Pull-to-refresh
- Loading and error states

## Hot reload

While `flutter run` is active:

- `r` — hot reload  
- `R` — hot restart  
- `q` — quit  

## Run on mobile (Android / iPhone)

Flutter is **one codebase** for Android and iOS. Your PC currently has **no Android SDK** (`flutter doctor` shows SDK missing). Follow the steps below once.

### Android (Windows) — recommended

#### Step 1: Install Android Studio

1. Download [Android Studio](https://developer.android.com/studio)
2. Run installer → include **Android SDK**, **Android SDK Platform**, **Android Virtual Device**
3. Open Android Studio → **More Actions** → **SDK Manager**
   - **SDK Platforms**: check latest (e.g. Android 15)
   - **SDK Tools**: Android SDK Build-Tools, Platform-Tools, Emulator

#### Step 2: Point Flutter to the SDK

In PowerShell (adjust path if your SDK is elsewhere):

```powershell
$env:ANDROID_HOME = "$env:LOCALAPPDATA\Android\Sdk"
[Environment]::SetEnvironmentVariable("ANDROID_HOME", $env:ANDROID_HOME, "User")
$env:Path = "$env:ANDROID_HOME\platform-tools;$env:LOCALAPPDATA\flutter\bin;" + $env:Path
flutter doctor --android-licenses   # type y for each prompt
flutter doctor
```

You should see a green check for **Android toolchain**.

#### Step 3A: Run on a real Android phone

1. On the phone: **Settings → About phone** → tap **Build number** 7 times (enables Developer options)
2. **Settings → Developer options** → enable **USB debugging**
3. Connect phone with USB cable
4. On the phone, allow **USB debugging** when prompted
5. Verify:

```powershell
cd d:\react-native-project\flutter-app
flutter devices
```

You should see something like `sdk gphone64` or your phone model.

6. Run:

```powershell
.\scripts\run-android.ps1
# or
flutter run
```

First build can take **5–15 minutes**; later runs use hot reload (`r`).

#### Step 3B: Run on Android emulator (no phone)

1. Android Studio → **Device Manager** → **Create device** (e.g. Pixel 7) → download a system image → **Finish**
2. Start the emulator (Play button)
3. In terminal:

```powershell
flutter devices
flutter run
```

#### Release APK (install on any Android phone)

```powershell
flutter build apk --release
```

APK path: `build\app\outputs\flutter-apk\app-release.apk` — copy to the phone and install (allow “Install unknown apps” if needed).

---

### iPhone (iOS)

**You need a Mac** with Xcode to build and run on iPhone or iOS Simulator. Flutter cannot compile iOS apps on Windows alone.

On a Mac:

```bash
cd flutter-app
flutter pub get
open -a Simulator
flutter run
```

For a physical iPhone: connect device, trust computer, open `ios/Runner.xcworkspace` in Xcode once to set signing team, then `flutter run`.

---

## Build for production (web)

```powershell
flutter build web
# Output: build/web/ — deploy to any static host (Nginx, Firebase, etc.)
```
