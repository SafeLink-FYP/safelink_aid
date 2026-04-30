plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Extract the Maps API key from lib/core/secrets/app_secrets.dart so the
// secret lives in one (gitignored) place. Compile-time read only — falls back
// to empty when the file or constant is missing so the build never crashes.
val appSecretsFile =
    rootProject.file("../lib/core/secrets/app_secrets.dart")
val mapsApiKey: String = if (appSecretsFile.exists()) {
    Regex("""mapsApiKey\s*=\s*['"]([^'"]*)['"]""")
        .find(appSecretsFile.readText())
        ?.groupValues?.get(1)
        ?: ""
} else {
    ""
}

android {
    namespace = "com.example.safelink_aid"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlin {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11)
        }
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.safelink_aid"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["MAPS_API_KEY"] = mapsApiKey
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
