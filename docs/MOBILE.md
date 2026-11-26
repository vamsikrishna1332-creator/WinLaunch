# LaunchDesk Android (experimental)

This Android build lives **in the same WinLaunch / LaunchDesk repository** and
uses the **same Flutter models, Riverpod providers, and local SQLite database
schema** as the Windows project. It does not change the Windows entry point.

## UI and features

- Same dark navy / purple LaunchDesk design, responsive to phone screens.
- Bottom navigation (Home, Tasks, Apps, Optimize) and a complete navigation
  drawer for Schedule, Notes, Focus Timer, Habits, Journal, Settings, ChatGPT,
  and in-app Widgets.
- Local SQLite persistence for tasks, notes, schedules, and shortcuts.
- Browser shortcuts plus selection of **launchable installed Android apps**.
- Live battery/network stats, memory and CPU estimates when exposed by Android,
  and user-confirmed cleanup of **LaunchDesk's own temporary cache**.
- Official Android settings shortcuts for battery saver, Wi-Fi, and this app.

## Known limitations

- It **does not** overclock a phone, force Roblox FPS, shut down other apps,
  delete another app's cache, or bypass Android security restrictions.
- Android may restrict reading /proc/stat and memory statistics; those numbers
  display *Unavailable* instead of fabricated values.
- Internet connection checks indicate a network connection, not verified access.
- The current Focus Timer only runs while the app is active; scheduled Android
  notification/background alarm integration is not implemented.
- Home-screen widgets and secure local password login are **not yet ported**;
  the mobile build opens its own local workspace without Windows auth gate.
- Android app enumeration is limited to applications with launcher activities;
  there is **no** QUERY_ALL_PACKAGES permission.
- Windows and Android each have independent on-device data. There is **no
  automatic synchronization** and no credential collection.

## Build Android

For a clean checkout, Flutter SDK and an Android SDK are required:

    flutter pub get
    flutter create --platforms=android --org com.draevix .
    flutter build apk --release --target lib/main_mobile.dart

To test with a connected phone:

    flutter run --target lib/main_mobile.dart

The APK appears at:

    build/app/outputs/flutter-apk/app-release.apk

Alternatively, open the GitHub Actions **LaunchDesk Android APK** workflow,
wait for a successful run, and download its **LaunchDesk-Android-APK**
artifact. Extract the archive to access the APK, and install only on a device
you control. APKs from this prototype are not Play Store signed.

The existing Windows release continues to use:

    flutter build windows --release --target lib/main.dart

The mobile feature branch is based on the unmerged redesign branch
feat/pixel-perfect-launchdesk. Merge the redesign before trying to bring
this Android feature into main.
