---
date: 2023-08-03
authors:
  - chojo  
categories:
  - minecraft
  - beginner
  - minecraft common pitfalls
  - common pitfalls
  - java
---

# The plugin main class. A constant naming discussion!

[German Version](../de/minecraft_main_class.md)

The minecraft main class, or the class which usually extends `JavaPlugin`, is nearly always subject of discussions when 
it comes to naming. 
In this post I try to explain my point of view, and also show my approach on naming them.

<!-- more -->

To understand why we always discuss this, we first have to understand what the so called `Main` class actually is.

## The java main class

In java, the main class is the class which holds the main method `public static void main(String... args)`.
The class holding the main method itself does already not need to be named `Main`.
This `main` method serves as the entry point into our application.
Usually people create their application instance here and build up the startup logic of their application.
Without this method our application would never do anything and can not be executed.
When we build our application, we also need to point to our main class in our build file, to tell the jvm where to 
actually find our main class.

## The plugin "main" class

The class we call main in our plugins has some very clear differences.

1. We don't have the main method.
2. We do not create our own instance of our plugin/application.
3. We don't have a single entrypoint into our application. In fact, we have at least three:
    - Constructor - When the server creates our instance
    - onLoad - When the server loads our plugin
    - onEnable - When the server enables our plugin
4. The jvm does not call our main methods itself, but the server does.

_"But I declare my main class in the plugin.yml"_ you might say.
Yes we do, however this naming is probably the main issue we have till today.

What we actually declare is not a main class as defined by java, but point at a class extending `JavaPlugin` or `Plugin`.
The correct naming for this parameter should probably be `plugin_class` or just `plugin`.
It is not a main class by all means, as defined by java.

## The "ideal" name

I personally go with `tld.domain.pluginname.PluginName` or `tld.domain.pluginname.PluginNamePlugin`

A plugin with the name `Maya` by me using the domain `chojo.dev` would then be named: `dev.chojo.maya.Maya` or 
`dev.chojo.maya.MayaPlugin`

This won't be by far the holy grail for naming.
However, this solves two big issues:

### 1. Namespace conflicts

On minecraft servers we always share the server with multiple plugins which are most probably not written all by 
ourselves.
We might run our plugin on a server with 50 or even 100 other plugins.
Therefore, it is important that we choose a unique namespace which is `tld.domain`.
Furthermore, we need to avoid conflicts with our own plugins.
That's why we add our `pluginname` as well and end up with `tls.domain.pluginname`.
Of course, we now have a unique namespace for our plugin already, and we could easily call our class main.
I personally prefer to call my class like I call my plugin, so `PluginName` or `PluginNamePlugin` to make clearer 
that the class extends the Plugin class.

### 2. Class name conflict

_"Why not call it Main?"_ 
For that to understand, you have to think about the users of your plugin.
Or just think about it in general, if everyone would call their plugin class `Main`.
When using an api of a plugin you use the plugin class in at least 90% of the cases.
Imagine searching it, and you get a list of 6 Main classes by 6 different plugins.
A good start for errors and confusion already.

Or if you use multiple apis or plugin classes in your own plugin by others you would probably end up with something 
like this:

```java
dev.someone.nele.Main nele = dev.someone.nele.Main.getInstance();
dev.someone.lara.Main lara = dev.someone.lara.Main.getInstance();
dev.someone.maya.Main maya = dev.someone.maya.Main.getInstance();
```

Instead, if you follow the naming mentioned above, it would look like this:

```java
NelePlugin nele = NelePlugin.getInstance();
LaraPlugin lara = LaraPlugin.getInstance();
MayaPlugin maya = MayaPlugin.getInstance();
```

Isn't this much more readable?
We avoid not only namespace conflicts but also class name conflicts. 
We communicate clearly that our class is a plugin and also directly show our plugins name with it as well.

## I don't have a domain

That is not a problem. You probably have a GitHub or GitLab account already and if not I strongly recommend to make one.
We use domains because we know that only we use it (ideally).
So everything you need is something unique that is bound to you, which is the case when you have a GitHub or GitLab account.
In that case you can use `io.github.username` or `io.gitlab.username` as your namespace.
You can even use this namespace for publishing to maven central!

## Conclusion

Plugins should use their own namespace usually using an inversed domain `tld.domain`, followed by the plugin name 
`pluginname`. 
The plugin class itself should contain the name of the Plugin, optionally suffixed with `Plugin` to show that it is 
a plugin class.

So next time you create and name your plugin class (not main class), consider this and choose a better name to make 
a better world!

{{ blog_footer_en }}
