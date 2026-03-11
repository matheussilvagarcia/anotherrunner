plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

import java.util.Properties
        import java.io.FileInputStream

        android {
            namespace = "com.matheussilvagarcia.anotherrunner"
            compileSdk = flutter.compileSdkVersion
            ndkVersion = flutter.ndkVersion

            compileOptions {
                sourceCompatibility = JavaVersion.VERSION_17
                targetCompatibility = JavaVersion.VERSION_17
            }

            buildFeatures {
                buildConfig = true
            }

            kotlinOptions {
                jvmTarget = JavaVersion.VERSION_17.toString()
            }

            defaultConfig {
                applicationId = "com.matheussilvagarcia.anotherrunner"
                minSdk = flutter.minSdkVersion
                targetSdk = flutter.targetSdkVersion
                versionCode = flutter.versionCode
                versionName = flutter.versionName

                val properties = Properties()
                val propertiesFile = project.rootProject.file("local.properties")
                if (propertiesFile.exists()) {
                    properties.load(FileInputStream(propertiesFile))
                }
                manifestPlaceholders["MAPS_API_KEY"] = properties.getProperty("MAPS_API_KEY") ?: ""
            }

            buildTypes {
                release {
                    signingConfig = signingConfigs.getByName("debug")
                }
            }
        }

flutter {
    source = "../.."
}