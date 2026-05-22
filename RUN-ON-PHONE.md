# Run Weather App on Your Phone (step-by-step)

This is a **Flutter** app — not React Native. Do **not** use `npm install`.

You are on **Windows**. To run on a **real Android phone** or **emulator**, you need **2 things**:

1. Flutter in your terminal PATH  
2. Android Studio + Android SDK  

---

## Part 1 — Fix “flutter: command not found”

Flutter is installed at: `C:\Users\hp\AppData\Local\flutter`

### Git Bash (what you use now)

Every new terminal session, run from the project folder:

```bash
cd /d/react-native-project/flutter-app
source scripts/flutter-env.sh
flutter --version
```

### PowerShell (recommended for first setup)

```powershell
$env:Path = "$env:LOCALAPPDATA\flutter\bin;" + $env:Path
flutter --version
```

### Permanent PATH (do once)

1. Press **Win + R** → type `sysdm.cpl` → Enter  
2. **Advanced** → **Environment Variables**  
3. Under **User variables** → **Path** → **Edit** → **New**  
4. Add: `C:\Users\hp\AppData\Local\flutter\bin`  
5. OK → **restart terminal**  

---

## Part 2 — Install Android (required for mobile)

Your PC has `ANDROID_HOME` set but the SDK folder **does not exist yet**.

### Install Android Studio

1. Download: https://developer.android.com/studio  
2. Run installer → keep defaults (SDK, emulator)  
3. Open Android Studio → **More Actions** → **SDK Manager**  
   - **SDK Platforms**: Android 14 or 15 ✓  
   - **SDK Tools**: Platform-Tools, Build-Tools, Emulator ✓ → Apply  

### Accept licenses

**PowerShell:**

```powershell
$env:ANDROID_HOME = "$env:LOCALAPPDATA\Android\Sdk"
$env:Path = "$env:ANDROID_HOME\platform-tools;$env:LOCALAPPDATA\flutter\bin;" + $env:Path
flutter doctor --android-licenses
flutter doctor
```

Wait until you see: `[√] Android toolchain`

---

## Part 3 — Run on a REAL phone (USB)

### On your Android phone

1. **Settings → About phone** → tap **Build number** 7 times  
2. **Settings → Developer options** → turn on **USB debugging**  
3. Connect phone to PC with USB cable  
4. On phone: tap **Allow** when asked about USB debugging  

### On PC

```powershell
cd d:\react-native-project\flutter-app
$env:Path = "$env:LOCALAPPDATA\flutter\bin;$env:LOCALAPPDATA\Android\Sdk\platform-tools;" + $env:Path
flutter devices
```

You must see a line with **android** (your phone name), for example:

```
SM G991B (mobile) • R58N... • android-arm64 • Android 14
```

Then run:

```powershell
flutter pub get
flutter run
```

- First build: **5–15 minutes** — normal  
- App opens on the phone automatically  
- In terminal: press **`r`** = hot reload, **`q`** = quit  

---

## Part 4 — Run on emulator (no phone)

1. Android Studio → **Device Manager** (phone icon on right)  
2. **Create device** → Pixel 7 → download system image → Finish  
3. Click **▶ Play** to start emulator — **wait until the home screen appears**  
4. If the emulator says **“not enough disk space”**, free space on **D:** (e.g. delete `D:\Android\avd\<your_avd>.avd\snapshots` — first boot will be slower)  
5. Terminal (use the script so Gradle stays on **E:**):

```powershell
cd d:\react-native-project\weather-app
flutter devices
.\run.ps1 -d emulator-5554
```

If `flutter run` only lists **Windows / Chrome**, the emulator is **not running** — start it in Device Manager first.

---

## Part 5 — Install APK without USB (share to any phone)

After Android SDK is installed:

```powershell
cd d:\react-native-project\flutter-app
flutter build apk --release
```

Copy this file to your phone and open it:

`build\app\outputs\flutter-apk\app-release.apk`

On phone: allow **Install from unknown sources** if asked.

---

## Quick scripts (after Android SDK is installed)

**PowerShell (recommended — sets Gradle/cache paths for low disk space on D:):**

```powershell
.\run.ps1
# or
.\run.ps1 -d emulator-5554
```

**Git Bash** (`MINGW64`): `.\run.ps1` does **not** work (that’s PowerShell syntax). Use either:

```bash
./run.sh
./run.sh -d emulator-5554
```

or:

```bash
powershell.exe -ExecutionPolicy Bypass -File ./run.ps1 -d emulator-5554
```

`source scripts/flutter-env.sh` alone does **not** set `GRADLE_USER_HOME` / `E:\` caches — prefer **`./run.sh`** or PowerShell **`run.ps1`** for Android builds on this project.

---

## AVD Manager extension (Cursor / VS Code)

## Run the Flutter app **after** starting an emulator (AVD Manager)

1. **Free space on D:** if the warning says D: is nearly full (~0 GB), run **`.\scripts\free-d-drive-for-android.ps1`** (or Cursor **Terminal → Run Task → Android: Free space on D:**). The emulator usually will not start otherwise.
2. **Cursor** → left bar **AVDManager** → **Android Virtual Device** → **Play** on `flutter_emulator` (or another AVD). Wait until the **home screen** appears (first boot can take a few minutes).
3. Confirm: **`adb devices`** shows `emulator-5554    device`.
4. Run the app: **`.\run.ps1 -d emulator-5554`** (PowerShell) or **`./run.sh -d emulator-5554`** (Git Bash).  
   Do **not** run plain **`flutter run`** and pick **Windows** unless you have **Developer Mode** + symlinks — that path fails for this project.

---

| Setting | Purpose |
|--------|---------|
| `avdmanager.sdkPath` | SDK root (`D:\Android\Sdk`) |
| `avdmanager.cmdVersion` | Command-line tools folder name (`latest`) |
| `avdmanager.avdHome` | Where AVD definitions live (`D:\Android\avd`) |
| `avdmanager.avdmanager` / `sdkManager` / `emulator` | Optional explicit paths (set for this PC) |

**Open the AVD Manager in Cursor (you do this in the UI — the AI cannot click it for you):**

1. Install **AVD Manager** (publisher **toroxx**) from the Extensions panel, or accept **“Install Recommended”** for this workspace.
2. Reload the window if asked (**Ctrl+Shift+P** → `Developer: Reload Window`).
3. In the **left activity bar**, click the **AVDManager** icon.  
   If you don’t see it: **Ctrl+Shift+P** → type **Open View** → pick **Android Virtual Device** or **AVDManager`.

**Extension commands (Command Palette, `Ctrl+Shift+P`):** e.g. **AVDManager: Accept All SDK Licenses**, **AVDManager: Update SDK Root Path**, refresh lists from the panel toolbar.

**Start the emulator without the extension:** **Terminal** → **Run Task…** → **Android: Start Emulator (flutter_emulator)**. Then `.\run.ps1` when `flutter devices` shows the emulator.

**SDK layout this extension expects** (your machine already matches if `verify` passes):

```text
<SDK>/cmdline-tools/latest/bin/avdmanager.bat
<SDK>/cmdline-tools/latest/bin/sdkmanager.bat
<SDK>/emulator/emulator.exe
```

Confirm from the project folder:

```powershell
.\scripts\verify-android-sdk-for-avd.ps1
```

**Licenses** (if builds/extension ask): **AVDManager: Accept All SDK Licenses**, or:

```powershell
& "D:\Android\Sdk\cmdline-tools\latest\bin\sdkmanager.bat" --licenses
```

If anything is missing: Android Studio → **SDK Manager** → **SDK Tools** → enable **Android SDK Command-line Tools (latest)**.

---

## iPhone?

**Cannot build iOS on Windows.** You need a Mac + Xcode, or build in the cloud.

---

## Troubleshooting

| Problem | Fix |
|--------|-----|
| `flutter: command not found` | Part 1 — add Flutter to PATH |
| `npm install` fails | Ignore — this is Flutter, use `flutter pub get` |
| No Android in `flutter devices` | Install Android Studio (Part 2) |
| Phone not listed | USB debugging on, try another cable, run `adb devices` |
| `Android SDK not found` | Install SDK via Android Studio SDK Manager |
| Build fails licenses | `flutter doctor --android-licenses` |
| `There is not enough space on the disk` | Free D: (delete old `build\`, `D:\gradle`). Use `.\run.ps1` — Gradle/cache go to **E:** |
| Emulator: “not enough disk space to run avd” | Free **D:** (AVD lives under `D:\Android\avd\`). You can delete `…\.avd\snapshots` to reclaim ~2 GB (cold boot next time) |
| `No such host is known` / Maven download errors | Check Wi‑Fi/mobile hotspot, wait and retry. Do not run two `flutter run` at once |
| Plain `flutter run` fails but SDK works | Always use `.\run.ps1` instead of bare `flutter run` on this PC |
| `No supported devices … emulator-5554` | Start the AVD first (AVD Manager **Play**), wait for home screen, run `adb devices`, then `.\run.ps1 -d emulator-5554` or `./run.sh -d emulator-5554` |
| D: almost **0 GB** free / emulator won’t start | Run `.\scripts\free-d-drive-for-android.ps1` or Cursor **Tasks → Android: Free space on D:** |
| Chose **Windows** in Flutter menu → **symlink** / “Building with plugins requires symlink support” | **Turn on Windows Developer Mode:** Win+R → `ms-settings:developers` → enable **Developer Mode** (reboot if needed). Or run **`.\scripts\enable-windows-developer-mode.ps1`** (opens settings; admin PowerShell can set registry — see script comments). **Or** skip Windows: always run **`.\run.ps1 -d emulator-5554`** / **`./run.sh -d emulator-5554`** so Flutter targets Android, not Windows. |

## What works RIGHT NOW (without Android Studio)

Only **web** in browser:

```powershell
$env:Path = "$env:LOCALAPPDATA\flutter\bin;" + $env:Path
cd d:\react-native-project\flutter-app
flutter run -d chrome
```

That is **not** the same as installing on a phone — for the real mobile app, complete **Part 2** first.
