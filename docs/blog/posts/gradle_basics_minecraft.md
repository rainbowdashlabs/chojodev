---
date: 2024-08-26
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

# Gradle with Minecraft

This blog post is about minecraft development with gradle and some of the most crucial tools that make your life much easier.

This post assumes you have a build file similar to the one we had at the end of the first [gradle blog](gradle_basics.md) post.
<!-- more -->

## Creating a plugin.yml using a Gradle plugin

If you followed only the last blog post, you might not have a plugin.yml yet.
If you already have a `plugin.yml` you can delete it now or wait until the end of this section.

To create our `plugin.yml` we will use the `plugin-yml` [Gradle plugin by minecrell](https://github.com/Minecrell/plugin-yml).

### Importing

First we need to import it.

!!! note

    Although I do not have any other plugins in my plugin section at the moment, this does not mean that you should create a new plugin section or delete the other plugins.
    I just do not show all available plugins every time to keep it as short as possible.

```java
plugins {
    id("{{ VC_PLUGIN_BUKKITYML_ID }}") version "{{ VC_PLUGIN_BUKKITYML_VERSION }}"
}
```

### Configuration

Now that this is done, we need to configure our plugin.
We do this, of course, in the section of the plugin called `bukkit` in our case.

```java
bukkit {
    name = "MyPlugin"
    main = "dev.chojo.myplugin.MyPlugin"

    commands {
        register("test") {
            aliases = listOf("command")
        }
    }
}
```

This is the minimum setup. (Commands are not really needed)
What are we doing here?

1. We define the plugin with the name "MyPlugin".
2. We define our plugin class.  
   Please don't make it `Main` and choose a correct namespace.
   See my previous [blog post](minecraft_main_class.md).
3. We will register a command called `test` with the alias `command`.

Have a look at the [GitHub page](https://github.com/Minecrell/plugin-yml#bukkit) for further references.

The version is taken from your project version by default.


<details>
<summary></summary>

```java
plugins {
    java
    id("{{ VC_PLUGIN_BUKKITYML_ID }}") version "{{ VC_PLUGIN_BUKKITYML_VERSION }}"
}

group = "dev.chojo" // Please use your own group id c:
version = "1.0.0-SNAPSHOT"

repositories {
    mavenCentral()
    // External repository
    maven("https://papermc.io/repo/repository/maven-public/")
}

dependencies {
    compileOnly("{{ VC_LIBRARY_PAPER_FULL }}")
    implementation("{{ VC_LIBRARY_SADU_GROUP }}", "{{ VC_LIBRARY_SADU_NAME }}", "{{ VC_LIBRARY_SADU_VERSION }}")
}

java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(21)
    }
    withSourcesJar()
    withJavadocJar()
}

bukkit {
    name = "MyPlugin"
    main = "dev.chojo.myplugin.MyPlugin"

    commands {
        register("test") {
            aliases = listOf("command")
        }
    }
}
```


</details>

### Bukkit Libraries - The better alternative to shading

Lets assume our dependency section looks like this:

```java
dependencies {
    compileOnly("{{ VC_LIBRARY_PAPER_FULL }}")
    implementation("{{ VC_LIBRARY_SADU_GROUP }}", "{{ VC_LIBRARY_SADU_NAME }}", "{{ VC_LIBRARY_SADU_VERSION }}")
}
```

Previously we had the problem that SADU was not included in our jar.
If we use the `plugin-yml` plugin and are using Minecraft 1.16.5 or later, we can use the library loader.
All we need to do is change `implementation` to `bukkitLibrary`:

```java
dependencies {
    compileOnly("{{ VC_LIBRARY_PAPER_FULL }}")
    bukkitLibrary("{{ VC_LIBRARY_SADU_GROUP }}", "{{ VC_LIBRARY_SADU_NAME }}", "{{ VC_LIBRARY_SADU_VERSION }}")
}
```

Now our library is loaded by Spigot/Paper when it loads our plugin and is available at runtime.
This works because SADU is located at Maven Central and Spigot/Paper downloads libraries from there.
Libraries not located at Maven Central still need to be [shadowed](gradle_basics_bundle_shadow.md).

#### Paper plugins

Paper plugins are a type of plugin exclusively for Paper servers.
They are quite new and some things might be different from what you know.
They don't share the command system with spigot but use the Brigadier system, that Minecraft itself uses. Usually people use a command system like [Cloud](https://cloud.incendo.org/minecraft/paper/) or [ACF](https://github.com/aikar/commands), which wraps around Brigadier and maker it easier to use.
They also require a new configuration framework, since file configurations and ConfigurationSerializable are no longer available. I developed [jackson bukkit](jackson_bukkit.md) for that.
So the learning curve might be a bit steeper for beginners since you probably start with a bunch of new frameworks right from the start. But if you are very new to this and are just starting with minecraft and are just targeting newer paper server, this might be an interesting starting point.

In Paper plugins you can also load dependencies from custom repositories. You can read more about this [here](https://github.com/Minecrell/plugin-yml#plugin-libraries-json).

More about Paper plugins can be found [here](https://docs.papermc.io/paper/reference/paper-plugins) and [here](https://docs.papermc.io/paper/dev/getting-started/paper-plugins).


<details>
<summary>Checkpoint</summary>

```java
plugins {
    java
    id("{{ VC_PLUGIN_BUKKITYML_ID }}") version "{{ VC_PLUGIN_BUKKITYML_VERSION }}"
}

group = "dev.chojo" // Please use your own group id c:
version = "1.0.0-SNAPSHOT"

repositories {
    mavenCentral()
    // External repository
    maven("https://papermc.io/repo/repository/maven-public/")
}

dependencies {
    compileOnly("{{ VC_LIBRARY_PAPER_FULL }}")
    bukkitLibrary("{{ VC_LIBRARY_SADU_GROUP }}", "{{ VC_LIBRARY_SADU_NAME }}", "{{ VC_LIBRARY_SADU_VERSION }}")
}

java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(21)
    }
    withSourcesJar()
    withJavadocJar()
}

bukkit {
    name = "MyPlugin"
    main = "dev.chojo.myplugin.MyPlugin"

    commands {
        register("test") {
            aliases = listOf("command")
        }
    }
}
```

</details>


## NMS and internals using the Paperweight Userdev plugin

I do not encourage using nms in any way, but if you want to, you should use the `userdev` plugin from `paperweight`.
This allows you to develop against an environment with non-obfuscated names.
It is also the only supported way of accessing internals in `org.bukkit.craftbukkit.v1_XX_RX`.
It also ensures that when you upgrade to a new version, you do not have to change any code that is using the `net.minecraft` package.
Of course, you still need to change code when Mojang changed something.
However, you still need to change the package names when using internal code from `org.bukkit.craftbukkit.v1_XX_RX`;

### Adding the repository

For this we need to do something new and go into our `settings.gradle.kts` to add a plugin repository.

```java
pluginManagement {
    repositories {
        gradlePluginPortal()
        maven("https://papermc.io/repo/repository/maven-public/")
    }
}
```

To do this we need to configure the `pluginManagement` section and change the repositories.
By default, only `gradlePluginPortal()` is imported, which usually contains all the important plugins so far.
But now we want to add another repository.
It is very important that you add `gradlePluginPortal()` as well as the Paper repository.

### Importing

Now we can import the plugin into our `build.gradle.kts` file.

```java
plugins {
    id("{{ VC_PLUGIN_USERDEV_ID }}") version "{{ VC_PLUGIN_USERDEV_ID }}"
}
```

This leaves just one step to set up the Paper version.

### Configuration

To define the version we want to use, we need to add it to our dependencies.
To do this we need to remove the old Paper compileOnly dependency and replace it with the paperweight dependency.

```java
dependencies {
    paperweight.paperDevBundle("{{ VC_LIBRARY_PAPER_VERSION }}")
}
```

The version entered here is the same as for Paper. You just remove the group and artefact id.
Paper uses the obfuscated jar.
This requires us to actually reobfuscate our jar before building.
We can do this again by configuring a task.
This time we configure the `assemble` task and set a `dependsOn` on it.


```java
tasks {
    assemble {
        dependsOn(reobfJar)
    }
}
```

!!! note

    From 1.21 onwards paper uses a non obfuscated jar.
    If your plugin only runs on paper, you no longer need to reobfuscate your jar.
    Have a look at the paper [documentation](https://docs.papermc.io/paper/dev/userdev#compiling-to-mojang-mappings), since some additional stuff is required to run mojang mapped plugins    


And that's it.
Now you can use nms as comfortably as possible.


<details>
<summary>Checkpoint</summary>

**build.gradle.kts**
```java
plugins {
    java
    id("{{ VC_PLUGIN_BUKKITYML_ID }}") version "{{ VC_PLUGIN_BUKKITYML_VERSION }}"
}

group = "dev.chojo" // Please use your own group id c:
version = "1.0.0-SNAPSHOT"

repositories {
    mavenCentral()
    // External repository
    maven("https://papermc.io/repo/repository/maven-public/")
}

dependencies {
    paperweight.paperDevBundle("{{ VC_LIBRARY_PAPER_VERSION }}")
    bukkitLibrary("{{ VC_LIBRARY_SADU_GROUP }}", "{{ VC_LIBRARY_SADU_NAME }}", "{{ VC_LIBRARY_SADU_VERSION }}")
}

java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(21)
    }
    withSourcesJar()
    withJavadocJar()
}

bukkit {
    name = "MyPlugin"
    main = "dev.chojo.myplugin.MyPlugin"

    commands {
        register("test") {
            aliases = listOf("command")
        }
    }
}
```

**settings.gradle.kts**

```java
pluginManagement {
    repositories {
        gradlePluginPortal()
        maven("https://papermc.io/repo/repository/maven-public/")
    }
}
```

</details>

## Running a server with your jar

To quickly test your plugin, you can start a server directly.
All you need to do is add the [run-task plugin](https://github.com/jpenilla/run-task) to your build file.

I'll refrain from simply copying their readme here, as I can't add any more value to it.

## Thank you!

Thank you for sticking with me so far.
You now have a very good understanding of Minecraft development with Gradle.

{{ blog_footer_en }}
