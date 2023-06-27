# Big Doors Opener

**Links:** [Source Code](https://github.com/eldoriarpg/BigDoorOpener), 
[Spigot](https://www.spigotmc.org/resources/80805/)

Big Doors Opener was my first add-on for another plugin named [Big Doors](https://www.spigotmc.org/resources/big-doors.58669/).
It was originally created for [Eldoria](eldoria.md), but then further developed for the public.

## Version 1
Version 1 was a quick proof of concept, which was first published in june 2020
The original system allowed one condition per door, making it very unflexible.
The general feature set was just opening and closing a door based on player proximity and world time.
Soon I would run into a lot of issues with extendability and decided to rewrite the system.

## Version 2

Version 2 is much more flexible in terms of conditions and even allows other plugins to inject their own conditions.
It also allows multiple conditions on a single door and can either `and` or `or` connect them.
Additionally, users can also define their own custom evaluation via js.
Version 2 is in general much more mature, but still lacks a lot of features I want to implement, which might come in a version 3.

