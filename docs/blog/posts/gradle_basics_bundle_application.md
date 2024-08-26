---
date: 2024-08-26
authors:
  - chojo
categories:
  - beginner
  - gradle
  - java
---

# Gradle Application Plugin

The application plugin is included in Gradle and is a nice alternative to shadow when your application is standalone.
For example a webservice or Discord bot.
It is however not useful, when your application is a minecraft plugin.
Please see the [minecraft](gradle_basics_minecraft.md) post for that.

<!-- more -->

For this post I will assume that you have the build files we ended up with in the previous [post](gradle_basics.md).

## What is the application plugin

The application plugin is bundled in gradle and one of the easiest way to ship your application.
It creates a zip and tar archive that contains the jar of all our external dependencies and our own jar.
It also creates a start script for our application, that we can execute to start our application.

## Apply the application plugin

To apply the application plugin we add it into our plugins section

```java
plugins {
    java
    application
}
```

All that is left now is some minimal configuration or the application plugin, which at least requires to define the main class.
For simplicity my main class is located at `dev.chojo.myapp.Main`.

```java
application {
    mainClass = "de.chojo.myapp.Main"
}
```

Additionally, we can also provide some default JVM arguments for our app.

```java
application {
    mainClass = "de.chojo.myapp.Main"
    applicationDefaultJvmArgs = listOf("-Dapp.language=en_US")
}
```

## Run our application

Now that we have configured our application plugin we can use the tasks that it is providing to run our application directly.
For that we simply run the run task either via the gradle tab in IntelliJ or via cli with `./gradlew run` and `gradlew.bat run`.

## Build and distribute our application

To distribute our application we can still simply execute our build task as before.
The application plugin hooks into gradle and tells it that the build process is depending on it.
Once we execute our build task we find our distribution under `build/libs/distributions`.
You can now choose between a tar or zip depending on your liking.
This jar contains our own application jar and the jar of every dependency imported as `implementation` in our build file.

## Executing the application

To run our application we need to unzip the tar or zip and execute the sh or bat file inside the `bin` directory.
And that's already it.
Your application can run everywhere, where java is installed.

## Thank you

Now you know the basics of the application plugin for gradle.
If you want to know more I recommend looking at the official [documentation](https://docs.gradle.org/current/userguide/application_plugin.html).

{{ blog_footer_en }}
