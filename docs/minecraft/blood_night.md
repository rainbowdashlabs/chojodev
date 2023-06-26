# Blood Night

Blood Night started as an experiment.
I wanted to check how hard it would be to create custom mobs in minecraft without using mobs or NMS.
The result was a custom mob framework which allows easy addition of custom mobs via code.

The plugin grew, I added more mobs and the users loved it.
It quickly became more popular than expected.
More popularity usually also means more feature requests.
Adding all those made the code base worse and worse.
When I started with blood night I was a beginner myself and therefore not very fond of good software architecture.
All this caused blood night to become a real mess to maintain.

In 2021, I stopped developing it and only update it to new versions. 
The code base reached a point where it was no longer fun to implement new features.
Every attempt to fix stuff would inevitably end in a complete rewrite of sections or even the whole plugin.
Also people were requesting Mythic Mobs support or an easy way to add custom mobs beside code.

The Mythic Mobs devs ignored all my questions regarding proper documentation of their api and all available documentation was outdated. 
This was a no-go and I decided to not implement it as long as this doesn't change, which is still the case as of today.

To add custom mobs without code would require some way to code without coding. That would probably be a yaml config, what MythicMobs does or a visual editor.
A yaml file is still the worst way for me to configure large things, especially mobs.
But I also lacked the knowledge to build a visual editor.

In 2023, I started working with some friends to rewrite blood night from scratch and also move all the configuration to a web editor.
As of today this is still in progress and not finished.