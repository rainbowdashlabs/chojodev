# Jackson Bukkit

**Links:** [Source Code](https://github.com/eldoriarpg/jackson-bukkit/)

**Used Frameworks:** [Jackson](https://github.com/FasterXML/jackson)

Bukkit/Spigot uses snakeyaml for serialization. 
Some classes in Bukkit can be directly written to a configuration file using an own wrapper around snakeyaml.
This required the implementation of an interface called [ConfigurationSerializable](https://hub.spigotmc.org/javadocs/bukkit/org/bukkit/configuration/serialization/ConfigurationSerializable.html).
This interface can also be used by api users.
Own classes need to be registered and implement a method for serialization and deserialization.
Those methods need to be created manually imposing a large amount of manual work and recurring maintenance work when altering the class.
It is also a great source of bugs caused by missing entries.

Paper, a fork of Spigot, removed this way of serialization for its own plugin introduced in 1.19.4.
It is however still supported as long as spigot compatible plugins are loaded.

The removal of snakeyaml serialization motivated me to finally use jackson in my plugins as well.
However, this made me loose the current ability to directly write objects of internal classes of bukkit directly into my configuration files.
That is where Jackson Bukkit comes in place. 
The library provides a jackson module, which allows to serialize internal objects with zero work for the developer.

The library also supports changed data models, since the classes changed a lot in the past years.
Jackson Bukkit supports everything from 1.13 to the latest version (Version 1.20 as of writing).
Migration from older to newer data models is performed automatically.
Migration from newer to older data models is not supported