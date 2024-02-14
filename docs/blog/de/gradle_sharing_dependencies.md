---
date: 2024-02-14
authors:
  - chojo  
categories:
  - minecraft
  - beginner
  - gradle
  - java
  - paper
  - spigot
---

# Teilen und Veröffentlichen von Abhängigkeiten mit Gradle

[English Version](../posts/gradle_sharing_dependencies.md)

Die Wiederverwendung oder der Zugriff auf Code aus anderen Projekten ist mit Gradle sehr einfach.
In diesem Blogbeitrag geht es um die Veröffentlichung von Abhängigkeiten in deinem lokalen Maven-Repository (oder remote), um sie in einem anderen Projekt zu verwenden.
Wir werfen auch einen kurzen Blick auf Online-Repositories und die kleinen Extras, die du beachten musst, wenn deine Projekte Minecraft-Plugins sind.

Wenn du noch nicht mit Gradle vertraut bist, wirf einen Blick auf meinen vorherigen Beitrag über [gradle basics](gradle_minecraft_basic_and_advanced.md).
<!-- more -->

## Projekt Aufsetzen

Wir haben zwei Projekte, die wir der Einfachheit halber `Projekt A` und `Projekt B` nennen.
Am Ende wird `Projekt A` Code und Funktionen implementieren, die von `Projekt B` verwendet werden.

Da dies das komplexere Projekt ist, fangen wir mit diesem an.

### Projekt A - Die Quelle

`Projekt A` wird Code bereitstellen, auf den `Projekt B` zugreift.
Das bedeutet, dass wir mehrere Dinge tun müssen:

- Erstellen eines neues Gradle-Projekt mit dem Namen `Projekt A`.
- Logik/Code hinzufügen, den wir in `Projekt B` verwenden wollen.
- Unser Projekt in unserem lokalen Maven-Repository veröffentlichen

Beginnen wir mit dem Setup selbst.
Die Konfiguration für unser Projekt und unsere Klasse, die wir in unserem anderen Projekt verwenden wollen, sieht folgendermaßen aus:

=== "build.gradle.kts"

    Für den Moment halten wir es einfach.
    Wir definieren unsere Gruppe und Version.
    Keine Abhängigkeiten oder Repositories.

    ```js
    plugins {
        java
    }
    
    group = "dev.chojo"
    version = "1.0.0"
    
    repositories {
        mavenCentral()
    }
    
    dependencies {
    }
    ```


=== "settings.gradle.kts"

    Nichts besonderes hier

    ```js
    rootProject.name = "project-a"
    ```

=== "src/main/java/dev/chojo/projecta/ProjectA.java"

    Zu Demonstrationszwecken haben wir nur eine Klasse mit einer Methode.

    ```java
    package dev.chojo.projecta;
    
    public class ProjectA {
        /**
         * Prints "Meow" to the console.
         */
        public void meow(){
            System.out.println("Meow");
        }
    }
    ```

Jetzt, wo wir unser Basisprojekt eingerichtet haben, können wir uns an das Veröffentlichen machen.
Das ist ziemlich einfach.
Alles, was wir tun müssen, ist, das Plugin `maven-publish` zu importieren und es zu konfigurieren.

!!! Hinweis

    Einige Teile, die bereits vorhanden waren, wurden jetzt weggelassen.
    Es werden nur die Teile angezeigt, die geändert wurden.

```kt
plugins {
    java
    `maven-publish`
}

java {
    toolchain {
        languageVersion.set(JavaLanguageVersion.of(21))
    }
    withSourcesJar()
    withJavadocJar()
}

publishing {
    publications {
        create<MavenPublication>("maven") {
            from(components["java"])
        }
    }
}
```

Hier ist eine Menge passiert, also gehen wir es Schritt für Schritt durch.

1. Wir haben ``maven-publish`` zu unseren `plugins` hinzugefügt. Damit können wir Artefakte überhaupt erst veröffentlichen
2. Wir haben das ``java``-Plugin konfiguriert:
    1. Wir haben die Java Version festgelegt, die unsere Bibliothek verwenden soll
    2. Wir haben festgelegt, dass wir ein Jar mit unserem Quellcode erstellen wollen
    3. Wir haben festgelegt, dass wir ein Jar mit unseren Javadocs erstellen wollen
3. Wir haben das Plugin `maven-publish` konfiguriert:
    1. Wir haben einen neuen Abschnitt für Publikationen erstellt
    2. In diesem Abschnitt haben wir eine neue `MavenPublication` mit dem Namen `maven` erstellt
    3. Wir haben festgelegt, dass diese Publikation alle Komponenten zurückgeben soll, die von unserem Java-Plugin zurückgegeben werden. Das wird sein:
        * Eine Jar mit unserem kompilierten Code
        * Eine Jar mit unserem Quellcode
        * Eine Jar mit unseren Java-Dokumenten

Nun können unser Projekt in unser Maven-Lokal veröffentlichen, indem wir den Task `publishToMavenLocal` von Gradle ausführen.

#### Transitive Abhängigkeiten

Wenn deine Api von einer anderen Api abhängt, kannst du dies anderen mitteilen.
Anstatt `implementation` in deinem `dependencies` Abschnitt zu verwenden, benutzt du `api`.
Außerdem musst du musst `java-library` als Plugin importieren.

```kt
plugins {
    java
    `maven-publish`
    `java-library`
}

dependencies {
    api("de.chojo.sadu", "sadu", "1.4.1")
}
```

Dadurch wird die Bibliothek, von der du abhängst, ebenfalls als transitive Abhängigkeit bei anderen importieren.

### Projekt B - Der Nutzer

Jetzt, wo wir unsere Artefakte in unserem lokalen Maven-Repository veröffentlicht haben, können wir von anderen Projekten in unserem System darauf zugreifen.

!!! warning "Warnung"

    Wenn du dein `Projekt B` an jemand anderen weitergibst, muss dieser den Task `publishToMavenLocal` selbst auf `Projekt A` ausführen.
    Um Abhängigkeiten richtig zu teilen, solltest du [remote repositories](#remote-repositories) verwenden.
    Das lokale Maven-Repository sollte nur für das Debugging und allgemeine Tests deines Projekts verwendet werden.

Als Erstes erstellen wir erneut unser grundlegendes Projekt-Setup wie bei `Projekt A`.

=== "build.gradle.kts"

    Wir definieren unsere Gruppe und Version.
    Keine Abhängigkeiten oder Repositories.

    ```js
    plugins {
        java
    }
    
    group = "dev.chojo"
    version = "1.0.0"
    
    repositories {
        mavenCentral()
    }
    
    dependencies {
    }
    ```


=== "settings.gradle.kts"

    Nichts besonderes hier

    ```js
    rootProject.name = "project-b"
    ```

=== "src/main/java/dev/chojo/projectb/ProjectB.java"

    ```java
    package dev.chojo.projectb;
    
    public class ProjectB {
        public static void main(String[] args) {
        }
    }
    ```

Jetzt importieren wir unser `Projekt A`.
Dafür müssen wir drei Dinge tun:

1. `mavenLocal()` als Repository hinzufügen.
2. Unseren Java Task so konfigurieren, dass er die gleiche oder eine neuere Java-Version als `Projekt A` verwendet.
3. Unser Projekt als Abhängigkeit hinzufügen

!!! Hinweis

    Einige Teile, die bereits vorhanden waren, wurden jetzt weggelassen.
    Es werden nur die Teile angezeigt, die geändert wurden.

```kt
repositories {
    mavenCentral()
    mavenLocal()
}

java {
    toolchain {
        languageVersion.set(JavaLanguageVersion.of(21))
    }
}

dependencies {
    implementation("dev.chojo", "project-a", "1.0.0")
}
```

Jetzt können wir in unsere Klasse `Projekt B` gehen, eine neue Instanz unserer Klasse `Projekt A` erstellen und die Methode `meow` aufrufen.

```java
package dev.chojo.projectb;

import dev.chojo.projecta.ProjectA;

public class ProjectB {
    public static void main(String[] args) {
        new ProjectA().meow();
    }
}
```

Wenn wir jetzt unsere Hauptmethode ausführen, können wir sehen, dass `meow` ausgegeben wird.

Während dies in unserer IDE funktioniert, wird es nicht funktionieren, wenn wir tatsächlich `Projekt B` bauen und unsere `Projekt B` jar ausführen.

Das hat zwei Gründe:

1. Wir haben unsere Main Class nirgendwo definiert.
2. Unsere IDE importiert `Projekt A` in unseren Klassenpfad, da wir es als `implementation` importiert haben.
   Wenn wir bauen, kann unsere IDE es nicht mehr importieren und Gradle geht davon aus, dass wir `Projekt A` selbst zum Klassenpfad hinzufügen werden.
   Um dies zu beheben, können wir entweder das [shadow](https://imperceptiblethoughts.com/shadow/introduction/) Plugin oder das [application](https://docs.gradle.org/current/userguide/application_plugin.html) Plugin verwenden.
   Konfiguriere eines der beiden Plugins wie in der Dokumentation beschrieben

## Hinweis zu Minecraft-Plugins

Wenn du ein Minecraft-Plugin erstellst, gibt es noch einige weitere Dinge, die du beachten solltest:

### CompileOnly oder Implementierung

Ob deine Abhängigkeit eine `compileOnly` oder eine `implementation` ist, hängt von mehreren Faktoren ab.

#### Implementation
- Die Abhängigkeit ist kein Plugin
- Sie wird nicht in Maven Central gehostet.
- Du verwendest eine ältere Version als 1.16.5

Stelle sicher, dass du [shadow and relocation](gradle_minecraft_basic_and_advanced.md#abhängigkeiten-in-unser-jar-shaden) verwendest

#### CompileOnly
- Die Abhängigkeit wird auf MavenCentral gehostet. Verwende den [library loader](gradle_minecraft_basic_and_advanced.md#bukkit-libraries---die-bessere-alternative-zu-shading)
- Die Abhängigkeit ist ein anderes Plugin. **Siehe nächster Abschnitt**

### Depend oder Softdepend

Wenn deine Abhängigkeit ein Plugin ist und als `compileOnly` importiert wird, musst du seinen Namen als `depend` oder `soft-depend` in deiner plugin.yml hinzufügen.

#### Soft-Depend

- Dein Plugin kann auch ohne eine Klasse deiner Abhängigkeit funktionieren

#### Depend

- Dein Plugin wird ohne die Abhängigkeit nicht funktionieren.

## Remote Repositories

Damit jeder dein Projekt unabhängig vom Inhalt des lokalen Maven-Repository bauen kann, solltest du deinen Code in einem remote Repository bereitstellen.

Das bekannteste dürfte [Maven Central](https://central.sonatype.com/) sein.
Allerdings ist die Veröffentlichung dort ziemlich komplex und nichts für Anfänger.
Das Repository ist auch für Projekte mit allgemeiner Nutzbarkeit für die Öffentlichkeit gedacht.

Es gibt verschiedene Software für selbst gehostete Repositories wie [sonatype nexus](https://www.sonatype.com/products/sonatype-nexus-oss) oder [reposilite](https://reposilite.com/).
Wenn du dich nicht selbst hosten willst, gibt es einige Repositories, die öffentlich zugänglich sind.
Bedenke aber, dass alle diese Repositories voraussetzen, dass dein Projekt Open Source ist

- [Eldonexus](https://github.com/eldoriarpg/eldonexus/wiki) wird von mir gehostet. (Kontaktiere mich über Discord, um dich für einen Namensraum zu bewerben)
- [CodeMC](https://github.com/CodeMC)

Letztendlich funktioniert die Veröffentlichung in einem remote Repository aber ähnlich.

Alles, was du normalerweise tun musst, ist, eine einfache Autorisierung zu konfigurieren:

```kt
publishing {
    publications {
        create<MavenPublication>("maven") {
            from(components["java"])
        }
    }

    repositories {
        maven {
            name = "Example"
      
            authentication {
                credentials(PasswordCredentials::class) {
                    username = "username"
                    password = "password"
                }
            }

            url = uri("https://repo.example.com")
        }
    }
}
```

!!! Warnung

    Füge deine Anmeldedaten nicht in deinen Code ein.
    Lies sie stattdessen aus einer Umgebungsvariable.

Sobald du dein Repository konfiguriert hast, hast du einen neuen Task namens `publishMavenPublicationToExampleRepository` mit dem du publishen kannst.

!!! Hinweis

    Der Name des Tasks ändert sich je nach dem Namen, den du deinem Repository gibst.

Und das war's.
Natürlich gibt es noch mehr zu beachten, wie Snapshot- und Stable-Repositories.
Plugins wie [publishData](https://github.com/rainbowdashlabs/publishdata) oder [indra](https://github.com/KyoriPowered/indra) können sich zum Beispiel darum kümmern.

## Vielen Dank

Das war's schon.
Jetzt kannst du ganz einfach Code zwischen deinen Projekten austauschen oder anderen erlauben, Code aus deinen Projekten zu verwenden.

{{ blog_footer_de }}
