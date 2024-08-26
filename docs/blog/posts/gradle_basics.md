---
date: 2024-08-26
authors:
  - chojo
categories:
  - beginner
  - gradle
  - java
---

# Gradle Basics

This blog post is about the basics of gradle. It is part of a longer series focusing on different build approaches using gradle. I will link further in depth posts for specific topics at the end of the post. During the Blog post I will show a lot of snippets. Those snippets will be mostly shorted and previously added stuff will not be shown. You will find spoilers sometimes that include the full files. Check those if you get lost on how your build file should look like.

This blogpost will mainly cover the general structure of gradle files, more precisely the `gradle.build` and `gradle.settings` files.
<!-- more -->

## What is Gradle

Before we start with using Gradle, we should clear up what Gradle is.

Gradle is a so-called project management system. Some refer to is as build tool as well.
Both are technical right. Gradle manages your project by allowing you to define your dependencies. In the end gradle will build your project depending on your build definition.

To manage your project gradle uses a so-called **domain specific language** or **DSL** in short form.
This language can be currently Groovy or Kotlin. While Groovy is older, Kotlin gains more and more popularity as a DSL and is considered the way to go today. You can see that you are using Kotlin as your DSL if your `gradle.build` file ends with `.kts`. The same goes for your `gradle.settings` file. So if your files are named `gradle.build.kts` and `gradle.settings.kts` you are on the right track.

It is also important that the DSL has nothing to do with the language you use for your project. You can use Kotlin as your DSL and still write your programm with Java or any other supported language

Since gradle uses a DLS to define your build logic, you are much more flexible compared to Maven. Where you would need a ton of xml or plugins in Maven, Gradle usually just needs a couple of Kotlin or Groovy code.

The general approach of gradle is that we use plugins to allow certain actions, which are named tasks. Those tasks usually depend on each other and are executed in a predefined order. We as the user can usually configure the plugin itself and the tasks, that the plugin added. We can also define own tasks, that for example depend on some other task or that are run as a standalone task.

But that's enough for now. Time to actually set up our gradle project.

## Install Gradle

If you are using Intellij, you actually don't need to worry about this step.
Gradle is already bundled in IntelliJ, and you don't need to install it. You will simply use the wrapper, which will be explained in the next section.

If you are using other IDEs I strongly suggest switching to intellij. Most projects will have a gradle wrapper in it, so installing gradle locally isn't usually necessary anymore, unless you don't use IntelliJ and want to set up a new Project.

So if you for any reason need to install Gradle, you should refer to their official [documentation](https://gradle.org/install/) or install with the package manager of your choice.

## The Gradle Wrapper

The Gradle wrapper is essentially a portable Gradle installation.
It does not require a Gradle installation on the system and can be used to build anywhere.
Gradle releases frequent updates and the wrapper should ideally be updated to the latest version. To update this version you only need one command:

```shell
./gradlew wrapper --gradle-version={{ gradle }} --distribution-type=bin
```

This works on Unix systems as well as in Windows PowerShell or git bash.
If you are using windows cmd, you will need to use `gradlew.bat` instead.

Check the [Gradle website](https://gradle.org/releases/) for the latest version.

If you have a gradle project that lacks a wrapper, the command above will create it for you. But for that you will need to have some gradle version installed on your system and use `gradle` instead of `./gradlew` at the start of the command.

## Setting up a Gradle Project

=== "Using IntelliJ"

    ![img.png](../../assets/images/gradle_setup.png)
    
    We will look at the marks one after another. 
    Most of the settings will be set by default already.
    
    1. We select **New Project**
    2. We add our project id aka name.  
    This name is your **plugin name in lower case** with `-` where a space would be.  
    So `MyPlugin` becomes `my-plugin`
    3. Make sure that a **git repository** will be created
    4. Select **Java** as language or **Kotlin** if you like this more, but I will only use Java here.
    5. Select **Gradle as build system**
    6. Select **Kotlin as Gradle DSL** 
    7. Let intellij add some sample code.  
    This will be removed later, but will create the most important directories.
    8. Select the wrapper as your Gradle distribution
    9. Enter the latest Gradle version, as mentioned on the [Gradle website](https://gradle.org/releases/).  
    This may not be available to select in the drop down menu, but you can enter it yourself.
    10. Enter your group id here.
    If you don't know what to write here have a log at my other [post](minecraft_main_class.md#1-namespace-conflicts)
    If you don't have a domain, see [here](minecraft_main_class.md#i-dont-have-a-domain)
    11. This is the same as your name in **2.**

=== "Using Eclipse"

    Sorry Eclipse users.
    Time to use an actually good IDE.
    Switch to IntelliJ c:

=== "Using CLI"

    If you already have a project, you can easily set it up from the command line.
    If your project is currently a Maven project, Gradle will offer to convert it to a Gradle project.

    We will look at how to set up a new Gradle project without importing anything from Maven.
    
    First we start by initialising Gradle with `Gradle init`.
    We're using the installed version of Gradle for this, so you need to have it installed.
    
    You will end up with this dialogue
    ```
    Select type of project to generate:
      1: basic
      2: application
      3: library
      4: Gradle plugin
    Enter selection (default: basic) [1..4]
    ```
    Choose 1 here by simply typing `1`, or just hit enter since `basic` is the default.
    This will create a basic Gradle project.

    If you want to create a library instead, you can choose `3`.
    However, all this does is to apply some basic plugins beforehand, which we will get through later anyway.
    
    
    The next step is to select the language for our Gradle DSL
    ```
    Select build script DSL:
      1: Kotlin
      2: Groovy
    Enter selection (default: Kotlin) [1..2]
    ```
    Again, choose 1 by typing `1` or just hit enter since Kotlin is the default.

    Now we need to enter our project name.
    I recommend using your plugin name in lower case and adding `-` where there would be spaces.
    So `MyPlugin` becomes `my-plugin`.
    ```
    Project name (default: directory): 
    ```

    Next is a question about Gradle stuff.    
    ```
    Generate build using new APIs and behavior (some features may change in the next minor release)? (default: no) [yes, no] 
    ```
    I recommend using the default no. So just press enter or type `no`.
    And you're done.

## Gradle files

Now you have a bunch of new files and directories.
Let's go through them one by one.

### .gradle

The `.gradle` directory contains internal gradle data.
It should be added to your gitignore if not done already.

### gradle directory

The `gradle` directory contains the wrapper directory, which in turn contains a `gradle-wrapper.jar`, which is your Gradle wrapper.
This is your portable Gradle installation as mentioned earlier.

The `gradle-wrapper.properties` contains the settings of the wrapper.
The most important part is the version.
You can also change it here if you forgot to use the command shown in the previous [section](#the-gradle-wrapper).

This directly should always be pushed to git

### gradlew and gradlew.bat

These are the Gradle wrapper files. You use them to execute your gradle wrapper.

- `gradlew` for Unix systems, Windows powershell and git bash on Windows.
- `gradlew.bat` for the windows cmd

### build.gradle.kts

The `build.gradle.kts` is the heart of our project.
Almost all the configuration of our project is done in this file.
It contains dependencies, repositories and lots of other stuff.
We will go over the sections in here in depth,

### settings.gradle.kts

The `settings.gradle.kts` can be used to apply project wide settings such as plugin repositories (not dependency repositories!).
You can also define submodules here if you have a multi-module project, or create a [version catalogue](https://docs.gradle.org/current/userguide/platforms.html).
Currently, it only holds our project name.

### src directory

While this directory is not strictly seen as part of Gradle, it is still important to have a specific structure:

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

If these directories do not exist in your src directory, please create them.

If you are creating a Kotlin project instead of a Java project the `java` directory will be named `kotlin` instead.

the `src/main` directory contains your programm logic and resources which will be compiled and moved into your jar in the end.

The `src/test` directory is for unit testing.

## The basic build.gradle.kts

Let's start by taking a look at our build.gradle.kts.
It should be empty at the moment if you used the cli approach, or already have some stuff in it if you set it up using IntelliJ.

Let's get you on the same page by adding some sections to start with a fresh file.

### The plugin section

The top section of our file will always be the `plugins` section.
So we start by adding it first.

```java
plugins {
}
```

The whole logic of Gradle is that plugins add tasks that we execute.
Since we want to build a Java application, we need to add the `java` plugin.
This can be done by simply adding `java` to the `plugins` block.

```java
plugins {
    java
}
```

And that's it. We are done with our plugin setup for now.

While we have added the java plugin now to our project, it lacks the configuration. Usually plugins have some kind of general configuration block, beside the tasks they add.

#### Plugin import syntax

We imported the java plugin with the short import syntax.
This can be done with every plugin that is bundled with gradle already.
If our plugin name is not only consisting of letters we need to quote our plugin with backticks. The `maven-publish` plugin would be imported like this:

```java
plugins {
    `maven-publish`
}
```

The normal syntax for importing a bundled plugin would be actually like this:

```java
plugins {
    id("java")
}
```

If you need to import a plugin that is not bundled in gradle you need to also supply a version. In that case all you need to do is to define the version of the plugin after the id.

```java
plugins {
  id("{{ VC_PLUGIN_SHADOW_ID }}") version "{{ VC_PLUGIN_SHADOW_VERSION }}"
}
```


<details>
<summary>Checkpoint</summary>

```java
plugins {
    java
}
```

</details>


### Declare group and version

Now we need to declare our group and version.
This is not a section, just two values we assign.
Your group id, if not already set, should be a domain you **own** in reverse order.
If you don't have a domain, see my other [post](minecraft_main_class.md#i-dont-have-a-domain).
I recommend using [semantic versioning (semver)](https://dev.to/nialljoemaher/an-introduction-to-semantic-versioning-26n9) for your version.

```java
group = "dev.chojo" // Please use your own group id c:
version = "1.0.0-SNAPSHOT"
```


<details>
<summary>Checkpoint</summary>

```java
plugins {
    java
}

group = "dev.chojo" // Please use your own group id c:
version = "1.0.0-SNAPSHOT"
```
</details>

### Repositories section

The repositories section is where we define which repositories our dependencies will be in.

The repository section looks like this:
```java
repositories {

}
```

!!! note
    **Order is important!**
    
    The order in which you assign repositories in this section is the order in which Gradle will search for dependencies.
    It will take the first found location where the dependency exists.


To add a repository, we can use two different ways.

#### Predefined Repositories

Gradle provides convenience functions to import common repositories

- `mavenCentral()`   
  This is the Maven Central repository where most of the dependencies we will need are located.
  If you have been using Maven: With Maven you did not need to import this specifically, but with Gradle you will need to do so.
- `mavenLocal()`
  This imports your local maven repository. This should usually not be used on public sources since it breaks the assumption that a project can be build everywhere.

#### Custom repositories

If a dependency happens to not be located in the Maven Central repository or your local Maven repository, we need to import a custom repository. You can easily do that with the `maven()` function. 

```java
repositories {
    maven("https://papermc.io/repo/repository/maven-public/")
}
```
This will import the `paper-mc` repository. Of course, you can do the same with any other repository.


<details>
<summary>Checkpoint</summary>

```java
plugins {
    java
}

group = "dev.chojo" // Please use your own group id c:
version = "1.0.0-SNAPSHOT"

repositories {
    mavenCentral()
}
```

</details>

### Dependencies section

!!! note

    If you have test imports from junit here, you can delete them for now.

Inside the dependencies section, we can define two different dependency types for now:

```java
dependencies {
    compileOnly("{{ VC_LIBRARY_PAPER_FULL }}")
    implementation("{{ VC_LIBRARY_SADU_GROUP }}", "{{ VC_LIBRARY_SADU_NAME }}", "{{ VC_LIBRARY_SADU_VERSION }}")
}
```

!!! note

    SADU is here only for demonstration purposes and not mandatory required

I have used two different ways of declaring dependencies here.
Both are valid.
You can either declare them as one string or as three separate strings.

[SADU](https://github.com/rainbowdashlabs/sadu) is a library I wrote to make using databases easier for beginners. Have a look at it c:

When we run our application we rely on the classes we are using to be there. In java there are multiple ways to make those classes of our dependency available.
In this step we don't care yet how those classes will be made available. At this point we only care about who is responsible that the classes will be there. 


=== "As implementation"

    If we are responsible for the classes to be there, we use `implementation`. This is for example the case when we write a Minecraft plugin for a paper server and we want to use a library that is not included in paper.

=== "As compileOnly"

    The `compileOnly` import means that the classes we are depending on will be there and that we are not responsible to ensure that they are there.
    If we stay in the Minecraft context, that means that every other plugin like FAWE, LuckPerms and in general any other api by other plugins or the server itself will be imported as `compileOnly`.
    APIs that are not available as plugins on the server, which can be the case for Inventory APIs for example, must of course be imported as an `implementation`.

!!! note

    There are other types of import like `runtimeOnly`, but those two are the most important for now.

### Tasks section

!!! note

    You can delete anything currently in your tasks section    

I told you earlier that everything in Gradle works with tasks.
So there has to be a way to configure them, and this is where the tasks section comes in.
For now, we will just start with a simple empty section.
In the next section you will see how we configure a task of the java plugin.


```java
tasks {

}
```

## Configuring Java

Now that we have all the necessary sections in our file, we can finally start configuring our project.

As told previously plugins provide tasks and usually some own configuration for the plugin itself.
Currently, the only plugin we have imported is java, so we need to configure it.
As we have a `dependency`, `repositories` and `tasks` sections, plugins can add own sections to our build file. Those sections are also called `extension`.
Those are not added automatically, but we can easily access them by writing the plugin name and opening a code block.

```java
java {
    
}
```

!!! note

    That the plugin configuration can be opened with the plugin name is a best practice.
    While most plugins adhere to this, it is not always the case.
    Consult the documentation of the plugin if you are unsure.


This will give us access to the configuration of our java plugin.

```java
java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(21)
    }
    withSourcesJar()
    withJavadocJar()
}
```

For `java` we set the so-called toolchain.
The toolchain controls the version of java used in our project.
If you want to import a dependency compiled with java 21, you need to set your toolchain to 21 as well.
On the other hand, using a java 21 toolchain will still allow you to import any dependency using an older version of java.

We also define that we want to build a source jar and a javadoc jar.
This may not be important to us now, but it may be in the future.
It doesn't hurt to have it in the end.

!!! note

    When you create a javadoc jar, you get a warning for every missing comment on classes and methods. If you don't work on a public library or plugin you can ignore them or remove the `withJavadocJar()` call. If you work on a public library, I highly recommend to comment your code instead 

In addition to configuring our java plugin, we also want to configure its tasks.
There are three tasks of interest to us:

=== "compileJava"

    This task is responsible for compiling our Java code.

=== "compileJavaTest"

    This task handles the compilation of our test code written in Java.
    Although we do not have any tests yet, it cannot hurt to define them anyway.

=== "javadoc"

    This handles how our javadocs are built.

All we want to define for these tasks is that we want to use `UTF-8` encoding for them.
This will avoid weird characters when using special characters.

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

!!! note

    On newer versions, the use of `UTF-8` is the default.
    I keep it here because its a good example for easy task configuration.

And that's the configuration for our Java plugin.


<details>
<summary>Checkpoint</summary>

```java
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
    implementation("de.chojo.sadu", "sadu", "2.2.5")
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
```

</details>

## Building the plugin

There is nothing stopping us from building our application now.
While we could stop here and just be happy that it works, there is still a lot (and by that I mean A LOT) of room for improvement.
We also still have to fix the problem of not including our library that we previously imported with `implementation`.
So while you might be tempted to call it a day, I highly recommend you keep reading!

For now, I will just show you the two ways to run a Gradle task.

!!! note

    You can run not only the build task with this, but **any other task** as well.
    If you are using IntelliJ you can have a look at the other tasks that are available.

=== "Via cli"

    Go into your cli and run `./gradlew build' or `gradlew.bat build' depending on your operating system.

=== "Via IntelliJ"

    Open the Gradle window on the right. Go to Tasks -> Build and run the build task by clicking on it.

    ![Gradle task view](../../assets/images/gradle_build.png)

### Getting the build file

You will now find your application in `build/libs/myproject.jar`.

Thank you for sticking with me so far.
You now have a very good understanding of the structure of a gradle file.
Its time now to choose your path c:

- [Minecraft Specific Gradle](gradle_basics_minecraft.md)
- [Bundle dependencies with shadow](gradle_basics_bundle_shadow.md)
- [Bundle dependencies with application plugin](gradle_basics_bundle_application.md)

{{ blog_footer_en }}

