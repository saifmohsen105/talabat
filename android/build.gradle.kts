allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

subprojects {
    plugins.withId("com.android.application") {
        configureAppSdk(project)
    }
    plugins.withId("com.android.library") {
        configureLibrarySdk(project)
    }
}

fun configureAppSdk(proj: Project) {
    proj.extensions.findByName("android")?.let { android ->
        try {
            val method = android.javaClass.methods.firstOrNull { it.name == "compileSdk" || it.name == "setCompileSdkVersion" }
            method?.invoke(android, 36)
        } catch (e: Exception) {}
    }
}

fun configureLibrarySdk(proj: Project) {
    proj.extensions.findByName("android")?.let { android ->
        try {
            val method = android.javaClass.methods.firstOrNull { it.name == "compileSdk" || it.name == "setCompileSdkVersion" }
            method?.invoke(android, 36)
        } catch (e: Exception) {}
    }
}