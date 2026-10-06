# TimeFlow Flutter application

This directory contains the Flutter application for TimeFlow, a local-first
work-time tracker for Android and iOS.

## Run locally

```sh
flutter pub get
flutter run
```

## Verify the application

```sh
dart format --output=none --set-exit-if-changed .
dart analyze
flutter test
flutter build apk --debug
```

The on-device integration tests require a connected Android or iOS device or
simulator:

```sh
flutter test integration_test -d <device-id>
```

The application stores work sessions locally using Drift/SQLite. The live timer
is derived from persisted UTC timestamps, so it can recover after an app kill,
phone lock, or device restart.
