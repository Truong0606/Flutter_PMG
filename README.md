# first_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
# PES Mobile (Flutter)

Flutter client for PES — includes authentication, parent/class features, student/admission flows, and profile pages. The app uses BLoC for state management and SharedPreferences for local storage.

## Mobile Installation

See the full step-by-step guide in `docs/Mobile_Installation.md`.

## Package diagram (mobile)

Editable sources are provided in:

- Mermaid: `docs/Package_Diagram_Mobile.mmd` (open in https://mermaid.live to export PNG/SVG)
- PlantUML: `docs/Package_Diagram_Mobile.puml` (render at https://www.plantuml.com/plantuml)

These diagrams reflect layered modules: `core` (config/network/services), `config` (DI), `features/*` with `data` → `domain` → `presentation`, plus `android/`, `ios/` and `assets/`.

## Tech stack

- Flutter (stable, Dart >= 3.9.2)
- BLoC, GetIt DI
- Packages: `http`, `image_picker`, `url_launcher`, `webview_flutter`, `shared_preferences`

## Quick start

```powershell
cd Flutter_PMG
flutter pub get
flutter run
```

For custom environments and API endpoints, pass `--dart-define` flags as described in the Mobile Installation guide.
