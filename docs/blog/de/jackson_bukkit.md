---
date: 2023-08-21
draft: true
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

# Jackson Bukkit - Bukkit serialization done the right way

[English Version](../posts/jackson_bukkit.md)

Mit der Einführung von [paper plugins](https://docs.papermc.io/paper/reference/paper-plugins) hat paper beschlossen, die Unterstützung für die Schnittstelle `ConfigurationSerializable` einzustellen.
Diese Schnittstelle und das dahinter stehende System boten zwar eine brauchbare Möglichkeit, ein Objekt relativ einfach zu de/serialisieren, aber sie war keineswegs ideal.
Sie war schwer zu erlernen und erforderte eine Menge Standardcode, um ein Objekt zu de/serialisieren.
Deshalb verabschieden wir uns jetzt von ihr. Wir werden sie nicht vermissen.

<!-- more -->

Aber jetzt brauchen wir ein anderes System, um Bukkit-Objekte und unsere Konfiguration im Allgemeinen zu serialisieren.
Ein großer Vorteil der eingebauten Schnittstelle war, dass sie Bukkit-Objekte wie `Location` oder `ItemStack` sofort serialisieren konnte.
Wir brauchten also etwas Ähnliches.
Dafür werden wir jackson mit einer (oder zwei) meiner Bibliotheken verwenden, die ich pflege.

## Was ist de/serialization

Um dich auf den richtigen Weg zu bringen, sollten wir uns vielleicht erst einmal ansehen, worüber wir eigentlich reden.
De/Serialisierung ist der Prozess, bei dem Objekte in einer Programmiersprache in ein Datenformat abgebildet werden.
Dieses Datenformat ist normalerweise Text für menschenlesbare Daten oder binär für maschinenlesbare Daten.
Du hast vielleicht schon von diesen Formaten gehört.
Sie haben Namen wie yaml, json, xml, toml oder properties und viele mehr.

Unsere Klasse könnte also so aussehen:

```java
public class Person {
    String name;
    int age;
    Address address;

    public static class Address {
        String street;
        String city;
    }
}
```

In verschiedenen textlichen Darstellungen würde es so aussehen:

=== "yaml"

    ```yaml
    firstName: "Lilly"
    secondName: "Tempest"
    age: 21
    address:
      street: "Best street 1337"
      city: "Moonlight City"
    ```


=== "json"

    ```json
    {
      "firstName" : "Lilly",
      "secondName" : "Tempest",
      "age" : 21,
      "address" : {
        "street" : "Best street 1337",
        "city" : "Moonlight City"
      }
    }
    ```

=== "toml"

    ```toml
    firstName = 'Lilly'
    secondName = 'Tempest'
    age = 21
    address.street = 'Best street 1337'
    address.city = 'Moonlight City'
    ```

=== "xml"

    ```xml
    <Person>
      <firstName>Lilly</firstName>
      <secondName>Tempest</secondName>
      <age>21</age>
      <address>
        <street>Best street 1337</street>
        <city>Moonlight City</city>
      </address>
    </Person>
    ```

=== "properties"

    ```properties
    firstName=Lilly
    secondName=Tempest
    age=21
    address.street=Best street 1337
    address.city=Moonlight City
    ```


## Die Möglichkeiten

Natürlich ist der Markt für Serialisierungs-Frameworks riesig.
Um ein paar zu nennen:

- **[SnakeYAML](https://bitbucket.org/snakeyaml/snakeyaml/)**  
  Das Framework, das derzeit von bukkit verwendet wird.
  Wahrscheinlich ist es die beliebteste Lösung für reines Yaml (ich verstehe nicht, warum).
  Es unterstützt auch nur yaml
- **[Configurate](https://github.com/SpongePowered/Configurate)**  
  Es wurde von den Sponge-Entwicklern entwickelt und wird von einer Vielzahl von Projekten verwendet, insbesondere von Minecraft-Projekten wie Paper.
  Unterstützt JSON, HOCON, YAML und XML.
  Allerdings verwendet es unter der Haube verschiedene andere Bibliotheken wie Jackson.
- **[Jackson](https://github.com/FasterXML/jackson-core)**  
  Jackson ist wahrscheinlich die beste Unternehmenslösung für die Serialisierung, die wir haben.
  Sie unterstützt verschiedene Datenformate durch eine Vielzahl unterschiedlicher Datenformatmodule.
  Die Beispiele oben sind alle mit Jackson erstellt worden
- **[GSON](https://github.com/google/gson)**  
  Gson ist die bekannteste Bibliothek für json.
  Sie ist in Spigot und Paper gebündelt und wird dort für eine Vielzahl von Anwendungen verwendet.
  Wie der Name schon sagt, unterstützt sie nur JSON

Ich habe mich für jackson entschieden, weil es das flexibelste Framework ist, weit verbreitet ist und eine gute Dokumentation hat.

## Jackson bukkit integrieren

![Maven Central](https://img.shields.io/maven-central/v/de.eldoria.jacksonbukkit/jackson-bukkit)

Jackson bukkit befindet sich in Maven Central. Du kannst es mit gradle oder maven in dein Projekt importieren.

=== "gradle"

    ```java
    dependencies {
        // Spigot server
        implementation("de.eldoria.jacksonbukkit", "bukkit", "version")
        // Paper server
        implementation("de.eldoria.jacksonbukkit", "paper", "version")
    }
    ```

=== "maven"

    ```xml
    <dependencies>
        <!-- Spigot Server -->
        <dependency>
            <groupId>de.eldoria.jacksonbukkit</groupId>
            <artifactId>spigot</artifactId>
            <version>version</version>
        </dependency>
    
        <!-- Paper Server-->
        <dependency>
            <groupId>de.eldoria.jacksonbukkit</groupId>
            <artifactId>paper</artifactId>
            <version>version</version>
        </dependency>
    </dependencies>
    ```

!!! note

    Please only use the module you need depending on your server version


## Module erstellen

Du kannst die Module `JacksonBukkit` und `JacksonPaper` entweder direkt bauen oder den Builder für einfache Änderungen verwenden.
Die Verwendung des Builders wird empfohlen.
Der Builder für bukkit und paper kann über die entsprechende Klasse aufgerufen werden.

=== "Creating a Spigot Module"

    ```java
    ObjectMapper JSON = JsonMapper.builder()
        .addModule(JacksonBukkit.builder().build())
        .build();
    ```

=== "Creating a Paper Module"

    ```java
    ObjectMapper JSON = JsonMapper.builder()
        .addModule(JacksonPaper.builder().build())
        .build();
    ```

Du kannst natürlich auch TOML oder YAML oder was immer Jackson sonst noch unterstützt, verwenden.

Der Modul-Builder hat außerdem weitere Konfigurationsoptionen, die du [hier](https://github.com/eldoriarpg/jackson-bukkit#more-customization) findest.

## Unterschied zwischen Paper- und Bukkit-Modul

Das Paper-Modul versucht, alle Funktionen zu unterstützen, die in Paper verfügbar sind.
Der Deserialisierer erkennt automatisch das aktuelle Format, wenn ein altes Format verwendet wird, und wandelt es beim Speichern in das neue Format um.
Daher wird eine auf 1.15 erstellte Konfiguration die Legacy-Map enthalten, und sobald der Server auf 1.16 läuft, wird stattdessen das Byte-Array verwendet.

Paper serialisiert `ItemStack` in ein base64-kodiertes Byte-Array, anstatt die Spigots-Serialisierung zu verwenden.
Dies funktioniert nur auf Paperservern mit Version 1.16 oder höher, nicht auf Spigot-Servern.
Der Builder erlaubt die Verwendung der Spigots-Serialisierung auf Paperservern, aber das wird nicht empfohlen.

Wenn du ein [Paper-Plugin](https://docs.papermc.io/paper/reference/paper-plugins) baust, kann das Modul `JacksonBukkit` nicht mehr `ItemStacks` serialisieren.
Du musst in diesem Fall `JacksonPaper` verwenden und sicherstellen, dass du keine Legacy-Serialisierung verwendest.

| Class     | Paper                                                                      | Spigot           |
|-----------|----------------------------------------------------------------------------|------------------|
| Color     | RGB oder HEX RGB < 1.19 <= RGBA oder HEX RGBA                              | RGB oder HEX RGB |
| ItemStack | legacy Map < 1.16 <= NBT byte array                                        | Legacy Map       |
| Component | MiniMessage String wenn MiniMessages vorhanden ist. Ansonsten Json Object. | Nope c:          |

Im Allgemeinen werden alle Klassen unterstützt, die die Schnittstelle "ConfigurationSerializable" implementieren oder implementiert haben.
Eine vollständige Liste der unterstützten Klassen findest du [hier](https://github.com/eldoriarpg/jackson-bukkit#supported-classes).

## Erstellen deiner ersten Konfigurationsdatei

Für unsere erste Konfigurationsdatei wollen wir die Häuser der Spieler speichern.
Dazu erstellen wir eine Basisklasse namens `Homes`, die eine Karte der `PlayerHomes` mit einem Eintrag pro Spieler enthält.


<details>
<summary>Homes</summary>

```java
public class Homes {
    private final Map<UUID, PlayerHomes> playerHomes;

    @JsonCreator
    public Homes(@JsonProperty("playerHomes") Map<UUID, PlayerHomes> playerHomes) {
        this.playerHomes = playerHomes;
    }

    public Homes() {
        this(new HashMap<>());
    }

    public PlayerHomes get(UUID key) {
        return playerHomes.computeIfAbsent(key, k -> new PlayerHomes());
    }
}
```

</details>

Die Klasse `PlayerHomes` ist die gleiche, nur mit einer Karte, die die Namen der Häuser enthält.

<details>
<summary>PlayerHomes</summary>

```java
public class PlayerHomes {
    private final Map<String, Location> homes;

    @JsonCreator
    public PlayerHomes(@JsonProperty("homes") Map<String, Location> homes) {
        this.homes = homes;
    }

    public PlayerHomes() {
        this(new HashMap<>());
    }

    /**
     * Retrieves the location associated with the given name.
     *
     * @param name the name of the home. Case-insensitive
     * @return the location associated with the given name, or null if the name is not found
     */
    @Nullable
    public Location get(String name) {
        return homes.get(name.toLowerCase());
    }

    /**
     * Puts a new entry in the homes map with the specified name and location.
     *
     * @param name     the name of the entry. Will be converted to lower case
     * @param location the location associated with the entry
     */
    public void put(String name, Location location) {
        homes.put(name.toLowerCase(), location);
    }
}
```

</details>

Schauen wir uns an, was wir hier gemacht haben.

Wir haben zwei Klassen erstellt, die die Informationen enthalten, die wir brauchen, und einige Methoden hinzugefügt, um die Häuser abzurufen und neue Häuser zu registrieren.

Der wichtigste Teil ist unser Konstruktor, der verwendet wird, um unsere Instanzen zu erstellen, wenn wir unsere Konfigurationsdatei lesen.
Dies sind die Konstruktoren, die mit `@JsonCreator` annotiert sind.
Diese Klassen werden von jackson verwendet.
Danach müssen wir nur noch die Eingabefelder mit den entsprechenden Namen versehen, indem wir die Annotation `@JsonProperty` verwenden.

Das ist alles, was wir tun müssen.

## Erstellen eines ObjectMappers

![Maven Central](https://img.shields.io/maven-central/v/com.fasterxml.jackson.dataformat/jackson-dataformat-yaml)

Wie bereits erwähnt, verwendet Jackson Object Mapper, um Objekte von und auf unser Datenformat zu mappen.
Da wir weiterhin yaml verwenden wollen, müssen wir das yaml-Datenformat importieren.
Die neueste Version ist oben abgebildet.

=== "gradle"

    ```java
    dependencies {
        implementation("com.fasterxml.jackson.dataformat", "jackson-dataformat-yaml", "version")
    }
    ```

=== "maven"

    ```xml
    <dependencies>
        <dependency>
            <groupId>com.fasterxml.jackson.dataformat</groupId>
            <artifactId>jackson-dataformat-yaml</artifactId>
            <version>version</version>
        </dependency>
    </dependencies>
    ```

Nachdem wir das yaml-Datenformat importiert haben, können wir damit einen Objekt-Mapper erstellen und konfigurieren.

```java
ObjectMapper mapper = YAMLMapper.builder().addModule(JacksonPaper.builder().build())
        .build()
        .setVisibility(PropertyAccessor.FIELD, JsonAutoDetect.Visibility.ANY)
        .setVisibility(PropertyAccessor.GETTER, JsonAutoDetect.Visibility.NONE);
```

Wir konfigurieren den Mapper auch so, dass er die Felder in unseren Klassen verwendet und die Methoden mit dem Präfix get ignoriert.
Das spart uns etwas Zeit und ist das, was du normalerweise willst. Wenn du ein Feld in deiner Klasse vom Schreiben ausschließen willst, kannst du die Annotation `@JsonIgnore` hinzufügen.

## Schreiben unserer Konfigurationsdatei

Nachdem du deinem Homes-Objekt einige Daten hinzugefügt hast, müssen wir sie in eine Datei schreiben.
Dazu verwenden wir den ObjectMapper, den wir oben erstellt haben, und schreiben ihn in eine Datei in unserem Plugins-Verzeichnis.

!!! note

    Ich habe hier einige Beispieldaten erstellt, nachdem ich die Instanz meiner Häuser angelegt habe.

```java
ObjectMapper mapper = YAMLMapper.builder().addModule(JacksonPaper.builder().build())
        .build()
        .setVisibility(PropertyAccessor.FIELD, JsonAutoDetect.Visibility.ANY)
        .setVisibility(PropertyAccessor.GETTER, JsonAutoDetect.Visibility.NONE);
Homes homes = new Homes();
mapper.writeValue(plugin.getDataFolder().toPath().resolve("homes.yml").toFile(), homes);
```

!!! warning

    Behandle die IOException richtig

!!! note

    Du solltest deinen ObjectMapper zwischenspeichern und wiederverwenden, anstatt ihn bei jeder Verwendung neu zu erstellen.


Und jetzt haben wir unser Homes-Objekt als yaml-Datei direkt auf die Festplatte geschrieben.

Unsere Konfigurationsdatei sieht ungefähr so aus:

<details>
<summary>homes.yml</summary>

```yaml
---
playerHomes:
  "5c4a58ce-2c5e-417e-9022-328489126845":
    homes:
      home:
        uid: "f3a41fe9-64b0-45ee-948e-a29ce4a92b15"
        name: "world"
        xCoord: -98.0
        yCoord: 54.0
        zCoord: 54.0
        yaw: 59.0
        pitch: 300.0
  "333bea57-90f2-4f62-a9a4-911294c79d77":
    homes:
      home:
        uid: "f3a41fe9-64b0-45ee-948e-a29ce4a92b15"
        name: "world"
        xCoord: -55.0
        yCoord: -46.0
        zCoord: 72.0
        yaw: 301.0
        pitch: 189.0
  ff88dace-9ef3-47a6-9c70-d93ddcf781f2:
    homes:
      another_home:
        uid: "f3a41fe9-64b0-45ee-948e-a29ce4a92b15"
        name: "world"
        xCoord: 50.0
        yCoord: -99.0
        zCoord: -55.0
        yaw: 19.0
        pitch: 154.0
      my_home:
        uid: "f3a41fe9-64b0-45ee-948e-a29ce4a92b15"
        name: "world"
        xCoord: 97.0
        yCoord: -66.0
        zCoord: -4.0
        yaw: 20.0
        pitch: 167.0
```

</details>

Du kannst sehen, dass der Standort automatisch in ein gut lesbares Format umgewandelt wurde.
Die Welten werden mit ihrer uid und ihrem Namen gespeichert, damit sie besser lesbar sind.

## Lesen unserer Konfigurationsdatei

Das Lesen der Konfigurationsdatei ist so einfach wie das Schreiben.

```java
ObjectMapper mapper = YAMLMapper.builder().addModule(JacksonPaper.builder().build())
        .build()
        .setVisibility(PropertyAccessor.FIELD, JsonAutoDetect.Visibility.ANY)
        .setVisibility(PropertyAccessor.GETTER, JsonAutoDetect.Visibility.NONE);

Homes homes = mapper.readValue(plugin.getDataFolder().toPath().resolve("homes.yml").toFile(), Homes.class);
```

Wenn die Datei nicht existiert, schlägt sie fehl. Deshalb solltest du eine Existenzprüfung hinzufügen und eine leere Konfigurationsdatei erstellen:

```java
File homesFile = plugin.getDataFolder().toPath().resolve("homes.yml").toFile();
if (!homesFile.exists()) mapper.writeValue(homesFile, new Homes());
Homes homes = mapper.readValue(homesFile, Homes.class);
```

## Verwendung eines Config-Wrappers für Konfigurationsdateien

![Maven Central](https://img.shields.io/maven-central/v/de.eldoria.util/jackson-configuration)

Natürlich lässt sich das alles auch viel einfacher machen.
Ich habe einen Wrapper geschrieben, der die einfache Handhabung von Konfigurationsdateien mit jackson ermöglicht.

Er ist auch in Maven Central verfügbar und kann mit Maven oder Gradle importiert werden:

=== "gradle"

    ```java
    dependencies {
        implementation("de.eldoria.jacksonbukkit", "jackson-configuration", "version")
    }
    ```

=== "maven"

    ```xml
    <dependencies>
        <dependency>
            <groupId>de.eldoria.jacksonbukkit</groupId>
            <artifactId>jackson-configuration</artifactId>
            <version>version</version>
        </dependency>
    </dependencies>
    ```

Der Jackson-Konfigurations-Wrapper ist so konzipiert, dass er mit mehreren Dateien umgehen kann, wobei eine Datei als Standardkonfigurationsdatei festgelegt ist.
Konfigurationsdateien werden mit `ConfigKeys` definiert, die einen menschenlesbaren Namen, den Pfad zur Datei und einen Standardwert für die Klasse enthalten.

Der Konfigurationsschlüssel für unsere Homes-Datei würde wie folgt aussehen: `ConfigKey.of("homes", Path.of("homes.yml"), Homes.class, Homes::new)`.
Zuerst legen wir den lesbaren Namen fest, nämlich `Homes`, gefolgt vom Pfad im Plugin-Verzeichnis.
Dann übergeben wir die Klasse und einen Standardwert, falls die Datei noch nicht existiert.

Der Standardschlüssel für die `config.yml` kann etwas einfacher mit `ConfigKey.defaultConfig(Configuration.class, Configuration::new)` erstellt werden.

Der schnellste Weg, auf unsere Dateien zuzugreifen, ist, einfach eine Instanz von `JacksonConfig` zu erstellen und ihr unsere Homes-Datei als Standardkonfiguration zu übergeben.

```java
// Create the config key for our homes file
ConfigKey<Homes> homesKey = ConfigKey.of("homes", Path.of("homes.yml"), Homes.class, Homes::new);
// Create a new instance and set the homes.yml as main configuration
JacksonConfig<Homes> config = new JacksonConfig<>(plugin, homesKey);

// Get the instance of our main configuration
Homes main = config.main();

// make some changes

// Save all configuration files
config.save();

// Only save the configuration with that key.
config.save(homesKey);
```

Die Bibliothek kümmert sich um die Erstellung unserer Datei und ermöglicht es uns auch, sie einfach zu speichern und abzurufen.

Um andere Dateien zu laden, musst du nur einen neuen `ConfigKey` erstellen und `JacksonConfig#secondary(ConfigKey)` damit aufrufen.

Der schönere Weg ist jedoch, eine eigene Klasse zu erstellen, die auf der JacksonConfig-Klasse basiert.
Du kannst auch eine config.yml hinzufügen und diese als Hauptkonfiguration und deine Homes-Datei als Sekundärkonfiguration verwenden.

```java
public class Configuration extends JacksonConfig<General> {
    private static final ConfigKey<General> MAIN = ConfigKey.defaultConfig(General.class, General::new);
    private static final ConfigKey<Homes> HOMES = ConfigKey.of("homes", Path.of("homes.yml"), Homes.class, Homes::new);

    public Configuration(@NotNull Plugin plugin) {
        super(plugin, MAIN);
    }

    public Homes homes() {
        return secondary(HOMES);
    }
    
    public Wrapper<Homes> homesWrapped() {
        return secondaryWrapped(HOMES);
    }
}
```

And that's it.
You can now use your `Configuration` instance to access your main plugin.yml and also access your homes file via the custom method.

```java
// Create a new configuration instance
Configuration configuration = new Configuration(plugin);
// Get the main configuration file
General general = configuration.main();
// Get the homes configuration file
Homes homes = configuration.homes();

// Add a home to the player
homes.get(player).put("home", location);
// save all files
configuration.save();

// Use the wrapper to automatically save once the wrapper is closed
try (var temp = configuration.homesWrapped()) {
    // Add a home to the player
    temp.config().get(player).put("home", location);
}
```

Die Wrapped-Methode ermöglicht es dir, den Config-Wrapper in ein Auto-Closable zu bekommen, das die Datei automatisch speichert, sobald der Block verlassen wird.

## Migration von ConfigurationSerializable

Wenn du die Bukkit-Serialisierung bereits benutzt hast, ist es ganz einfach, deine neuen Objekte zu verwenden.
Alles, was du tun musst, ist, deinen Konstruktor als json-Ersteller zu markieren und den alten Map-Konstruktor zu entfernen.
Natürlich solltest du sicherstellen, dass deine Nutzer bereits migriert sind, bevor du den Konstruktor vollständig aus deinem Projekt entfernst:

```diff
-public final class PersonCS implements ConfigurationSerializable {
+public final class PersonCS {
     private final String firstName;
     private final String secondName;
     private final int age;
     private final Address address;
 
-    public PersonCS(Map<String, Object> map) {
-        firstName = (String) map.get("firstName");
-        secondName = (String) map.get("secondName");
-        age = (Integer) map.get("age");
-        address = (Address) map.get("address");
-    }

+   @JsonCreator
+    public PersonCS(@JsonProperty("firstName") String firstName,
+                    @JsonProperty("secondName") String secondName,
+                    @JsonProperty("age") int age,
+                    @JsonProperty("address") Address address) {
         this.firstName = firstName;
         this.secondName = secondName;
         this.age = age;
         this.address = address;
     }
 
-    @Override
-    public @NotNull Map<String, Object> serialize() {
-        HashMap<String, Object> map = new HashMap<>();
-        map.put("firstName", firstName);
-        map.put("secondName", secondName);
-        map.put("age", age);
-        map.put("address", address);
-        return map;
-    }
 
     /* GETTER */
 
     public static final class Address implements ConfigurationSerializable {
         private final String street;
         private final String city;
 
-        public Address(Map<String, Object> map) {
-            street = (String) map.get("street");
-            city = (String) map.get("city");
-        }

+       @JsonCreator
+        public Address(@JsonProperty("street") String street,
+                       @JsonProperty("city") String city) {
             this.street = street;
             this.city = city;
         }
 
-        @Override
-        @NotNull
-        public Map<String, Object> serialize() {
-            HashMap<String, Object> map = new HashMap<>();
-            map.put("street", street);
-            map.put("city", city);
-            return map;
-        }
 
         /* GETTER */
     }
 }
```

Anstatt einen Konstruktor für deine Klassen zu erstellen, kannst du auch die Felder verwenden, um Werte zuzuordnen.
Ich bevorzuge Konstruktoren, weil sie weniger hakelig sind als Reflection-Kram.

## Danke!

Danke, dass du mir bis jetzt gefolgt bist.
Du kannst jetzt ganz einfach Konfigurationsdateien mit jackson erstellen und sie in deinen Plugins verwenden!

{{ blog_footer_de }}
