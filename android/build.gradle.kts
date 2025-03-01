allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
rootProject.buildDir = file("../build")

subprojects {
    buildDir = file("${rootProject.buildDir}/${name}")
}

tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}
