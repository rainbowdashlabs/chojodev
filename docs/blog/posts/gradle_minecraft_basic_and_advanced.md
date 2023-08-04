---
date: 2023-08-04
authors:
  - chojo  
categories:
  - minecraft
  - beginner
  - gradle
  - java
---

# Minecraft Development with Gradle: Basic and Advanced | A guide

[German Version](../de/gradle_minecraft_basic_and_advanced.md)

This blog post is about minecraft developing using gradle.
The minecraft community has built a huge ecosystem for minecraft around the Gradle build tool.
Instead of throwing some example Gradle file at you, we will walk through this step by step.
Starting with the basic Gradle layout, start to set repositories and dependencies and proceed with plugins.

<!-- more -->

## What is gradle?

Gradle is a so-called project management system or also build tool.
It takes basically care of your building process, resolved dependencies, executes tests and can do all kind of things, even starting a minecraft server.
Gradle uses Kotlin or Groovy for the build file.
I recommend to use kotlin.
Where you need custom plugins in maven, you can simply write your own logic directly in the build file when using Gradle.
But enough of the examples it is time to get started.

## Install gradle

If you haven't installed Gradle yet, you should do this first.
I will not go into this in depth since Gradle itself has great [documentation](https://gradle.org/install/) on this.
We will use Gradle only for the initial project initialization and after this proceed to use the Gradle wrapper.

## The Gradle wrapper

The Gradle wrapper is basically a portable Gradle installation.
It does not require any Gradle installation present on the system and can be used to build everywhere.
Therefore, it has its own version.
To upgrade this version you only need one command:

```shell
./gradlew wrapper --gradle-version=8.2.1 --distribution-type=bin
```

This works on unix systems and in Windows PowerShell or git bash as well.
If you are using the windows cmd you have to use `gradlew.bat` instead.

Check the latest version on the [Gradle website](https://gradle.org/releases/).

## Setting up a Gradle project

=== "Using IntelliJ"

    ![img.png](../../assets/images/gradle_setup.png)
    
    We will look at the marks one after another. 
    Most of the settings will be set by default already.
    
    1. We select **New Project**
    2. We add our project id aka name.  
    This name is your **plugin name in lower case** with `-` where a space would be.  
    So `MyPlugin` becomes `my-plugin`
    3. Make sure that a **git repository** is created
    4. Select **Java** as language or **Kotlin** if you like this more, but I will only use Java here.
    5. Select **Gradle as build system**
    6. Select **Kotlin as Gradle DSL** 
    7. Let intellij add some sample code.  
    This will be removed later but already creates the most important directories.
    8. Select the wrapper as Gradle distribution
    9. Write in here the latest Gradle version as mentioned on the [Gradle website](https://gradle.org/releases/).  
    This might not be available to select in the drop-down menu, but you can write it yourself.
    10. Write your group id here.
    If you don't know what to write here have a log at my other [post](minecraft_main_class.md#1-namespace-conflicts)
    If you don't own a domain have a look [here](minecraft_main_class.md#i-dont-have-a-domain)
    11. This is the same as your name in **2.**

=== "Using Eclipse"

    Sorry eclipse users.
    Time to use an actually good IDE.
    Switch to IntelliJ c:

=== "Using CLI"

    If you already have a project you can easily set it up via command line.
    If your project is currently a maven project, Gradle will offer you to convert it into a Gradle project.
    
    We will look into how we set up a new Gradle project without importing anything from maven.
    
    First we start with initialising Gradle with `Gradle init`.
    We are using the installed Gradle version for this, so that's why you need it installed.
    
    You will end up with this dialogue
    ```
    Select type of project to generate:
      1: basic
      2: application
      3: library
      4: Gradle plugin
    Enter selection (default: basic) [1..4]
    ```
    Select 1 here by simply typing `1` or just press enter since `basic` is the default.
    This will create a basic Gradle project.
    
    If instead you want to create a library you can choose `3`.
    However, all that this does is to apply some basic plugins beforehand which we will get through anyway later.
    
    
    In the next step we need to select the language for our Gradle DSL
    ```
    Select build script DSL:
      1: Kotlin
      2: Groovy
    Enter selection (default: Kotlin) [1..2]
    ```
    Select 1 here again by typing `1` or just press enter since Kotlin is the default.
    
    
    Now we need to enter our project name.
    I recommend to use your plugin name in lower case and insert `-` where spaces would be.
    So `MyPlugin` becomes `my-plugin`
    ```
    Project name (default: directory): 
    ```
    
    Next up is some question for Gradle stuff.
    ```
    Generate build using new APIs and behavior (some features may change in the next minor release)? (default: no) [yes, no] 
    ```
    I recommend to go with the default no. So just press enter or type `no`.
    And that's it you are done.


## Gradle files

Now you have a bunch of new files.
Let's go over them one by one.

### gradle Directory

The Gradle directory contains the wrapper directory which itself contains a `gradle-wrapper.jar`, which is your gradle-wrapper.
That is your portable Gradle installation as mentioned before.

The `gradle-wrapper.properties` contains the settings of the wrapper.
The most important part here is the version.
You can change it here as well if you forget the command shown in the previous [section](#the-gradle-wrapper).

### build.gradle.kts

The build.gradle.kts is the core of our project.
Nearly all of our configuration in our project will be done in this file.
It contains dependencies, repositories and a lot of other stuff.

### gradlew and gradlew.bat

Those are the Gradle wrapper files.

- `gradlew.bat` for the windows cmd 
- `gradlew` for unix systems, Windows powershell and git bash on windows.

### settings.gradle.kts

The settings can be used to apply project wide settings like plugin repositories (not dependency repositories!).
You can also define submodules here when you have a multimodule project or create a [version catalog](https://docs.gradle.org/current/userguide/platforms.html).

### src directory

While the directory is strictly seen not a part of Gradle it is still important to have a specific setup:

```
.
└── src/
    ├── main/
    │   ├── java
    │   └── resources
    └── test/
        ├── java
        └── resources
```

If those directories are not present in your src directory please create them.

## The basic build.gradle.kts

Let's start with taking a look at our build.gradle.kts.
It should be empty at the moment if you have used the cli approach or have some stuff in it already if you set it up via IntelliJ.

Let's get you on the same page by adding some sections to start with a fresh file.

### The plugin section

The top section of our file will be always the `plugins` section.
So we start with inserting it first.

```java
plugins {
}
```

The whole Gradle logic works by plugins adding tasks which are executed by us.
Since we want to build a java application we need to add the `java` plugin.
This can be done by simply writing `java` in the `plugins` block.

```java
plugins {
    java
}
```

And that's it. We are already done with our plugin setup for now.

### Declaring group and version

Now we need to declare our group and version.
This is not a section but only two values we assign.
Your group id if not set yet should be a domain you **own** in inversed order.
If you don't own a domain have a look at my other [post](minecraft_main_class.md#i-dont-have-a-domain).
I recommend to use [semver](https://dev.to/nialljoemaher/an-introduction-to-semantic-versioning-26n9) for your version.

```java
group = "dev.chojo"
version = "1.0.0-SNAPSHOT"
```

### Repositories section

The repositories section is the section where we define the repositories our dependencies are located in.

We need two repositories most probably.

- `mavenCentral()`   
This is the maven central repository where most of the dependencies we will need are located.
If you used maven: On maven you did not need to import this specifically, but in Gradle you do.
- `maven("https://repo.papermc.io/repository/maven-public/")`  
This imports the paper mc repository. Of course, you can do the same with any other repository.

```
repositories {
    mavenCentral()
    maven("https://repo.papermc.io/repository/maven-public/")
}
```

**Order matters!**

The order you assign repositories in this section is the order Gradle will search for dependencies.
It will take the first found location where the dependency is present.

**Maven local**

If you want to use dependencies from your local maven repository you need to add `mavenLocal()` at the top of the section.
I highly recommended to do this only for local development, since this destroys the ability to build it on other machines.

### Dependencies section

!!! note 
    
    If you have test imports from junit here you can delete it for now.

Inside the dependencies section we can for now define two different dependency types:

```java
dependencies {
    compileOnly("io.papermc.paper:paper-api:1.20.1-R0.1-SNAPSHOT")
    implementation("de.chojo", "sadu", "1.3.1")
}
```

I used two different ways to declare dependencies here.
Both are valid.
You can either declare them as one string or as three separate strings.

[SADU](https://github.com/rainbowdashlabs/sadu) is a library written by me, which aims to make using databases easier for beginners. Have a look c:

=== "As implementation"

    The `implementation` imports are dependencies which are not part of paper and therefore need to get into your plugin in some way.
    This will not work now, but we are going to fix this in a later step.

=== "As compileOnly"

    The `compileOnly` imports are dependencies we only need for building.
    This will nearly always just be paper for you.

### Tasks section

!!! note

    You can delete everything currently in your tasks section    

I told you earlier that everything in Gradle works with tasks.
So there must be a way to configure them and that is where the tasks section is used.
For now, we will just start with a simple empty section.

```java
tasks {

}
```

## Configuring Java

Now that we have all required sections in our file we can finally start with actually configuring our project.

The first thing we need to configure is the `java` plugin we already imported.
While I showed you the basic sections already there are more, because nearly every plugin adds its own section for configuring.
That means we can not only configure the tasks of our plugins, but the plugin itself as well.

```java
java {
    toolchain {
        languageVersion.set(JavaLanguageVersion.of(17))
    }
    withSourcesJar()
    withJavadocJar()
}
```

For `java` we set the so called toolchain.
The toolchain, for us, controls the used java version in our project.
If you want to import a dependency, which is compiled with java 17, you need to set your toolchain to 17 as well.
On the other hand using a toolchain of java 17 still allows you to import any dependency using an older java version.

We also define that we want to build a sources jar and a javadoc jar.
This might not be important for us now, but it might be in the future.
Having it doesn't hurt in the end.

Additionally, to our java plugin configuration we want to configure the tasks of it as well.
There are three tasks that are interesting for us:

=== "compileJava"  

    This tasks handles the compilation of our java code

=== "compileJavaTest"  

    This tasks handles the compilation of our test code written in java.
    While we do not have tests yet, it cant hurt to still define it.

=== "javadoc"
    
    This handles how our javadocs are build

All we want to define for those tasks is just that we want to use `UTF-8` encoding for them.
This avoids weird characters when using any special characters.

```java
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
```

And that's the configuration for our java plugin.

## Building the plugin

Nothing can hold us back from building our plugin now. 
All we miss is a `plugin.yml`.
While we could stop here and just be happy that it works there is still a lot (and by that I mean A LOT) room for improvement.
We also still have to solve the issue of our library not being included that we imported with `implementation` earlier.
So while you could call it a day now I highly recommend to keep reading!

For now, I will just show you the two ways of executing a Gradle task

=== "Via cli"

    Go into your cli and execute `./gradlew build` or `gradlew.bat build` depending on your operating system

=== "via IntelliJ"

    Open the Gradle window on the right side. Go to tasks -> build and execute the build task by clicking on it.

    ![Gradle build.png](../../assets/images/gradle_build.png)

### Obtaining the build file

You will now find your plugin under `build/libs/myplugin.jar`.
Now this is of course not in your server yet, but we have a very simple way for that.

## Copy a jar after build

To copy our jar into our server we can simply create our own task.

Take a look at the code. Explanations are shown when you hover over the plus for each line

!!! note

    Although I have no other tasks in my tasks section right now, that does not mean you should create a new tasks.
    I just dont show all present tasks every time to keep it as short as possible.

```java
tasks {
    /*(1)!*/register<Copy>("copyToServer") {
        /*(2)!*/val props = Properties() 
        /*(3)!*/val propFile = file("build.properties") 
        /*(4)!*/if (!propFile.exists()) propFile.createNewFile() 
        /*(5)!*/file("build.properties").reader().let { props.load(it) }
        /*(6)!*/val path = props.getProperty("targetDir") ?: "" 
        /*(7)!*/if (path.isEmpty()) throw RuntimeException("targetDir is not set in build.properties") 
        /*(8)!*/from(jar) 
        /*(9)!*/destinationDir = File(path)
    }
}
```

1. We register a new task of type `Copy` and name it `copyToServer`
2. We create our properties  
You might need to add an import `import java.util.*` to the top of the file for this.
3. We create a file called `build.properties`
4. We create the file if it doesn't exist yet.
5. We read the file and add it to the properties
6. We read the `targetDir` property
7. We check if the path is empty and throw an error if that is the case
8. We define that we want the output of our jar task to copy
9. We set the destination dir of the copy task

## Creating a plugin.yml using a Gradle plugin

Now you might have tried it or not.
If you have created a `plugin.yml` already it might have worked and otherwise failed.

If you have created a `plugin.yml` already you can delete it again now or wait until the end of the section.

To create our `plugin.yml` we will use the `plugin-yml` [Gradle plugin by minecrell](https://github.com/Minecrell/plugin-yml).

### Importing

First we need to import it. The latest version currently is ![Gradle Plugin Portal](https://img.shields.io/gradle-plugin-portal/v/net.minecrell.plugin-yml.bukkit?label=Version)

!!! note

    Although I have no other plugins in my plugin section right now, that does not mean you should create a new plugin section or delete the other plugins.
    I just dont show all present plugins every time to keep it as short as possible.

```java
plugins {
  id("net.minecrell.plugin-yml.bukkit") version "version" // (1)!
}
```

1. Replace the version here with the version in the image above

### Configuration

Now that this is done we need to configure our plugin.
We do this of course in the section of the plugin, which is called `bukkit` in our case.

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

This is the minimal setup. (Commands are not required)
What are we doing here:

1. We define the plugin with the name "MyPlugin"
2. We define our plugin class.  
Please don't main it `Main` and choose a correct namespace.
See my previous [blog post](minecraft_main_class.md).
3. We register a command named `test` with the alias `command`

For further references have a look at the [GitHub page](https://github.com/Minecrell/plugin-yml#bukkit)

The version will be retrieved from your project version by default

### Bukkit Libraries - The better alternative to shading

You probably remember our dependencies section looking like this:

```java
dependencies {
    compileOnly("io.papermc.paper:paper-api:1.20.1-R0.1-SNAPSHOT")
    implementation("de.chojo", "sadu", "1.3.1")
}
```

Previously we had the problem that sadu was not included in our jar.
When we use the `plugin-yml` plugin and are using minecraft 1.16.5, or later, we can use the library loader.
To do this all we need to do is change `implementation` to `bukkitLibrary`:

```java
dependencies {
    compileOnly("io.papermc.paper:paper-api:1.20.1-R0.1-SNAPSHOT")
    bukkitLibrary("de.chojo", "sadu", "1.3.1")
}
```

Now our library will be loaded by spigot/paper when it loads our plugin and will be available during runtime.
This works because sadu is located at maven central and spigot/paper downloads libraries from there.
Libraries which are not located at maven central still need to be shaded.

## Shading dependencies into our jar

Let's assume that sadu is not located at maven central, and we can't use the library loader.

In that case we need to use another plugin called shadow. The latest version currently is ![Gradle Plugin Portal](https://img.shields.io/gradle-plugin-portal/v/com.github.johnrengelman.shadow?label=Version)

### Importing

```java
plugins {
  id("com.github.johnrengelman.shadow") version "version" // (1)!
}
```

1. Replace the version here with the version in the image above

Our dependencies look like this again:

```java
dependencies {
    compileOnly("io.papermc.paper:paper-api:1.20.1-R0.1-SNAPSHOT")
    implementation("de.chojo", "sadu", "1.3.1")
}
```

The purpose of shadow is to copy everything marked as implementation into the output file.

This is already the case when we would execute the `shadowJar` task instead of the `build` task.
However, building our plugin without shadowJar would result in a jar which is simply broken.

### Configuration

We can fix this by telling Gradle that when we execute `build` we actually want to execute `shadowJar`.
We do this by configuring the `build` task to depend on `shadowJar`

```java
tasks {
    build {
        dependsOn(shadowJar)
    }
}
```

#### Relocation

Now that our libraries are shaded we need to do something called relocation.
This is important to avoid conflicts with other plugins if you shade the same library.
To do this we need to configure it, but this time we do not configure the plugin, but the task called `shadowJar`.

```java
tasks {
    shadowJar {
        val mapping = mapOf("de.chojo.sadu" to "sadu")
        val base = "dev.chojo.myplugin.libs."
        for ((pattern, name) in mapping) relocate(pattern, "${base}${name}")
    }
}
```

What this basically does is:

1. We define a map with the packages we want to relocate and the directory we want it to be moved to. 
2. We define the root of the new location of all our shaded libraries
3. For each entry in our map we call the relocation function of our task.

So what does relocation do:  
Consider the class `de.chojo.sadu.Sadu`. After the relocation it will be at `dev.chojo.myplugin.libs.sadu.Sadu`.
Since it is now in your namespace and your plugin it is no longer possible to clash with any other plugin.
Shadow will also replace every path to the class in your code to the new relocated path.

#### Using the output in copy

To use the output of `shadowJar` for our copy task, all you need to change the `jar` task to the `shadowJar` task.

```java
tasks {
    register<Copy>("copyToServer") {
        val props = Properties() 
        val propFile = file("build.properties") 
        if (!propFile.exists()) propFile.createNewFile() 
        file("build.properties").reader().let { props.load(it) }
        val path = props.getProperty("targetDir") ?: "" 
        if (path.isEmpty()) throw RuntimeException("targetDir is not set in build.properties") 
        /*(1)!*/from(shadowJar) 
        destinationDir = File(path)
    }
}
```

1. Change it here

## Working with nms and paperweight

![GitHub release (with filter)](https://img.shields.io/github/v/release/PaperMC/paperweight?label=Latest%20Version)

I do not encourage using nms in any way, but if you want to you should use the `userdev` plugin from `paperweight`.
This allows you to use an unobfuscated jar of paper and gives you a lot of readable variable names.
It also ensures that you do not need to do any code changes when updating to a new version beside the package names.

### Adding the repository

For that we need to do something new and head over to our `settings.gradle.kts` to add a plugin repository.

```java
pluginManagement {
    repositories {
        gradlePluginPortal()
        maven("https://papermc.io/repo/repository/maven-public/")
    }
}
```

For that we need to configure the `pluginManagement` section and change the repositories.
By default, only `gradlePluginPortal()` is imported which contains usually all important plugins until now.
But we want to add another repository now.
It is very important that you add `gradlePluginPortal()` as well as the paper repository.

### Importing

Now we can import the plugin into our `build.gradle.kts` file.

```java
plugins {
    id("io.papermc.paperweight.userdev") version "1.5.5"
}
```

With that only one step is missing and that is to set the paper version

### Configuration

To define the version we want to use we need to add it to our dependencies.
For that we need to remove the old paper compileOnly dependency and replace it with the paperweight dependency.

```java
dependencies {
    paperweight.paperDevBundle("1.20.1-R0.1-SNAPSHOT")
}
```

The version you enter here is the same you used for paper previously. You just remove the group and artifact id.
Paper uses the unobfuscated jar. 
That requires us to actually reobfuscate our jar before building.
We can do this again by configuring a task.
This time we configure the `assemble` task and set a `dependsOn` there.

```java
tasks {
    assemble {
        dependsOn(reobfJar)
    }
}
```

And that's it. 
Now you can use nms as comfortable as possible.

## Run server with your jar

To quickly test your plugin you can directly start up a server.
All you need to do is add the [run-task plugin](https://github.com/jpenilla/run-task) to your build file.

I will refrain from simply copying their readme over here since I can't add any more value to it.

## Thank you!

Thank you for sticking with me till here.
You have now a very good understanding of minecraft development with gradle.
