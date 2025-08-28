plugins {
    id("com.android.application")
    id("com.google.gms.google-services") // Firebase services
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.whatsapp_clone"
    compileSdk = 36 // or use flutter.compileSdkVersion if you want Flutter to manage

    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.example.whatsapp_clone"
        minSdk = flutter.minSdkVersion  // ✅ fixed
        targetSdk = 36                  // or flutter.targetSdkVersion
        versionCode = 1                 // or flutter.versionCode
        versionName = "1.0.0"           // or flutter.versionName
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

            isMinifyEnabled = true   // ✅ Kotlin DSL property
            isShrinkResources = true // ✅ Kotlin DSL property

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
