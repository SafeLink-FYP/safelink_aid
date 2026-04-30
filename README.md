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

## Backend schema

This app consumes Supabase at runtime (auth + Postgres). The canonical schema
and migrations live in a separate repo / project-root `supabase/` folder, not
in this repo. Run `supabase` CLI commands (`supabase migration new`,
`supabase db reset`, `supabase db diff`) from the schema folder, not from here.

## Maps setup

The request detail screen embeds a Google Map showing the assigned case's
location. The API key is **never committed** — each developer/CI machine
provides it locally.

### Android

1. Copy the template:

   ```
   cp android/key.properties.example android/key.properties
   ```

   `android/key.properties` is gitignored.

2. Edit it and replace the placeholder with your key:

   ```
   MAPS_API_KEY=AIzaSy...
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
