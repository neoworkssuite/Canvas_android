# NeoCanvas for Android tablets

NeoCanvas is an offline-first drawing and creative studio for Android tablets. It keeps artwork on the device unless the artist explicitly imports, exports, or shares a file; it has no account, network service, telemetry, or cloud-storage dependency.

## Modules

- `core` — document model, commands, history, and persistence contracts
- `brushes` — brush definitions, stroke sampling, and bundled brush packs
- `renderer` — tile raster engine, compositing, effects, and encoders
- `ui` — shared Compose editor workspace and tablet gestures
- `androidApp` — Android activity, input, local files, and resources

## Prerequisites

- JDK 17
- Android SDK with API 36
- Android Studio or the Android command-line tooling

## Verify

```powershell
./gradlew.bat :androidApp:testDebugUnitTest :androidApp:assembleDebug
```

The debug APK is written to `androidApp/build/outputs/apk/debug/`.

## Current product direction

This repository starts from NeoCanvas's iPad-parity shared editor. Android-specific work now focuses on physical-tablet stylus and gesture validation, Storage Access Framework and sharing integration, tablet windowing, performance, recovery, and accessibility.
