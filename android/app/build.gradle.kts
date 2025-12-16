plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")  // Firebase - only once
}

android {
    namespace = "com.example.whatsapp_clone"
    compileSdk = 35  // Required by androidx.credentials and other dependencies
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.example.whatsapp_clone"
        minSdk = flutter.minSdkVersion  // Must be 21 or higher for Firebase Auth
        targetSdk = 34  // Keep targetSdk at 34 for stability
        versionCode = 1
        versionName = "1.0.0"
        multiDexEnabled = true  // Good for Firebase projects
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
            
            // Set to false for development, true for production
            isMinifyEnabled = false
            isShrinkResources = false
            
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

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
    implementation("com.google.firebase:firebase-auth")
}
