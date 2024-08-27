---
date: 2024-08-26
authors:
  - chojo
categories:
  - beginner
  - gradle
  - java
---


# Gradle Shadow Plugin

The shadow plugin for gradle is a third party plugin that is widely used.
It is especially useful if you need to bundle all your dependencies in a single jar, producing a so called **FatJar**.
If you simply want to ship a standalone application, the [application plugin](gradle_basics_bundle_application.md) might be the better choice.
Shadow is ideal for minecraft plugins for example.
<!-- more -->

## What is the shadow plugin

The shadow plugin will copy all your dependencies imported via `implementation` into your jar file during the building process.

It has also some additional features like relocating packages and setting the main class path, which I will explain later.

## Applying the shadow plugin

Since the shadow plugin is a third party plugin we now need to define the version of it additionally.

```java
plugins {
  id("{{ VC_PLUGIN_SHADOW_ID }}") version "{{ VC_PLUGIN_SHADOW_VERSION }}"
}
```

Our dependencies currently look like this:

```java
dependencies {
    implementation("{{ VC_LIBRARY_SADU_GROUP }}", "{{ VC_LIBRARY_SADU_NAME }}", "{{ VC_LIBRARY_SADU_VERSION }}")
}
```

The purpose of shadow is to copy everything marked as `implementation` to the output jar.

This is already the case if we were to run the `shadowJar` task instead of the `build` task.
However, building our plugin without `shadowJar` would result in a jar that is simply broken and would throw a `ClassNotFoundException` at us at the moment we want to use classes from SADU.

## Configure shadow task

We can fix this by telling Gradle that when we run `build` we actually want to run `shadowJar`.
We do this by configuring the `build` task to depend on `shadowJar`.

```java
tasks {
    build {
        dependsOn(shadowJar)
    }
    
    shadowJar {
        mergeServiceFiles()
    }
}
```

Additionally, we want to merge service files.

### Service files

If you have dependencies that provide services (which a lot actually do) You should add `mergeServiceFiles()` to your `shadowJar` task configuration. This makes shadow to merge all service files of all your dependencies together.

```java
tasks {
    shadowJar {
        mergeServiceFiles()
    }
}
```

### Minimize

If you have a very large jar because you have a lot of dependencies, it might be beneficial to minimize your jar. This will remove any uncalled class of your dependencies. But be aware that this will not detect classes loaded via reflections, e.g. database drivers.

```java
tasks {
    shadowJar {
        minimize()
    }
}
```

### Relocation

!!! warn

    This part is crucial when shading in minecraft plugins

Now that our libraries are shaded we need to do something called relocation.
This is important to avoid conflicts with other plugins when you shade the same library.
To do this we need to configure it, but this time we are not configuring the plugin, but the task called `shadowJar`.

```java
tasks {
    shadowJar {
        val mapping = mapOf("de.chojo.sadu" to "sadu")
        val base = "dev.chojo.myapp.libs."
        for ((pattern, name) in mapping) relocate(pattern, "${base}${name}")
    }
}
```

What this basically does is:

1. We define a map with the packages we want to move and the directory we want them to move to.
2. We define the root of the new location of all our shaded libraries.
3. For each entry in our map, we call the relocate function of our task.

So what does relocation do?  
Consider the class `de.chojo.sadu.Sadu`. After the relocation it will be located at `dev.chojo.myapp.libs.sadu.Sadu`.
Now that it is in your namespace and our plugin, it is no longer possible for it to collide with another plugin.
Shadow will also replace any path to the class in your code with the new relocated path.

The path to relocate is usually the group id of the dependency you want to relocate.
Beware that dependencies may have own dependencies that are shaded as well.
Those dependencies might have other group ids that require explicit relocation.

## Bundling applications

If your application is not a plugin, and you want to run your jar via `java -jar` you additionally need to define a main class. You can do that easily in the shadowJar task as well.

```java
tasks {
    shadowJar {
        manifest {
            attributes(mapOf("Main-Class" to "dev.chojo.myapp.Main"))
        }
    }
}
```

<details>
<summary>Checkpoint</summary>

```java
plugins {
  id("{{ VC_PLUGIN_SHADOW_ID }}") version "{{ VC_PLUGIN_SHADOW_VERSION }}"
}

group = "dev.chojo" // Please use your own group id c:
version = "1.0.0-SNAPSHOT"

repositories {
    mavenCentral()
}

dependencies {
    implementation("{{ VC_LIBRARY_SADU_GROUP }}", "{{ VC_LIBRARY_SADU_NAME }}", "{{ VC_LIBRARY_SADU_VERSION }}")
}

java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(21)
    }
    withSourcesJar()
    withJavadocJar()
}

tasks {
    build {
        dependsOn(shadowJar)
    }
    
    shadowJar {
        mergeServiceFiles()
        // minimize()
        val mapping = mapOf("de.chojo.sadu" to "sadu")
        val base = "dev.chojo.myapp.libs."
        for ((pattern, name) in mapping) relocate(pattern, "${base}${name}")
        // If you have a main class, relocation is most probably not necessary since your application is most probably standalone
        manifest {
            attributes(mapOf("Main-Class" to "dev.chojo.myapp.Main"))
        }
    }
}

```

</details>

## Thank you!

Thank you for sticking with me so far.
You now have a very good understand how the shadow plugin works.

To continue your gradle journey you may be interested in my other blog post about [gradle basics with minecraft](gradle_basics_minecraft.md), or you maybe want to take a look at the [application plugin](gradle_basics_bundle_application.md)

{{ blog_footer_en }}
