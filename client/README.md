# Duanju Flutter Client

Flutter client scaffold for the short-drama instant interaction MVP.

## MVP Scope

- Drama list with multiple candidate dramas.
- Player page with basic play/pause and progress controls.
- Highlight timeline that can trigger interaction overlays.
- Mock repository that can later be replaced by a local server or cloud API.

## Structure

```text
lib/
  app/                         App entry and composition
  core/config/                 Runtime configuration
  core/theme/                  Visual theme
  features/drama/              Drama list, models, repository
  features/player/             Player and highlight interactions
```

## Run

Flutter SDK is installed at:

```text
C:\Users\niuwe\flutter
```

Run from this directory:

```powershell
cd client
flutter pub get
flutter run
```

If a newly opened terminal cannot find `flutter`, restart the terminal or use:

```powershell
C:\Users\niuwe\flutter\bin\flutter.bat run
```

## Verification

These commands passed locally:

```powershell
flutter pub get
flutter analyze
flutter test
flutter build windows
```
