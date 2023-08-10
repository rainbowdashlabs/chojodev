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

[English Version](../posts/minecraft_logging.md)

In diesem Blogpost geht es um das Loggen und das Schreiben von Informationen in die Konsole von Minecraft.
Es gibt eine Menge Möglichkeiten, Daten in die Minecraft-Konsole zu schreiben.
Und es gibt eine Menge schlechter oder falscher Wege, in die Minecraft-Konsole zu schreiben.
Wir fangen damit an, uns einige schlechte Praktiken anzusehen, gehen dann zum eingebauten Plugin-Logger über und schließen mit einem Blick auf slf4j.

<!-- more -->

## Die fünf Arten des Loggings

Wie bereits erwähnt, gibt es mehrere Möglichkeiten (mindestens fünf), in die Konsole zu schreiben.
Schauen wir uns diese an, bevor ich sie erkläre.

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

Daraus ergeben sich die folgenden Ergebnisse:

```log
[15:39:35 INFO]: [MyPlugin] [STDOUT] Writing via std out
[15:39:35 WARN]: Nag author(s): '[]' of 'MyPlugin v1.0.0' about their usage of System.out/err.print. Please use your plugin's logger instead (JavaPlugin#getLogger).
[15:39:35 INFO]: Writing via console sender
[15:39:35 INFO]: Writing via bukkit logger
[15:39:35 INFO]: [MyPlugin] Writing via plugin logger
[15:39:35 INFO]: [dev.chojo.myplugin.MyPlugin] Writing via slf4j logger
```

Vielleicht hast du schon einige wichtige Unterschiede bemerkt, aber lass uns einen genaueren Blick darauf werfen.

## Schlecht

Alle Logging-Methoden in diesem Abschnitt sind Don'ts.
Wenn du nur daran interessiert bist, wie man es richtig macht, spring direkt zu [gut](#gut)

### Standard output

**So nicht!**

`System.out.println` ist zwar eine gute Möglichkeit, wenn du eine schnelle Antwort von deiner Anwendung brauchst, aber es gibt oft viel bessere Wege.
Generell sollte dies immer vermieden werden.
Es ist wahrscheinlich der schlechteste Weg, wenn du Spigot verwendest, und immer noch ein schlechter Weg, wenn du Paper verwendest.
Paper erfasst alles, was ein Plugin nach std schreibt, und verwendet den [plugin logger](#plugin-logger), um es zu schreiben.
Auf diese Weise weiß der Leser, woher die Nachricht stammt.
Das ist bei der Verwendung von Spigot nicht der Fall.
Die Leute bekommen dann nur eine Nachricht wie bei der Methode [console sender](#console-sender) oder [bukkit logger](#bukkit-logger).
Du weißt nicht, woher diese Nachricht kommt.

Wenn du die Standardausgabe zum Schreiben verwendest, bekommst du auch eine schöne Nachricht auf Paperservern:

```log
[15:39:35 INFO]: [MyPlugin] [STDOUT] Writing via std out
[15:39:35 WARN]: Nag author(s): '[]' of 'MyPlugin v1.0.0' about their usage of System.out/err.print. Please use your plugin's logger instead (JavaPlugin#getLogger).
```

Es schlägt bereits etwas anderes vor, den [plugin logger](#plugin-logger), den wir uns später ansehen werden.

### Console sender

**So nicht!**

Der Console Sender ist genauso schlecht wie die Standardausgabe, nur dass er dir wirklich nicht sagt, woher die Nachricht kommt.
Du bekommst nur einen einfachen Text mit einer Nachricht, die du vielleicht verstehst, vielleicht aber auch nicht.

```log
[15:39:35 INFO]: Writing via console sender
```

### Bukkit Logger

**So nicht!**

Der Bukkit-Logger ist zwar ein Logger und kann auch als solcher verwendet werden, aber es fehlt ihm die Information, welches Plugin die Nachricht gesendet hat.
Der einzige Vorteil ist, dass er Fehler richtig darstellen kann.
Ansonsten ist er immer noch genauso schlecht wie die Methoden [console sender](#console-sender) und [standard out](#standard-output).

```log
[15:39:35 INFO]: Writing via bukkit logger 
```

## Gut

Dies sind die richtigen Wege, wenn du etwas in die Konsole schreiben willst.

### Plugin Logger

Die Klasse `Plugin` bietet eine Methode namens `#getLogger()`.
Diese Methode gibt einen [Logger](https://docs.oracle.com/javase/8/docs/api/java/util/logging/Logger.html) zurück, mit dem du auf verschiedenen Leveln schreiben und auch Fehler richtig ausgeben kannst.
Sie fügt außerdem den Namen deines Plugins am Anfang der Nachricht ein, so dass jeder sehen kann, welches Plugin die Nachricht gesendet hat.

Um auf verschiedenen Leveln zu schreiben, kannst du diese Methoden verwenden:

- `Logger#info(String)`
- `Logger#warning(String)`
- `Logger#severe(String)`

Es gibt noch weitere Levels wie `config`, `fine`, `finer` und `finest`, aber wenn du Paper oder Spigot verwendest, werden diese Nachrichten nicht in deiner Konsole oder Logdatei erscheinen.
Es gibt Umgehungsmöglichkeiten, z. B. die Implementierung eines benutzerdefinierten Loggers, der stattdessen einfach an die Info-Ebene delegiert, oder die Verwendung von Reflections, um die Konfiguration des Loggers zu ändern, aber das würde den Rahmen dieses Beitrags sprengen.

Wenn du den Logger verwendest, sieht das so aus:

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

#### Logging Exceptions

Obwohl es in den meisten Fällen ausreicht, einfach nur Nachrichten zu schreiben, werden wir wahrscheinlich irgendwann Fehler ausgeben wollen.

Du hast vielleicht das schon in vielen Fällen gesehen:

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

Das ist schlecht, tu es nicht!

Stattdessen musst du die Methode `#log(Level, String, Throwable)` deines Loggers verwenden.

```java
try {
    throw new RuntimeException("This is not good");
} catch (Exception e) {
    getLogger().log(Level.SEVERE, "Something went wrong", e);
}
```

Die Klasse [Level](https://docs.oracle.com/javase/8/docs/api/java/util/logging/Level.html) ist eine Java-Klasse, die Teil des Pakets `java.util.logging` ist.
Wenn du diese Methode aufrufst, wird dein Fehler schön ausgegeben. Deine Ausgabe enthält deine Nachricht, die Fehlermeldung und einen Stacktrace.


!!! warning "Achtung"

    Wenn du das nicht lesen und verstehen kannst, empfehle ich dir, diesen [Stackoverflow-Beitrag](https://stackoverflow.com/a/3988794) zu lesen.

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

### Der SLF4J logger

Intern verwendet Paper and Spigot ein Framework namens [slf4j](https://www.slf4j.org/) mit einer Implementierung namens [log4j](https://github.com/apache/logging-log4j2).
Auch wenn du den [plugin logger](#plugin-logger) verwendest, benutzt du immer noch das slf4j-Framework.
Du kannst es also auch direkt verwenden.
Anstatt deiner Nachricht den Namen des Plugins voranzustellen, stellt der slf4j-Logger deiner Ausgabe den Namen der Klasse voran, welche die Nachricht sendet.
Dadurch erhältst du noch mehr Informationen darüber, woher die Nachricht kommt.

Abgesehen von seinem praktischen Einsatz in Minecraft wird slf4j auch in anderen Projekten häufig verwendet und du wirst es auch außerhalb von Minecraft sehr häufig antreffen.
Deshalb ist es generell gut zu kennen, wenn du mit anderen Frameworks und Bibliotheken arbeiten willst.

Um eine Logger-Instanz für deine Klasse zu erhalten, brauchst du die Klasse `LoggerFactory`, rufst die Methode `#getLogger(Class)` auf und übergibst deine aktuelle Klasse.
Da dies langweilige Handarbeit ist, kannst du einfach ein [Live Template](https://www.jetbrains.com/help/idea/using-live-templates.html) dafür erstellen, wenn du IntelliJ verwendest.

Das Live-Template sieht wie folgt aus (eine Importvorlage findest du im Spoiler unten):
```java
private static final org.slf4j.Logger log = org.slf4j.LoggerFactory.getLogger($class$.class);
```

<details>
<summary>XML Template zum importieren</summary>

Um dies zu importieren, erstelle eine neue Java Live-Vorlage, kopiere den obigen XML-Code und füge ihn in deine neu erstellte Vorlage ein.

```xml
<template name="log" value="private static final org.slf4j.Logger log = org.slf4j.LoggerFactory.getLogger($class$.class);" description="insert a default logger" toReformat="false" toShortenFQNames="true" useStaticImport="true">
  <variable name="class" expression="className()" defaultValue="className()" alwaysStopAt="false" />
  <context>
    <option name="JAVA_DECLARATION" value="true" />
  </context>
</template>
```

</details>

Wenn du dies mit der Abkürzung `log` registrierst, musst du nur noch `log` in deine Klasse eingeben und der Logger wird eingefügt.
Du bekommst dann etwas wie das hier:

```java
private static final Logger log = LoggerFactory.getLogger(MyPlugin.class);
```

Die Verwendung dieser Logger-Instanz ist der Verwendung des [plugin logger](#plugin-logger) sehr ähnlich, aber es gibt einige Unterschiede.

Schauen wir uns zuerst das grundlegende Logging an.

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

Du siehst, dass wir jetzt die Klasse als Präfix vor unserer Nachricht haben.
Statt `warning` verwenden wir jetzt `warn` und statt `severe` verwenden wir `error`.

#### Logging exceptions

Die Ausgabe von Fehlern ist mit slf4j einfacher.
Wir müssen ihn nur als zweites Argument nach unserer Nachricht übergeben.

```java
try {
    throw new RuntimeException("This is not good");
} catch (Exception e) {
    log.error("Something went wrong", e);
}
```

Die Ausgabe bleibt dieselbe wie bei [plugin logger](#plugin-logger), nur dass wir jetzt wieder den Klassenpräfix haben.

<details>
<summary>Ausgabe</summary>

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

#### Verwendung von Platzhaltern in Nachrichten

slf4j hat eine nette Funktion für Platzhalter.
Um deiner Nachricht zusätzliche Informationen hinzuzufügen, kannst du Platzhalter mit `{}` definieren und die Werte in der richtigen Reihenfolge nach deiner Nachricht übergeben.

```java
log.info("Hello {}. How was your {}? Is it already past {}?", "Chojo", "day", 2);
```
```log
[16:39:49 INFO]: [dev.chojo.myplugin.MyPlugin] Hello Chojo. How was your day? Is it already past 2?
```

Du kannst sehen, dass die Werte einfach in deine Nachricht eingefügt werden.

Das funktioniert auch mit Fehlern.
Achte nur darauf, dass dein letztes Argument der Fehler selbst ist und dass alle anderen Werte zuerst angegeben werden.

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

Funktioniert wie ein Zauber und macht es sehr einfach, zusätzliche Informationen zu deiner Nachricht hinzuzufügen!

## Hinzufügen eines Präfixes

Das Hinzufügen eines Präfixes, wenn du eine der Methoden im Abschnitt [schlecht](#schlecht) verwendest, hilft zwar ein bisschen, ist aber trotzdem schlecht.
Warum einen schlechten Weg benutzen, wenn es gute Wege gibt.

## Vielen Dank!

Jetzt weißt du, wie du dich richtig in dein Minecraft-Projekt einloggen kannst!

{{ blog_footer_de }}
