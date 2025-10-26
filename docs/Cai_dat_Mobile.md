# Hướng dẫn cài đặt Mobile — PES Mobile (Flutter)

Tài liệu này hướng dẫn cách cài đặt và chạy ứng dụng Flutter cho Android và iOS. Nội dung ưu tiên cho Windows (Android); phần iOS áp dụng khi dùng macOS.

## 1) Yêu cầu môi trường

- Flutter (stable) đi kèm Dart >= 3.9.2
- Android Studio (SDK Platform + Platform Tools)
- Xcode + CocoaPods (chỉ khi build iOS trên macOS)
- Thiết bị để chạy:
  - Android: AVD (API 33+ khuyến nghị) hoặc điện thoại thật bật USB debugging
  - iOS: Simulator hoặc iPhone thật (chỉ macOS)

Kiểm tra môi trường:

```powershell
flutter --version
flutter doctor
```

## 2) Thư mục & tệp quan trọng

Mã nguồn mobile nằm trong `Flutter_PMG/`:

- `pubspec.yaml` — danh sách package & assets
- `lib/core/config/app_config.dart` — cấu hình môi trường; base URL API (có thể override bằng `--dart-define`)
- `android/app/build.gradle.kts`, `android/app/src/main/AndroidManifest.xml` — cấu hình Android & permissions
- `ios/Runner/Info.plist` — cấu hình/permissions cho iOS
- `lib/main.dart` — entry point, routes, BLoC

Các package chính: `http`, `webview_flutter`, `url_launcher`, `image_picker`, `shared_preferences`, `flutter_bloc`, `get_it`.

## 3) Tải dependencies

Từ thư mục gốc repo, vào mobile app và cài package:

```powershell
cd Flutter_PMG
flutter pub get
```

## 4) Cấu hình môi trường (API)

Mặc định app đã trỏ sẵn tới các API Azure trong `AppConfig`. Bạn có thể chạy ngay hoặc truyền tham số để override khi chạy.

Các `--dart-define` hỗ trợ:

- `FLUTTER_ENV` — `development` | `production` (mặc định `production`)
- `API_BASE_URL` — URL base của Auth service
- `PARENT_API_BASE_URL` — URL base của Parent service
- `CLASS_API_BASE_URL` — URL base của Class service
- `CLOUDINARY_CLOUD_NAME`, `CLOUDINARY_UPLOAD_PRESET` — cấu hình media upload

Ví dụ (chạy môi trường development và custom endpoint):

```powershell
flutter run `
  --dart-define=FLUTTER_ENV=development `
  --dart-define=API_BASE_URL=https://your-host/auth-api/api `
  --dart-define=PARENT_API_BASE_URL=https://your-host/parent-api/api `
  --dart-define=CLASS_API_BASE_URL=https://your-host/class-api/api
```

Lưu ý: Dùng dấu backtick (`) để xuống dòng trong PowerShell; hoặc truyền trên một dòng.

## 5) Chạy trên Android

1. Mở AVD từ Android Studio hoặc cắm điện thoại thật (bật USB debugging)
2. Chạy lệnh:

```powershell
flutter devices
flutter run -d <device-id>
```

Build APK release:

```powershell
flutter build apk --release
```

Build App Bundle:

```powershell
flutter build appbundle --release
```

Quyền Android đã có sẵn trong `AndroidManifest.xml`:

- `INTERNET`, `ACCESS_NETWORK_STATE`
- `queries` cho http/https (phục vụ `url_launcher`)

## 6) Chạy trên iOS (chỉ macOS)

Cài pods và chạy:

```bash
cd ios
pod install
cd ..
flutter run -d <ios-device-id>
```

Build IPA release:

```bash
flutter build ipa --release
```

Permission cần thêm trong `ios/Runner/Info.plist` nếu dùng camera/thư viện ảnh (do `image_picker`):

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Ứng dụng cần truy cập thư viện ảnh để chọn hình.</string>
<key>NSCameraUsageDescription</key>
<string>Ứng dụng cần truy cập camera để chụp ảnh.</string>
```

## 7) Troubleshooting

- JDK/Gradle: dự án dùng Java 11. Hãy đặt JDK của Android Studio về 11 nếu build lỗi do version.
- Android licenses: chạy `flutter doctor --android-licenses` nếu thiếu.
- Lỗi mạng/Connection refused: kiểm tra backend có chạy và thiết bị/emulator có truy cập được không.
- iOS thiếu quyền: bổ sung các khóa `NS*UsageDescription` như trên.
- WebView/URL launcher không mở: kiểm tra kết nối mạng emulator và có sẵn trình duyệt.

## 8) Lệnh nhanh (PowerShell)

```powershell
cd Flutter_PMG
flutter pub get
flutter devices
flutter run
```

Hoàn tất! Nếu cần tùy biến môi trường nâng cao, xem thêm ở `lib/core/config/app_config.dart` và các module trong `lib/features/`.
