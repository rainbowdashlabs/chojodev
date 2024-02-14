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

# Sharing and Publishing Dependencies with Gradle

[German Version](../de/gradle_sharing_dependencies.md)

Reusing or accessing code from other projects with gradle is very easy.
This blog posts dives into publishing dependencies to your local maven repository (or remote) to use it in another project.
We also take a short look at online repositories and the small extras you have to account for when your projects are minecraft plugins.

If you are not familiar with gradle yet, have a look at my previous post about [gradle basics](gradle_minecraft_basic_and_advanced.md).

<!-- more -->

## Project Setup

We have two projects which are named `ProjectA` and `ProjectB` for simplicity.
In the end `ProjectA` will implement code and functions that are used by `ProjectB`.

Since this is the more complex setup we're going to start with this.

### ProjectA - The Provider

`ProjectA` will provide code accessed by `ProjectB`.
That means we need to do several things:

- Create a new gradle project named `ProjectA`
- Add some logic/code to it, that we want to use in `ProjectB`
- Publish our project into our local maven repository

Let's start with the setup itself. 
The configuration for our project and our class we want to use in our other project look like this:

=== "build.gradle.kts"

    For now we take it simple.
    We defined our group and version.
    No dependencies and no additional repositories.

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

    Nothing special here

    ```js
    rootProject.name = "project-a"
    ```

=== "src/main/java/dev/chojo/projecta/ProjectA.java"

    For demonstration purposes we only have one class with one method.

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

Now that we have our basic project setup we can work on publishing our changes.
This is fairly simple.
All we need to do is to import the `maven-publish` plugin and configure it.

!!! note

    Some parts that were already there were left out now.
    Only parts that were changed are shown.

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

A lot happened here, so lets go through it step by step.

1. We added ``maven-publish`` to our `plugins`. This allows us to publish artifacts in the first place
2. We configured the `java` plugin:
    1. We defined the language version our library will use
    2. We defined that we want to create a jar containing our source
    3. We defined that we want to create a jar containing our javadocs
3. We configured the `maven-publish` plugin.
    1. We created a new publications section
    2. In that section we created a new `MavenPublication` called `maven`
    3. We defined that this publication should return all components returned by our java plugin. This will be:
        * One jar containing our compiled code
        * One jar containing our source code
        * One jar containing our java docs

Now that this is done we can publish into our maven local by executing the `publishToMavenLocal` task of gradle.

#### Transitive dependencies

If your api depends on another api you can tell this to others.
Instead of using `implementation` in your `dependencies` section you use `api`.
For that you also need to import `java-library` as a plugin.

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

This will make them import the library your depend on as a transitive dependency as well.


### Project B - The Consumer

Now that we published our artifacts into our local maven repository we can access it from other projects on our system.

!!! warning
    
    If you send your `ProjectB` to someone else they need to execute the `publishToMavenLocal` task themself on `ProjectA`.
    To properly share dependencies you should use [remote repositories](#remote-repositories).
    The local maven repository should only be used for debugging and general testing of your project.

First we create our basic project setup again like we did on `ProjectA`.

=== "build.gradle.kts"

    We defined our group and version.
    No dependencies and no additional repositories yet.

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

    Nothing special here

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

Now we get to importing our `ProjectA`.
For that we need to do three things:
1. Add `mavenLocal()` as a repository.
2. Configure our java task to use the same or a newer toolchain version than `ProjectA`.
3. Add our project as a dependency

!!! note

    Some parts that were already there were left out now.
    Only parts that were changed are shown.

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

Now we can go into our `ProjectB` class, create a new instance of our `ProjectA` class and call the meow method.

```java
package dev.chojo.projectb;

import dev.chojo.projecta.ProjectA;

public class ProjectB {
    public static void main(String[] args) {
        new ProjectA().meow();
    }
}
```

If we run our main method now we can see that "meow" get printed out.

While this works in our IDE, it will not work when we actually build `ProjectB` and execute our `ProjectB` jar.

This has two reasons:
1. We did not define our main class anywhere.
2. Our IDE does imports `ProjectA` into our class path, since we imported it as `implementation`.
   When we build our IDE can no longer import it and gradle assumes that we will add `ProjectA` ourselves to the classpath.
   To fix this we can either use the [shadow](https://imperceptiblethoughts.com/shadow/introduction/) plugin or the [application](https://docs.gradle.org/current/userguide/application_plugin.html) plugin.
   Configure either of them as described in the documentation

## Note on minecraft plugins

When you are building a minecraft plugin there are several more things you should consider:

### CompileOnly or Implementation

Whether your dependency is a `compileOnly` or `implementation` depends on multiple factos.

#### Implementation  
- The dependency is not a plugin
- Is not hosted in maven central.
- You are on an older version than 1.16.5

Make sure to use [shadow and relocation](gradle_minecraft_basic_and_advanced.md#shading-dependencies-into-our-jar)

#### CompileOnly
- The dependency is hosted on MavenCentral. Use the [library loader](gradle_minecraft_basic_and_advanced.md#bukkit-libraries---the-better-alternative-to-shading)
- The dependency is another plugin. **See next section**

### Depend or Softdepend

If your dependency is a plugin and imported as `compileOnly` make sure to add its name as a `depend` or `soft-depend` in your plugin.yml.

#### Soft-Depend

- Your plugin can work without any class of your dependency

#### Depend

- Your plugin will not work without the dependency.

## Remote Repositories

To allow everyone to build your project regardless of their local maven repository content you should deploy your code into a remove repository.

The most famous one might be [Maven Central](https://central.sonatype.com/).
However, publishing there is quite complex and nothing for beginners.
The repository is also intended for projects with general usability for the public.

There are several different pieces of software for self-hosting repositories like [sonatype nexus](https://www.sonatype.com/products/sonatype-nexus-oss) or [reposilite](https://reposilite.com/).
If you don't want to self-host, there are a some repositories out there that are open to the public.
However, have in mind that all those repositories require your project to be open source

- [Eldonexus](https://github.com/eldoriarpg/eldonexus/wiki) hosted by me. (Reach out via discord, to apply for a namespace)
- [CodeMC](https://github.com/CodeMC)

However, in the end publishing to a remote repository works similar.

All you need to do usually is to configure some simple auth:

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

!!! Warning

    Don't put your credentials in your code.
    Read them from some environment variable instead.

Once you configured your repository you have a new tasks called `publishMavenPublicationToExampleRepository` which allows you to publish to your remote repository.

!!! Note

    The task name changes based on the name you assign to your repository.

And that's it.
Of course there is more to consider like snapshot and stable repositories. 
Plugins like [publishData](https://github.com/rainbowdashlabs/publishdata) or [indra](https://github.com/KyoriPowered/indra) can take care of that for example. 

## Thank you

That's it. Now you can easily share code between your projects or allow others to use code from your projects. 

{{ blog_footer_en }}
