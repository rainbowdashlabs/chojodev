---
date: 2023-08-10
authors:
  - chojo  
categories:
  - minecraft
  - beginner
  - minecraft common pitfalls
  - common pitfalls
  - java
---

# Logging in Minecraft - The good and better way

[German Version](../de/minecraft_logging.md)

This blog post is about logging and writing information to the console in Minecraft.
There are a lot of ways to write data to the Minecraft console.
And there are a lot of bad or wrong ways to write to the Minecraft console.
We'll start by looking at some bad practices, then move on to the built-in plugin logger, and finish with a look at slf4j.

<!-- more -->

## The five types of logging

As mentioned earlier, there are several ways (at least five) to write to the console.
Let's have a look at them before I explain them.

```java
public final class MyPlugin extends JavaPlugin {
    private static final Logger log = LoggerFactory.getLogger(MyPlugin.class);
    
    @Override
    public void onEnable() {
        System.out.println("Writing via std out");
        Bukkit.getConsoleSender().sendMessage("Writing via console sender");
        Bukkit.getLogger().info("Writing via bukkit logger");
        getLogger().info("Writing via plugin logger");
        log.info("Writing via slf4j logger");
    }
}
```

This results in these outputs:

```log
[15:39:35 INFO]: [MyPlugin] [STDOUT] Writing via std out
[15:39:35 WARN]: Nag author(s): '[]' of 'MyPlugin v1.0.0' about their usage of System.out/err.print. Please use your plugin's logger instead (JavaPlugin#getLogger).
[15:39:35 INFO]: Writing via console sender
[15:39:35 INFO]: Writing via bukkit logger
[15:39:35 INFO]: [MyPlugin] Writing via plugin logger
[15:39:35 INFO]: [dev.chojo.myplugin.MyPlugin] Writing via slf4j logger
```

You may have already noticed some important differences, but let us take a closer look.

## Don'ts

All logging methods in this section are don'ts.
If you are only interested in how to do it properly, jump directly to [dos](#dos)

### Standard output

**Don't do this!**

While `System.out.println` is a valid use case when you need a quick response from your application, there are often much better ways.
In general, it should always be avoided.
It is probably the worst way if you are using Spigot, and still a bad way if you are using Paper.
Paper captures everything a plugin writes to std and actually uses the [plugin logger](#plugin-logger) to write it.
This way the reader actually knows where the print came from.
This is not the case when using Spigot.
People will just end up with a printout like when using the [console sender](#console-sender) or [bukkit logger](#bukkit-logger) method.
You don't know where it came from.

If you use the default out to write, you will also get a nice message on Paper servers:

```log
[15:39:35 INFO]: [MyPlugin] [STDOUT] Writing via std out
[15:39:35 WARN]: Nag author(s): '[]' of 'MyPlugin v1.0.0' about their usage of System.out/err.print. Please use your plugin's logger instead (JavaPlugin#getLogger).
```

It already suggests something else, the [plugin logger](#plugin-logger), which we will look at later.

### Console sender

**Don't do this!**

The console sender is just as bad as standard output, except that it doesn't really tell you where the message came from.
All you get is a simple text with some message that you may or may not understand.

```log
[15:39:35 INFO]: Writing via console sender
```

### Bukkit Logger

**Don't do this!**

While the bukkit logger is actually a logger and can be used as such, it still lacks the information about which plugin sent the message.
The only advantage it has is that it can log exceptions properly.
Other than that, it is still as bad as the [console sender](#console-sender) and [standard out](#standard-output) methods.

```log
[15:39:35 INFO]: Writing via bukkit logger 
```

## Do's

These are the ways to go if you want to write something to the console.

### Plugin Logger

The `Plugin' class provides a method called `#getLogger()`.
This method returns a [Logger](https://docs.oracle.com/javase/8/docs/api/java/util/logging/Logger.html) which allows you to write at different levels and also log exceptions properly.
It also adds the name of your plugin to the top of your log message, so everyone can easily see which plugin sent the message.

To write on different levels you can use these methods:

- `Logger#info(String)`
- `Logger#warning(String)`
- `Logger#severe(String)`

There are more levels like `config`, `fine`, `finer` and `finest`, but if you're using Paper or Spigot, these messages won't appear in your console or log file.
There are workarounds, such as implementing a custom logger that simply delegates to the info level instead, or using reflections to change the logger configuration, but that is beyond the scope of this post.

If you are using the logger, it looks like this:

```java
getLogger().info("This is a info");
getLogger().warning("This is a warning");
getLogger().severe("This is an error");
```
```log
[16:13:08 INFO]: [MyPlugin] This is a info
[16:13:08 WARN]: [MyPlugin] This is a warning
[16:13:08 ERROR]: [MyPlugin] This is an error
```

#### Logging exceptions

While in most cases it may be sufficient to simply write messages, we will probably want to log exceptions at some point.

You may have seen this in many cases:

```java
try {
    throw new RuntimeException("This is not good");
} catch (Exception e) {
    e.printStackTrace();
}
```

<details>
<summary>Output</summary>

```log
[16:13:08 WARN]: java.lang.RuntimeException: This is not good
[16:13:08 WARN]: 	at myplugin-1.0.0.jar//dev.chojo.myplugin.MyPlugin.onEnable(MyPlugin.java:25)
[16:13:08 WARN]: 	at org.bukkit.plugin.java.JavaPlugin.setEnabled(JavaPlugin.java:281)
[16:13:08 WARN]: 	at io.papermc.paper.plugin.manager.PaperPluginInstanceManager.enablePlugin(PaperPluginInstanceManager.java:189)
[16:13:08 WARN]: 	at io.papermc.paper.plugin.manager.PaperPluginManagerImpl.enablePlugin(PaperPluginManagerImpl.java:104)
[16:13:08 WARN]: 	at org.bukkit.plugin.SimplePluginManager.enablePlugin(SimplePluginManager.java:507)
[16:13:08 WARN]: 	at org.bukkit.craftbukkit.v1_20_R1.CraftServer.enablePlugin(CraftServer.java:640)
[16:13:08 WARN]: 	at org.bukkit.craftbukkit.v1_20_R1.CraftServer.enablePlugins(CraftServer.java:551)
[16:13:08 WARN]: 	at net.minecraft.server.MinecraftServer.loadWorld0(MinecraftServer.java:636)
[16:13:08 WARN]: 	at net.minecraft.server.MinecraftServer.loadLevel(MinecraftServer.java:435)
[16:13:08 WARN]: 	at net.minecraft.server.dedicated.DedicatedServer.e(DedicatedServer.java:308)
[16:13:08 WARN]: 	at net.minecraft.server.MinecraftServer.w(MinecraftServer.java:1101)
[16:13:08 WARN]: 	at net.minecraft.server.MinecraftServer.lambda$spin$0(MinecraftServer.java:318)
[16:13:08 WARN]: 	at java.base/java.lang.Thread.run(Thread.java:833)
```

</details>

This is bad, don't do it!

Instead, you need to use the `#log(Level, String, Throwable)` method of your logger.

```java
try {
    throw new RuntimeException("This is not good");
} catch (Exception e) {
    getLogger().log(Level.SEVERE, "Something went wrong", e);
}
```

The [Level](https://docs.oracle.com/javase/8/docs/api/java/util/logging/Level.html) class is a built-in Java class that is part of the `java.util.logging` package.
Calling this method will print your exception nicely, containing a message, the exception message and a stack trace.


!!! warning

    If you cannot make sense of this, I recommend reading this [stackoverflow post](https://stackoverflow.com/a/3988794)

```log
[16:10:43 ERROR]: [MyPlugin] Something went wrong
java.lang.RuntimeException: This is not good
	at dev.chojo.myplugin.MyPlugin.onEnable(MyPlugin.java:25) ~[myplugin-1.0.0.jar:?]
	at org.bukkit.plugin.java.JavaPlugin.setEnabled(JavaPlugin.java:281) ~[paper-api-1.20.1-R0.1-SNAPSHOT.jar:?]
	at io.papermc.paper.plugin.manager.PaperPluginInstanceManager.enablePlugin(PaperPluginInstanceManager.java:189) ~[paper-1.20.1.jar:git-Paper-117]
	at io.papermc.paper.plugin.manager.PaperPluginManagerImpl.enablePlugin(PaperPluginManagerImpl.java:104) ~[paper-1.20.1.jar:git-Paper-117]
	at org.bukkit.plugin.SimplePluginManager.enablePlugin(SimplePluginManager.java:507) ~[paper-api-1.20.1-R0.1-SNAPSHOT.jar:?]
	at org.bukkit.craftbukkit.v1_20_R1.CraftServer.enablePlugin(CraftServer.java:640) ~[paper-1.20.1.jar:git-Paper-117]
	at org.bukkit.craftbukkit.v1_20_R1.CraftServer.enablePlugins(CraftServer.java:551) ~[paper-1.20.1.jar:git-Paper-117]
	at net.minecraft.server.MinecraftServer.loadWorld0(MinecraftServer.java:636) ~[paper-1.20.1.jar:git-Paper-117]
	at net.minecraft.server.MinecraftServer.loadLevel(MinecraftServer.java:435) ~[paper-1.20.1.jar:git-Paper-117]
	at net.minecraft.server.dedicated.DedicatedServer.initServer(DedicatedServer.java:308) ~[paper-1.20.1.jar:git-Paper-117]
	at net.minecraft.server.MinecraftServer.runServer(MinecraftServer.java:1101) ~[paper-1.20.1.jar:git-Paper-117]
	at net.minecraft.server.MinecraftServer.lambda$spin$0(MinecraftServer.java:318) ~[paper-1.20.1.jar:git-Paper-117]
	at java.lang.Thread.run(Thread.java:833) ~[?:?]
```

### The SLF4J logger

Internally, Paper and Spigot uses a framework called [slf4j](https://www.slf4j.org/) with an implementation called [log4j](https://github.com/apache/logging-log4j2).
Even if you use the [plugin logger](#plugin-logger), you are still using the slf4j framework.
So you can actually use it directly.
Instead of prefixing your message with the plugin name, the slf4j logger will prefix your output with the class name that is sending the message.
This gives you even more detail about where the message is coming from.

Aside from its practical use in Minecraft, slf4j is also widely used in other projects, and you will encounter it very often outside the Minecraft world.
This makes it generally good to know if you are going to go out and work with other frameworks and libraries.

To get a logger instance for your class, you need the `LoggerFactory` class, call the `#getLogger(Class)` method and pass your current class.
As this is some lame manual work, you can simply create a [live template](https://www.jetbrains.com/help/idea/using-live-templates.html) for it if you are using IntelliJ.

The live template looks like this (an import template is in the spoiler below):

```java
private static final org.slf4j.Logger log = org.slf4j.LoggerFactory.getLogger($class$.class);
```

<details>
<summary>XML Template for import</summary>

To import this, create a new Java Live template, copy the XML code above and paste it into your newly created template.

```xml
<template name="log" value="private static final org.slf4j.Logger log = org.slf4j.LoggerFactory.getLogger($class$.class);" description="insert a default logger" toReformat="false" toShortenFQNames="true" useStaticImport="true">
  <variable name="class" expression="className()" defaultValue="className()" alwaysStopAt="false" />
  <context>
    <option name="JAVA_DECLARATION" value="true" />
  </context>
</template>
```

</details>

If you register this with the abbreviation `log`, all you have to do is type `log` in your class and the logger will be inserted.
You will end up with something like this:

```java
private static final Logger log = LoggerFactory.getLogger(MyPlugin.class);
```

Using this logger instance is very similar to using the [plugin logger](#plugin-logger), but there are some differences.

Let's look at basic logging first.

```java
log.info("This is a info");
log.warn("This is a warning");
log.error("This is an error");
```

```log
[16:32:03 INFO]: [dev.chojo.myplugin.MyPlugin] This is a info
[16:32:03 WARN]: [dev.chojo.myplugin.MyPlugin] This is a warning
[16:32:03 ERROR]: [dev.chojo.myplugin.MyPlugin] This is an error
```

You can see that we now have the plugin class as a prefix to our message.
Instead of `warning` we now use `warn` and instead of `severe` we use `error`.

#### Logging exceptions

Logging exceptions is easier with slf4j.
All we need to do is pass it as a second argument after our message.

```java
try {
    throw new RuntimeException("This is not good");
} catch (Exception e) {
    log.error("Something went wrong", e);
}
```

The output remains the same as with [plugin logger](#plugin-logger), except that we now have the class prefix again.

<details>
<summary>Output</summary>

```log
[16:34:49 ERROR]: [dev.chojo.myplugin.MyPlugin] Something went wrong
java.lang.RuntimeException: This is not good
	at dev.chojo.myplugin.MyPlugin.onEnable(MyPlugin.java:40) ~[myplugin-1.0.0.jar:?]
	at org.bukkit.plugin.java.JavaPlugin.setEnabled(JavaPlugin.java:281) ~[paper-api-1.20.1-R0.1-SNAPSHOT.jar:?]
	at io.papermc.paper.plugin.manager.PaperPluginInstanceManager.enablePlugin(PaperPluginInstanceManager.java:189) ~[paper-1.20.1.jar:git-Paper-117]
	at io.papermc.paper.plugin.manager.PaperPluginManagerImpl.enablePlugin(PaperPluginManagerImpl.java:104) ~[paper-1.20.1.jar:git-Paper-117]
	at org.bukkit.plugin.SimplePluginManager.enablePlugin(SimplePluginManager.java:507) ~[paper-api-1.20.1-R0.1-SNAPSHOT.jar:?]
	at org.bukkit.craftbukkit.v1_20_R1.CraftServer.enablePlugin(CraftServer.java:640) ~[paper-1.20.1.jar:git-Paper-117]
	at org.bukkit.craftbukkit.v1_20_R1.CraftServer.enablePlugins(CraftServer.java:551) ~[paper-1.20.1.jar:git-Paper-117]
	at net.minecraft.server.MinecraftServer.loadWorld0(MinecraftServer.java:636) ~[paper-1.20.1.jar:git-Paper-117]
	at net.minecraft.server.MinecraftServer.loadLevel(MinecraftServer.java:435) ~[paper-1.20.1.jar:git-Paper-117]
	at net.minecraft.server.dedicated.DedicatedServer.initServer(DedicatedServer.java:308) ~[paper-1.20.1.jar:git-Paper-117]
	at net.minecraft.server.MinecraftServer.runServer(MinecraftServer.java:1101) ~[paper-1.20.1.jar:git-Paper-117]
	at net.minecraft.server.MinecraftServer.lambda$spin$0(MinecraftServer.java:318) ~[paper-1.20.1.jar:git-Paper-117]
	at java.lang.Thread.run(Thread.java:833) ~[?:?]
```

</details>

#### Using placeholders in messages

slf4j has a nice feature for placeholders.
To add additional information to your message, you can define placeholders with `{}` and pass the values after your message in the correct order.

```java
log.info("Hello {}. How was your {}? Is it already past {}?", "Chojo", "day", 2);
```

```log
[16:39:49 INFO]: [dev.chojo.myplugin.MyPlugin] Hello Chojo. How was your day? Is it already past 2?
```

You can see that the values are simply inserted into your message.

This also works with exceptions.
Just make sure that your last argument is the exception itself, and that any replacements are specified first.

```java
var first = 5;
var second = 0;
try {
    var result = first / second;
} catch (Exception e) {
    log.error("I tried to divide {} through {} and it went up in flames", first, second, e);
}
```

```log
[16:39:49 ERROR]: [dev.chojo.myplugin.MyPlugin] I tried to divide 5 through 0 and it went up in flames
java.lang.ArithmeticException: / by zero
	at dev.chojo.myplugin.MyPlugin.onEnable(MyPlugin.java:51) ~[myplugin-1.0.0.jar:?]
    at ... #Shortened by me
```

Works like a charm and makes it very easy to add extra information to your output message!

## Adding a prefix

While adding a prefix when using any of the methods in the [don't](#donts) section might help a bit, it's still bad.
Why use a bad way when there are good ways.

## Thank you!

Now you know how to log into your Minecraft project properly!

{{ blog_footer_en }}
