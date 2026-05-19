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
3. Click **▶ Play** to start emulator  
4. Terminal:

```powershell
flutter devices
flutter run
```

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

**PowerShell:**

```powershell
.\scripts\run-android.ps1
```

**Git Bash:**

```bash
source scripts/flutter-env.sh
flutter pub get
flutter run
```

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

---

## What works RIGHT NOW (without Android Studio)

Only **web** in browser:

```powershell
$env:Path = "$env:LOCALAPPDATA\flutter\bin;" + $env:Path
cd d:\react-native-project\flutter-app
flutter run -d chrome
```

That is **not** the same as installing on a phone — for the real mobile app, complete **Part 2** first.
