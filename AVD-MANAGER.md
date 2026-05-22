# AVD Manager extension — how it works + make it run successfully

This project uses the **AVD Manager** extension (`toroxx.vscode-avdmanager`). Your screenshot shows it is enabled: **Android Virtual Device**, **SDK Platforms**, **SDK Tools**, and **AVDManager** are checked — good.

## How it works (short)

1. **Workspace settings** (`.vscode/settings.json`) tell the extension where your **SDK** and **AVD folder** are. It then runs Google’s **`avdmanager`**, **`sdkmanager`**, and **`emulator`** from under that SDK.
2. **Android Virtual Device** — list/create/rename/delete AVDs; **Play** starts an emulator.
3. **SDK Platforms / SDK Tools** — install system images, build-tools, etc.; accept licenses.

Those tools need **Java**: they read **`JAVA_HOME`**.

## Critical fix on your PC (JAVA_HOME)

If `JAVA_HOME` points to a folder that **does not exist** (for example `C:\Program Files\Java\jdk-17`), **`avdmanager`** fails and lists stay empty or commands error out.

**Working JDK on your machine:** Android Studio’s JBR:

`C:\Program Files\Android\Android Studio\jbr`

Do **one** of the following:

### Option A — one-time script (recommended)

From PowerShell in the repo root:

```powershell
.\scripts\set-user-java-home-jbr.ps1
```

Then **fully quit Cursor** and reopen it (so the extension inherits the new `JAVA_HOME`).

### Option B — Windows UI

1. Win + R → `sysdm.cpl` → **Advanced** → **Environment Variables**
2. Under **User variables**, edit **JAVA_HOME** → set to  
   `C:\Program Files\Android\Android Studio\jbr`  
   (or remove JAVA_HOME if you only use Android Studio and let tools default — usually setting JBR explicitly is clearer.)

Restart Cursor after changing.

### Option C — integrated terminal only

`.vscode/settings.json` already sets **`terminal.integrated.env.windows`** so **terminals inside Cursor** use JBR. That **does not** always fix the extension’s own subprocesses — still fix **User JAVA_HOME** (A or B) if panels fail.

## After JAVA_HOME is correct

1. **Disk space:** Emulator + AVD files live on **D:**. If **D:** is nearly **empty** (~0 GB), the emulator will not start. Run from repo root: **`.\scripts\free-d-drive-for-android.ps1`** (or Cursor **Run Task → Android: Free space on D:**), then try again.

2. **Start AVD:** **Ctrl+Shift+P** → **Developer: Reload Window** (or restart Cursor).

3. Click **AVDManager** in the left activity bar.

4. Open **Android Virtual Device** → refresh if needed → **Play** on `flutter_emulator` (wait for **home screen**).

5. In a terminal: **`adb devices`** — you should see **`emulator-5554    device`**.

6. Run the app: **`.\run.ps1 -d emulator-5554`** or **`./run.sh -d emulator-5554`** (Git Bash).  
   Avoid **`flutter run`** with no **`-d`** — Flutter may offer **Windows**, which hits the **symlink / Developer Mode** error for plugin builds.

## More AVDs

Use **Create (+)** in the AVD panel, or Android Studio **Device Manager**. All AVDs under `D:\Android\avd` appear automatically. See **RUN-ON-PHONE.md** → *Multiple emulators*.

## Optional: Run and Debug icon

Your menu shows **Run and Debug** hidden — that only affects the **Flutter/Dart debug** button, not AVD Manager. You can check **Run and Debug** if you want **F5** on `launch.json`.
