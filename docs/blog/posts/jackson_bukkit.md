---
date: 2023-10-30
authors:
  - chojo  
categories:
  - minecraft
  - beginner
  - gradle
  - java
  - paper
  - spigot
  - jackson
---

# Jackson Bukkit - Bukkit serialization done the right way

[German Version](../de/jackson_bukkit.md)

With the introduction of [paper plugins](https://docs.papermc.io/paper/reference/paper-plugins), paper decided to drop support for the `ConfigurationSerializable` interface.
While this interface and the system behind it provided a usable way to de/serialise an object fairly easily, it wasn't ideal by any means.
It was hard to learn and required a lot of boilerplate code to simply de/serialise an object.
So we're going to say goodbye to it. It won't be missed.

<!-- more -->

But now we need another system to serialise Bukkit objects and our configuration in general.
A big advantage of the built-in interface was that it could serialise bukkit objects like `Location` or `ItemStack` out of the box.
So we needed something similar.
For this we will use jackson with one (or two) of my libraries that I maintain.

## What is de/serialization

To get you where you are, we should probably take a look at what we are actually talking about.
De/serialisation is the process of mapping objects in a programming language into a data format.
This data format is usually text for human-readable data, or binary for machine-readable data.
You may have heard of them.
They have names like yaml, json, xml, toml or properties and many more.

So while our class might look like this:

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

It would look like this in various textual representations:


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


## The possibilities

Of course the market is huge in terms of serialization frameworks.
To list a few:

- **[SnakeYAML](https://bitbucket.org/snakeyaml/snakeyaml/)**  
The framework currently used by bukkit.
Probably the most popular solution for pure yaml (I don't understand why).
It also does only support yaml
- **[Configurate](https://github.com/SpongePowered/Configurate)**  
Developed by the sponge developers it is used by a wide variety of especially minecraft projects like Paper.
Supports JSON, HOCON, YAML and XML.
However, it uses several other libraries like jackson under the hood.
- **[Jackson](https://github.com/FasterXML/jackson-core)**  
Jackson is probably the most enterprise solution for serialization we have.
It supports various dataformats throught a ton of different data format modules.
The examples above are all created with jackson
- **[GSON](https://github.com/google/gson)**  
Gson is the library most know for json.
It is bundled in spigot and paper and used for a ton of applications there.
Like the name says it only support JSON

I settled for jackson since it is the most flexible framework, widely used and has actually great documentation.

## Obtaining jackson bukkit

![Maven Central](https://img.shields.io/maven-central/v/de.eldoria.jacksonbukkit/jackson-bukkit)

Jackson bukkit is located in Maven Central. You can import it into your project with gradle or maven.

=== "gradle"

    ```java
    dependencies {
        // Spigot server
        implementation("de.eldoria.jacksonbukkit", "bukkit", "{{ VC_LIBRARY_JACKSONBUKKIT_VERSION }}")
        // Paper server
        implementation("de.eldoria.jacksonbukkit", "paper", "{{ VC_LIBRARY_JACKSONBUKKIT_VERSION }}")
    }
    ```

=== "maven"

    ```xml
    <dependencies>
        <!-- Spigot Server -->
        <dependency>
            <groupId>de.eldoria.jacksonbukkit</groupId>
            <artifactId>spigot</artifactId>
            <version>{{ VC_LIBRARY_JACKSONBUKKIT_VERSION }}</version>
        </dependency>
    
        <!-- Paper Server-->
        <dependency>
            <groupId>de.eldoria.jacksonbukkit</groupId>
            <artifactId>paper</artifactId>
            <version>{{ VC_LIBRARY_JACKSONBUKKIT_VERSION }}</version>
        </dependency>
    </dependencies>
    ```

!!! note

    Please only use the module you need depending on your server version


## Module Creation

You can either build the `JacksonBukkit` and `JacksonPaper` modules directly, or use the builder for easy modification.
Use of the builder is recommended.
The builder for bukkit and paper can both be accessed via the corresponding class.

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

Of course you can also use TOML or YAML or whatever else Jackson supports.

The module builder also has more configuration options, which can be found [here](https://github.com/eldoriarpg/jackson-bukkit#more-customization).

## Difference between Paper and Bukkit module

The paper module tries to support all the features available in paper.
The deserialiser will automatically detect the current format when using a legacy format and convert it to the new format when saving.
Therefore, a config created on 1.15 will contain the legacy map, and once the server is running on 1.16, the byte array will be used instead.

Paper serialises `ItemStack` to a base64 encoded byte array instead of using spigots serialisation.
This will only work on paper servers on 1.16 or later, not on spigot servers.
The builder allows you to use spigots serialisation on paper servers, but this is not recommended.

When building a [paper plugin](https://docs.papermc.io/paper/reference/paper-plugins) the `JacksonBukkit` module is no longer able to serialise `ItemStacks`.
You will need to use `JacksonPaper` in this case, and make sure you are not using legacy serialisation.

| Class     | Paper                                                                   | Spigot         |
|-----------|-------------------------------------------------------------------------|----------------|
| Color     | RGB or HEX RGB < 1.19 <= RGBA or HEX RGBA                               | RGB or HEX RGB |
| ItemStack | legacy Map < 1.16 <= NBT byte array                                     | Legacy Map     |
| Component | MiniMessage String when MiniMessages is present. Otherwise Json Object. | Nope c:        |

In general, all classes that implement or have implemented the `ConfigurationSerializable' interface are supported.
A complete list of supported classes can be found [here](https://github.com/eldoriarpg/jackson-bukkit#supported-classes).

## Creating your first configuration file

We want to store player homes for our first config file.
To do this, we create a base class called `Homes`, which holds a map of `PlayerHomes` with one entry per player.


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

The `PlayerHomes` class is the same just with a map containing the names of the homes.

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

Let's take a look at what we've done here.

We have created two classes that contain the information we need and added some utility methods to get the houses and register new houses.

The most important part is our constructor, which is used to create our instances when we read our configuration file.
These are the constructors annotated with `@JsonCreator`.
These classes will be used by jackson.
After that, we just need to annotate the input fields with their corresponding names using the `@JsonProperty` annotation.

That's all we need to do.

## Creating our ObjectMapper

As mentioned earlier, Jackson uses object mapper to map objects from and to our dataformat.
Since we want to continue using yaml, we need to import the yaml dataformat.
The latest version is shown above.

=== "gradle"

    ```java
    dependencies {
        implementation("com.fasterxml.jackson.dataformat", "jackson-dataformat-yaml", "{{ VC_LIBRARY_JACKSON_YAML_VERSION }}")
    }
    ```

=== "maven"

    ```xml
    <dependencies>
        <dependency>
            <groupId>com.fasterxml.jackson.dataformat</groupId>
            <artifactId>jackson-dataformat-yaml</artifactId>
            <version>{{ VC_LIBRARY_JACKSON_YAML_VERSION }}</version>
        </dependency>
    </dependencies>
    ```

Once we imported the yaml dataformat we can use it to create an object mapper and configure it.

```java
ObjectMapper mapper = YAMLMapper.builder().addModule(JacksonPaper.builder().build())
        .build()
        .setVisibility(PropertyAccessor.FIELD, JsonAutoDetect.Visibility.ANY)
        .setVisibility(PropertyAccessor.GETTER, JsonAutoDetect.Visibility.NONE);
```

We also configure the mapper to use the fields in our classes and ignore the get prefixed methods.
This saves us some time and is what you usually want. If you want to exclude a field in your class from being written, you can add the `@JsonIgnore` annotation to it.

## Writing our config file

Once you added some data to your homes object we need to write it into a file.
For that we will use the ObjectMapper we created above and will use it to write it to a file in our plugins directory.

!!! note

    I created some sample data here after creating my homes instance.

```java
ObjectMapper mapper = YAMLMapper.builder().addModule(JacksonPaper.builder().build())
        .build()
        .setVisibility(PropertyAccessor.FIELD, JsonAutoDetect.Visibility.ANY)
        .setVisibility(PropertyAccessor.GETTER, JsonAutoDetect.Visibility.NONE);
Homes homes = new Homes();
mapper.writeValue(plugin.getDataFolder().toPath().resolve("homes.yml").toFile(), homes);
```

!!! warning

    Handle the IOException properly

!!! note

    You should cache your ObjectMapper and reuse it instead of creating it again on every usage.


And now we have written our homes object as a yaml file directly to disk.

Our config file looks something like this:


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

You can see that the location has been automatically broken down into a nice readable format.
Worlds are stored with their uid and name for readability.

## Reading our configuration file

Reading the configuration file is as simple as writing it.

```java
ObjectMapper mapper = YAMLMapper.builder().addModule(JacksonPaper.builder().build())
        .build()
        .setVisibility(PropertyAccessor.FIELD, JsonAutoDetect.Visibility.ANY)
        .setVisibility(PropertyAccessor.GETTER, JsonAutoDetect.Visibility.NONE);

Homes homes = mapper.readValue(plugin.getDataFolder().toPath().resolve("homes.yml").toFile(), Homes.class);
```

If the file doesn't exist it will fail, so you might want to add an existence check and create an empty config file:

```java
File homesFile = plugin.getDataFolder().toPath().resolve("homes.yml").toFile();
if (!homesFile.exists()) mapper.writeValue(homesFile, new Homes());
Homes homes = mapper.readValue(homesFile, Homes.class);
```

## Using a config wrapper for configuration files

Of course, this can all be done much more easily.
I have written a wrapper that allows easy handling of configuration files with jackson.

It is also available in Maven Central and can be imported with maven or gradle:

=== "gradle"

    ```java
    dependencies {
        implementation("de.eldoria.jacksonbukkit", "jackson-configuration", "{{ VC_LIBRARY_ELDOUTIL_VERSION }}")
    }
    ```

=== "maven"

    ```xml
    <dependencies>
        <dependency>
            <groupId>de.eldoria.jacksonbukkit</groupId>
            <artifactId>jackson-configuration</artifactId>
            <version>{{ VC_LIBRARY_ELDOUTIL_VERSION }}</version>
        </dependency>
    </dependencies>
    ```

The jackson configuration wrapper is designed to handle multiple files, with one file set as the default, aka main configuration file.
Configuration files are defined using `ConfigKeys` which provide a human readable name, path to the file and also a default value for the class.

The config key for our homes file would look like this `ConfigKey.of("homes", Path.of("homes.yml"), Homes.class, Homes::new)`.
First we define the human readable name, which is `homes`, followed by the path within the plugin directory.
Then we pass the class and a default value if the file doesn't exist yet.

The default key for the `config.yml` can be created a bit easier with `ConfigKey.defaultConfig(Configuration.class, Configuration::new)`.

The quickest way to access our files is to simply create an instance of `JacksonConfig` and pass it our homes file as the default configuration.

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

The library takes care of the creation of our file and also allows us to easily save and retrieve it.

To load other files you just need to create a new `ConfigKey` and call `JacksonConfig#secondary(ConfigKey)` with it.

However, the nicer way is to create your own class based on the JacksonConfig class.
You can also add a config.yml and use that as the main configuration and your homes file as the secondary configuration.

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

The wrapped method allows you to get the config wrapper into an auto closable, which will automatically save the file once the block is left.

## Migrating from ConfigurationSerializable

If you have used bukkit serialisation before, it is quite easy to use your new objects.
All you need to do is mark your constructor as the json creator and remove the old map constructor.
Of course, make sure that your users have already migrated before you remove the constructor completely from your project c:

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

Instead of creating a constructor for your classes, you can also use the fields to map values.
I just prefer constructors because they are less hacky than reflection stuff.

## Thank you!

Thank you for sticking with me so far.
You can now easily create configuration files with jackson and use them in your plugins!

{{ blog_footer_en }}
