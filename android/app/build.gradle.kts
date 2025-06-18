import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val properties = Properties()
properties.load(project.rootProject.file("local.properties").inputStream())

android {
    namespace = "com.example.flutter_bloc_rxdart"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {

        applicationId = "com.example.flutter_bloc_rxdart"

        minSdk = 33
        targetSdk = 33
        versionCode = flutter.versionCode
        versionName = flutter.versionName

//        manifestPlaceholders["GOOGLE_MAP_API_KEY"] = project.properties["GOOGLE_MAP_API_KEY"].toString()

                manifestPlaceholders["GOOGLE_MAP_API_KEY"] = "AIzaSyCFnCqp1Y9Wy8FINjFUHDvd_BOg27vL4vI"
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
