# Die Main Klasse des Plugins. Eine ständige Benennungsdiskussion!

Die Minecraft Main Klasse, oder die Klasse, die normalerweise von `JavaPlugin` erbt, ist fast immer Anlass für Diskussionen, wenn 
wenn es um die Namensgebung geht. 
In diesem Beitrag versuche ich meinen Standpunkt zu erläutern und zeige auch meinen Ansatz zur Namensgebung.

<!-- mehr -->

Um zu verstehen, warum wir immer wieder darüber diskutieren, müssen wir zunächst verstehen, was die sogenannte `Main` Klasse eigentlich ist.

## Die Java Main Class

In Java ist die Main Class die Klasse, die die methode `public static void main(String... args)` enthält.
Die Klasse, welche die Main-Methode selbst enthält, muss nicht unbedingt `Main` heißen.
Diese `main`-Methode dient als Einstiegspunkt in unsere Anwendung.
Normalerweise erstellen die Leute hier ihre Anwendungsinstanz und bauen die Startlogik ihrer Anwendung auf.
Ohne diese Methode würde unsere Anwendung nie etwas tun und könnte nicht ausgeführt werden.
Wenn wir unsere Anwendung bauen, müssen wir auch auf unsere Main Class in unserer Build-Datei verweisen, um dem JVM mitzuteilen, wo sie 
unsere Main Class findet.

## Die Plugin "Main Class" Klasse

Die Klasse, die wir in unseren Plugins main nennen, hat einige sehr deutliche Unterschiede.

1. Wir haben keine main-Methode.
2. Wir erstellen keine eigene Instanz unseres Plugins.
3. Wir haben keinen einzelnen Einstiegspunkt in unsere Anwendung. Vielmehr haben wir mindestens drei:
    - Constructor - Wenn der Server unsere Instanz erstellt
    - onLoad - Wenn der Server unser Plugin lädt
    - onEnable - Wenn der Server unser Plugin aktiviert
4. Der JVM ruft unsere Hauptmethoden nicht selbst auf, sondern der Server tut dies.

Jetzt sagst du bestimmt: _"Aber ich deklariere meine Main Class in der plugin.yml"_.
Ja, das tun wir, aber diese Namensgebung ist wahrscheinlich das Hauptproblem, das wir bis heute haben.

Was wir tatsächlich deklarieren, ist keine Main Klasse, wie sie von Java definiert wird, sondern verweist auf eine Klasse, die `JavaPlugin` oder `Plugin` erweitert.
Die korrekte Bezeichnung für diesen Parameter sollte wahrscheinlich `plugin_class` oder einfach `plugin` sein.
Es ist auf keinen Fall eine Main Klasse, wie sie von Java definiert wird.

## Der "ideale" Name

Ich persönlich verwende `tld.domain.pluginname.PluginName` oder `tld.domain.pluginname.PluginNamePlugin`.

Ein Plugin mit dem Namen `Maya` von mir unter der Domain `chojo.dev` würde dann `dev.chojo.maya.Maya` heißen oder 
`dev.chojo.maya.MayaPlugin`

Dies ist bei weitem nicht der Heilige Gral der Namensgebung.
Allerdings werden damit zwei große Probleme gelöst:

### 1. Namespace-Konflikte

Auf Minecraft-Servern teilen wir uns den Server immer mit mehreren Plugins, die höchstwahrscheinlich nicht alle von uns geschrieben  
selbst geschrieben wurden.
Es kann sein, dass wir unser Plugin auf einem Server mit 50 oder sogar 100 anderen Plugins betreiben.
Daher ist es wichtig, dass wir einen eindeutigen Namespace wählen, nämlich `tld.domain`.
Außerdem müssen wir Konflikte mit unseren eigenen Plugins vermeiden.
Deshalb fügen wir auch unseren `pluginnamen` hinzu und enden mit `tls.domain.pluginname`.
Natürlich haben wir jetzt schon einen eindeutigen Namespace für unser Plugin, und wir könnten unsere Klasse einfach main nennen.
Ich persönlich ziehe es vor, meine Klasse so zu nennen, wie ich mein Plugin nenne, also `PluginName` oder `PluginNamePlugin`, um deutlicher zu machen 
dass die Klasse die Plugin-Klasse erweitert.

### 2. Konflikt zwischen Klassennamen

_"Warum nennen Sie es nicht Main?"_ 
Um das zu verstehen, musst du an die Nutzer deines Plugins denken.
Oder denke ganz allgemein darüber nach, was wäre, wenn jeder seine Plugin-Klasse `Main` nennen würde.
Wenn du eine API eines Plugins benutzt, benutzt du in mindestens 90% der Fälle die Plugin-Klasse.
Stell dir vor, du suchst danach und bekommst eine Liste von 6 Klassen mit dem Namen `Main` von 6 verschiedenen Plugins.
Das ist schon ein guter Anfang für Fehler und Verwirrung.

Oder wenn du mehrere Apis oder Plugin-Klassen in deinem eigenen Plugin von anderen verwendest, würdest du wahrscheinlich mit etwas enden 
wie diesem:

```java
dev.someone.nele.Main nele = dev.someone.nele.Main.getInstance();
dev.someone.lara.Main lara = dev.someone.lara.Main.getInstance();
dev.someone.maya.Main maya = dev.someone.maya.Main.getInstance();
```

Wenn Du stattdessen die oben erwähnte Namensgebung befolgst, würde es wie folgt aussehen:

```java
NelePlugin nele = NelePlugin.getInstance();
LaraPlugin lara = LaraPlugin.getInstance();
MayaPlugin maya = MayaPlugin.getInstance();
```

Ist das nicht viel besser lesbar?
Wir vermeiden nicht nur Namespace-Konflikte, sondern auch Klassennamenskonflikte. 
Wir kommunizieren klar, dass unsere Klasse ein Plugin ist und zeigen auch direkt den Namen unseres Plugins mit an.

## Ich habe keine Domain

Das ist kein Problem. Du hast wahrscheinlich schon einen GitHub- oder GitLab-Account und wenn nicht, empfehle ich dringend, einen zu erstellen.
Wir verwenden Domains, weil wir wissen, dass nur wir sie benutzen (im Idealfall).
Alles, was du brauchst, ist also etwas Einzigartiges, das an dich gebunden ist, was der Fall ist, wenn du ein GitHub- oder GitLab-Konto hast.
In diesem Fall kannst du `io.github.username` oder `io.gitlab.username` als Namespace verwenden.
Du kannst diesen Namespace sogar für die Veröffentlichung in Maven Central verwenden!

## Schlussfolgerung

Plugins sollten ihren eigenen Namespace verwenden, normalerweise mit einer umgedrehten Domain `tld.domain`, gefolgt vom Plugin-Namen `pluginname`. 
Die Plugin-Klasse selbst sollte den Namen des Plugins enthalten, optional mit dem Suffix `Plugin` um zu zeigen, dass es sich um 
eine Plugin-Klasse handelt.

Wenn Du also das nächste Mal deine Plugin Klasse (nicht Main Class) erstellst und benennst, bedenke dies und wähle einen besseren Namen, für eine bessere Welt!
