plugins {
    id("com.android.application")
    id("com.google.gms.google-services") // FlutterFire
      id("org.jetbrains.kotlin.plugin.compose") // ✅ required for Glance
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.eibs.agriot"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        //  kotlinCompilerExtensionVersion = "1.1.0-beta03"
    }
    buildFeatures {
        compose = true
        viewBinding = true
         buildConfig = true
    }

   

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.eibs.agriot"
    //    minSdk= flutter.minSdkVersion
         minSdk =flutter.minSdkVersion
        // minSdk =23 
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            storeFile = file("C:/Users/IT/Documents/Bala Files/agriot_mobile_app/agriot-api.txt")
            storePassword = "EIBS@123"
            keyAlias = "myreleasekey"
            keyPassword = "EIBS@123"
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation("androidx.window:window:1.0.0")
    implementation("androidx.window:window-java:1.0.0")
     // For Glance support
    implementation("androidx.glance:glance:1.1.0")
    
    // For AppWidgets support
    implementation("androidx.glance:glance-appwidget:1.1.0")

    
    implementation ("androidx.work:work-runtime-ktx:2.7.1")
    implementation("io.coil-kt:coil:2.2.1")
}

flutter {
    source = "../.."
}
