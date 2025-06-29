plugins {
    id("com.android.application")
    id("com.google.gms.google-services") // Firebase services
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.whatsapp_clone"
    compileSdk = 35 // or use flutter.compileSdkVersion if defined elsewhere

    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.example.whatsapp_clone"
        minSdk = 23
        targetSdk = 34 // or flutter.targetSdkVersion if defined
        versionCode = 1 // or flutter.versionCode if managed by Flutter
        versionName = "1.0.0" // or flutter.versionName
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    buildTypes {
    release {
        signingConfig = signingConfigs.getByName("debug")

        isMinifyEnabled = true // <- Required for shrinkResources
        isShrinkResources = true

        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )
    }
}

}

flutter {
    source = "../.."
}
