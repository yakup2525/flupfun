import java.io.FileInputStream
import java.util.Properties
import java.util.Base64

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    FileInputStream(keystorePropertiesFile).use { keystoreProperties.load(it) }
}


val adDefines = (project.findProperty("dart-defines") as String?).orEmpty()
    .split(",").filter { it.isNotBlank() }.associate {
        val pair = String(Base64.getDecoder().decode(it)).split("=", limit = 2)
        pair[0] to pair.getOrElse(1) { "" }
    }
val isProductionBuild = gradle.startParameter.taskNames.any {
    it.contains("Release", ignoreCase = true)
}
val productionAppId = adDefines["ADMOB_APP_ID"].orEmpty()
if (isProductionBuild) {
    require(Regex("ca-app-pub-[0-9]{16}~[0-9]{10}").matches(productionAppId) &&
        !productionAppId.contains("3940256099942544")) { "Release requires the real Flup Fun ADMOB_APP_ID." }
    val unit = adDefines["ADMOB_INTERSTITIAL_ID"].orEmpty()
    require(Regex("ca-app-pub-[0-9]{16}/[0-9]{10}").matches(unit) &&
        !unit.contains("3940256099942544")) { "Release requires the real Flup Fun ADMOB_INTERSTITIAL_ID." }
    require(adDefines["ADS_AUDIENCE"] == "children") {
        "Flup Fun includes children: release must use ADS_AUDIENCE=children."
    }
}

android {
    namespace = "com.kurtizi.flupfun"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.kurtizi.flupfun"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
        manifestPlaceholders["admobAppId"] = if (isProductionBuild) productionAppId
            else "ca-app-pub-3940256099942544~3347511713"

        ndk {
            debugSymbolLevel = "FULL"
        }
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = (keystoreProperties["storeFile"] as String?)?.let(::file)
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
