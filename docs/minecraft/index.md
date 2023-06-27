# Minecraft Projects

I maintain several projects related to Minecraft.
A lot of them are small fun plugins, which I will not mention here individually.
Some projects however are notable and have build up a surprisingly large userbase.
A few of my projects are also only available when purchased.
They are still open source, but support is only provided to verified buyers.

All my plugins are located under the [Eldoria](eldoria.md) organization.
I created a server to provide support for my plugins:

[![](https://discordapp.com/api/guilds/718502316940066927/widget.png?style=banner3)](https://discord.eldoria.de)

## Smaller Projects

Those are some of my smaller projects.
Those projects are sometimes not even published anywhere else then GitHub.

### Better Plugins

Better Plugins revamps the plugin list. Adding hover texts, dependency information and update checks.
It is mainly used to inspect and find unused plugins, which might still be there but not required by any plugin.
The update check also works via several platforms, be it spigot or a github release or just a release tag.

### Pick Me Up

**Links:** [Source Code](https://github.com/eldoriarpg/PickMeUp)

Pick me up was born from the idea to pick up entities.
The idea is not new though and a lot of plugins like player stacker have used them.
The main twist of this plugin is configurability and the feature to not only pickup and put down entities, but to also
throw them away.
The plugin works for every existing entity and even primed tnt, which some users found out and had great fun with it.

### NashornJS

**Links:** [Source Code](https://github.com/eldoriarpg/NashornJS)

NashornJS was born with the release of java 15 where the nashorn javascript engine was removed from the jdk.
This plugin allows to use it again.
The only known usage however are my own plugins.
It also contains a js cli tool which allows to execute js inside the minecraft chat.
(Not sure if this is actually a good thing)

### Eldo Utilities

**Links:** [Source Code](https://github.com/eldoriarpg/eldo-util)

Eldo Utilities are the core of all my plugins.
They contain everything I need.
Be it an enhanced plugin base class, configuration with jackson, localization, unified message sending, item and entity
builder and much more.

### Schematic Sanitizer

**Links:** [Source Code](https://github.com/eldoriarpg/schematic-sanitizer)

Schematic Sanitizer was created to strip data from a schematic.
This data can be nbt tags, or complete blocks. It can also limit the size and amount of entities inside a schematic.
The metrics about the schematic and illegal data is shown via an detailed report, listing exactly what was found.

### Update Butler

**Links:** [Source Code](https://github.com/eldoriarpg/updatebutler)

The update butler was what [lyna](../discord/lyna.md) is today.
It still exists and is maintained because my debugging system is tied to it which allows users to automatically provide
any data needed by myself to debug issues with my plugins.

### Schematic Saver

**Links:** [Source Code](https://github.com/eldoriarpg/SchematicSaver)

The schematic save can be used to deconstruct structures which have a fixed layout into several schematics.
This is especially useful if a huge amount of template structures are build and then combined randomly.

### Hot Spring

**Links:** [Source Code](https://github.com/eldoriarpg/HotSpring)

Hot springs is nothing more than a custom world guard flags which heals players when they are inside water.
It can also give xp.
Its giving players a way to idle and still gain something

### Firework Parade (Abandoned)

**Links:** [Source Code](https://github.com/eldoriarpg/FireworkParade)

Firework parade can be used to create custom firework.
However, it never left the proof of concept state and would deserve some great rewrite before being used in production.
Also, the text ui creator for firework is not ideal and should probably be replaced by a web editor.

