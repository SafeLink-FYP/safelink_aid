# safelink_aid

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Maps setup

The request detail screen embeds a Google Map showing the assigned case's
location. The API key is **never committed** — each developer/CI machine
provides it locally.

### Android

1. Open `android/local.properties` (gitignored).
2. Add the line:

   ```
   MAPS_API_KEY=YOUR_ANDROID_KEY
   ```

3. Rebuild. The key is read by `android/app/build.gradle.kts` and injected
   into `AndroidManifest.xml` as a manifest placeholder
   (`com.google.android.geo.API_KEY`).
4. If `MAPS_API_KEY` is missing, the build still succeeds but the map
   surface will fail to render. No crash.

### iOS

1. Copy `ios/Config/Secrets.xcconfig.example` to `ios/Config/Secrets.xcconfig`
   (the latter is gitignored).
2. Edit it and set the iOS key:

   ```
   MAPS_API_KEY = YOUR_IOS_KEY
   ```

3. In Xcode, set the Debug and Release configurations of the Runner target
   to inherit from `Config/Secrets.xcconfig` (Project → Info → Configurations).
   This is a one-time manual step per workstation.
4. `Info.plist` references `$(MAPS_API_KEY)` under the `GMSApiKey` entry,
   and `AppDelegate.swift` reads it via `Bundle.main`.

### Google Cloud restrictions

Apply both restrictions in Cloud Console for each key:

- **Application restriction**:
  - Android key → restrict to package `com.example.safelink_aid` and the
    SHA-1 fingerprint of your debug/release signing cert.
  - iOS key → restrict to bundle id `com.example.safelinkAid` (or whatever
    `PRODUCT_BUNDLE_IDENTIFIER` resolves to).
- **API restriction**:
  - Android key → "Maps SDK for Android" only.
  - iOS key → "Maps SDK for iOS" only.

Never put either key in source files, comments, dialog messages, or test
fixtures.
