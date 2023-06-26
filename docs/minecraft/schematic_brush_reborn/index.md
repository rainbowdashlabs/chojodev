# Schematic Brush Reborn

Schematic Brush Reborn is one of my oldest plugins.
Initially it was my first real Minecraft plugins.
My initial motivation was to build a version
of [Schematic Brush by mikeprimm](https://github.com/mikeprimm/SchematicBrush/).
His version broke on minecraft 1.13, and I knew a lot of people who relied on this plugin, so I thought it would be a
good practice piece to dive into minecraft plugin development.

## Version 1

**Links:** [Source Code](https://github.com/eldoriarpg/SchematicBrushReborn/tree/legacy/v1)

The initial version of Schematic Brush Reborn was a pure rewrite of the original.
I redeveloped the whole feature set and extended it by a bit as well.
However, the goal was to act as a drop in replacement and I didn't change much on the core functionality.
This also included the hard to learn syntax to define brushes in the first place.

My rewrite got more popular, and therefore I started to receive feature requests.
Soon I would reach a point where my quite hacky and completely regex based parser met its borders.
I was in decent need of a rewrite.
Ideally something modular with a large api allowing to nearly modify everything.

## Version 2

**Links:** 
[Source Code](https://github.com/eldoriarpg/SchematicBrushReborn), 
[Purchase on Spigot](https://www.spigotmc.org/resources/98499/),
[Demo Video](https://www.youtube.com/watch?v=ZUj9YpIMTes)

Out of the needs of V1 Schematic Brush Reborn V2 was born.
It took me 140 hours to rewrite everything from scratch.
None of the code of V1 made it into V2 in the end.

Version 2 has nearly nothing in common with version 1 beside that it pastes schematics in the end.
The old complicated text based syntax was replaced by a rich text ui, which allows you to click your settings together.
Schematics can now be seen in realtime before being pasted and flip, rotation and offset can be adjusted.
The schematic can also be skipped without being pasted.
Complete brushed or only single presets and be saved and reused in other brushes.

V2 itself follows an api first approach. Every feature of the plugin itself was implemented using its own api.
The plugin itself is just a skeleton without features. No schematic loading, no pasting or setting saving.

Everything from schematic storage, over paste modification to storage of the settings can and is implemented via the
api.

This api first allows users to add their own content and second forces me to provide a good api, since I am itself its
biggest user.
If there is missing access on a part of the plugin, I first add an api for it and then use it.

This extensibility also gave birth to a bunch of addons namely:

- [Grid Selector](grid_selector.md)
- [Schematic Brush Database](schematic_brush_database.md)
- [Schematic Tools](schematic_tools.md)
- [Survival Schematic Brush](survival_schematic_brush.md)
