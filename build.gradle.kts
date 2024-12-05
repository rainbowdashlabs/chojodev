plugins {
    java
}

group = "dev.chojo" // Please use your own group id c:
version = "1.0.0-SNAPSHOT"

repositories {
    mavenCentral()
    // External repository
    maven("https://papermc.io/repo/repository/maven-public/")
}

dependencies {
    // We are not responsible to provide the classes from this dependency
    compileOnly("io.papermc.paper:paper-api:1.21.1-R0.1-SNAPSHOT")
    // We are responsible for providing the classes from this dependency
    implementation("de.chojo.sadu", "sadu", "2.3.1")
}

java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(21)
    }
    withSourcesJar()
    withJavadocJar()
}

tasks {
    compileJava {
        options.encoding = "UTF-8"
    }

    compileTestJava {
        options.encoding = "UTF-8"
    }

    javadoc {
        options.encoding = "UTF-8"
    }
}
