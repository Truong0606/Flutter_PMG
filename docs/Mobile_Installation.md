# Mobile Installation — PES Mobile (Flutter)

This guide explains how to set up and run the Flutter mobile app on Android and iOS. It’s tailored for Windows developers (Android) and includes notes for macOS (iOS).

## 1) Requirements

- Flutter SDK (stable channel) with Dart >= 3.9.2
- Android Studio (SDK Platform + Platform Tools) for Android builds
- Xcode + CocoaPods (macOS only) for iOS builds
- A device or emulator:
  - Android: AVD (API 33+ recommended) or a physical phone with USB debugging
  - iOS: Simulator or a physical iPhone (macOS only)

Check your environment:

```powershell
flutter --version
flutter doctor
```

## 2) Project structure (mobile)

Main mobile app lives in `Flutter_PMG/` with notable files:

- `pubspec.yaml` — dependencies and assets
- `lib/core/config/app_config.dart` — environment + API base URLs (overridable via `--dart-define`)
- `android/app/build.gradle.kts` and `android/app/src/main/AndroidManifest.xml` — Android configuration and permissions
- `ios/Runner/Info.plist` — iOS configuration and permissions
- `lib/main.dart` — app entry (routes, DI wiring)

The app uses:

- HTTP client, WebView, URL launcher, Image picker
- SharedPreferences for local storage
- BLoC for state management and GetIt DI (lightweight)

## 3) Clone and install dependencies

From the repository root, switch into the mobile app folder and fetch packages:

```powershell
cd Flutter_PMG
flutter pub get
```

## 4) Configuration (APIs and environment)

Default API endpoints are preconfigured to the Azure Container Apps URLs in `AppConfig`. You can run without extra flags, or override at runtime.

Available dart-defines:

- `FLUTTER_ENV` — `development` or `production` (default: `production`)
- `API_BASE_URL` — Auth service base URL
- `PARENT_API_BASE_URL` — Parent service base URL
- `CLASS_API_BASE_URL` — Class service base URL
- `CLOUDINARY_CLOUD_NAME`, `CLOUDINARY_UPLOAD_PRESET` — media upload settings

Example (run in development mode with custom endpoints):

```powershell
flutter run `
  --dart-define=FLUTTER_ENV=development `
  --dart-define=API_BASE_URL=https://your-host/auth-api/api `
  --dart-define=PARENT_API_BASE_URL=https://your-host/parent-api/api `
  --dart-define=CLASS_API_BASE_URL=https://your-host/class-api/api
```

Tip: use backticks (`) as the line continuation in PowerShell; or pass on a single line.

## 5) Android — run and build

1. Start an emulator (AVD) from Android Studio or connect a real device (enable USB debugging).
2. From `Flutter_PMG/` run:

```powershell
flutter devices
flutter run -d <device-id>
```

To build a release APK (unsigned debug signing is used by default in Gradle; for publishing, set up your own keystore):

```powershell
flutter build apk --release
```

Optional: app bundle

```powershell
flutter build appbundle --release
```

### Android permissions already included

`android/app/src/main/AndroidManifest.xml` contains:

- `INTERNET` and `ACCESS_NETWORK_STATE`
- Query intents for `url_launcher` (http/https)

No extra action is required for typical development runs.

## 6) iOS — run and build (macOS only)

1. Open the iOS workspace once to install pods:

```bash
cd ios
pod install
cd ..
```

2. Run on simulator/device:

```bash
flutter run -d <ios-device-id>
```

3. Build release:

```bash
flutter build ipa --release
```

### iOS permissions you must add (Info.plist)

If you use image picking or the camera, add these keys to `ios/Runner/Info.plist`:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to your photo library to select images.</string>
<key>NSCameraUsageDescription</key>
<string>This app needs access to the camera to take pictures.</string>
```

## 7) Running with specific environment

Run with dev environment and default Azure endpoints:

```powershell
flutter run --dart-define=FLUTTER_ENV=development
```

Run with all custom endpoints:

```powershell
flutter run `
  --dart-define=FLUTTER_ENV=development `
  --dart-define=API_BASE_URL=https://dev.example.com/auth-api/api `
  --dart-define=PARENT_API_BASE_URL=https://dev.example.com/parent-api/api `
  --dart-define=CLASS_API_BASE_URL=https://dev.example.com/class-api/api
```

## 8) Troubleshooting

- Gradle/JDK: Project targets Java 11. If Android Studio uses a different JDK, set it to 11 in Gradle settings.
- Stuck at Installing build tools: ensure Android SDK Platform and Platform-Tools are installed; then `flutter doctor --android-licenses`.
- Network errors (Connection refused): make sure the backend services are reachable from your device/emulator.
- iOS build fails due to missing permissions: add the `NS*UsageDescription` keys shown above.
- WebView/URL launcher blocked on emulator: confirm an internet connection in the emulator and that a browser app exists for http/https intents.

## 9) Quick commands (PowerShell)

```powershell
# From repo root
cd Flutter_PMG
flutter pub get
flutter devices
flutter run
```

That’s it—your mobile app should be up and running. For advanced usage, see `lib/core/config/app_config.dart` and feature modules under `lib/features/`.
