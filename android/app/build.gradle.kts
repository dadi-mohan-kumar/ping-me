plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android") // Move Kotlin directly under the Android application plugin
    
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    
    // The Flutter Gradle Plugin is correctly kept at the very bottom
    id("dev.flutter.flutter-gradle-plugin")
}
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}

android {
    namespace = "com.example.pingme"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    // FIXED: Merged into a single correct Java 17 configuration block
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.pingme"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
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