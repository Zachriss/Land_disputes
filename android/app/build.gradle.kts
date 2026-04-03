plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")

    // Apply the Google Services plugin to enable Firebase
    id("com.google.gms.google-services")
}

android {
    namespace = "com.thomas.land_disputes" // Your app namespace
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.thomas.land_disputes" // MUST match Firebase package name
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Signing with debug keys for now
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

// Add Firebase dependencies here
dependencies {
    // Firebase BoM to manage compatible versions
    implementation(platform("com.google.firebase:firebase-bom:34.11.0"))

    // Firebase libraries you need
    implementation("com.google.firebase:firebase-auth-ktx")       // For Authentication
    implementation("com.google.firebase:firebase-firestore-ktx")  // For Firestore Database
    implementation("com.google.firebase:firebase-storage-ktx")    // For File Storage
}

flutter {
    source = "../.."
}