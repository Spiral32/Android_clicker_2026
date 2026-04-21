plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.progsettouch.app"
    compileSdk = 34
    ndkVersion = flutter.ndkVersion

    defaultConfig {
        applicationId = "com.progsettouch.app"
        minSdk = 28
        targetSdk = 34
        versionCode = 1
        versionName = "0.1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    buildTypes {
        getByName("debug") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

tasks.matching { task ->
    task.name.contains("Debug") &&
        (task.name.startsWith("assemble") || task.name.startsWith("package"))
}.configureEach {
    finalizedBy("stageDebugApkForFlutterTool")
}

tasks.register("stageDebugApkForFlutterTool") {
    doLast {
        val candidateApks =
            fileTree(layout.buildDirectory) {
                include("outputs/**/*.apk")
                include("**/*.apk")
                exclude("outputs/flutter-apk/**")
            }.files
                .filter { it.isFile }
                .sortedByDescending { it.lastModified() }

        val sourceApk =
            candidateApks.firstOrNull()
                ?: throw GradleException(
                    "No debug APK artifact was found under ${layout.buildDirectory.get().asFile.absolutePath}",
                )

        val flutterOutputDir = layout.buildDirectory.dir("outputs/flutter-apk").get().asFile
        flutterOutputDir.mkdirs()

        sourceApk.copyTo(
            target = flutterOutputDir.resolve("app-debug.apk"),
            overwrite = true,
        )
    }
}
