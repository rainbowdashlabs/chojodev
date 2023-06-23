# Reputation Bot

**Links:** [Source Code](https://github.com/RainbowDashLabs/reputation-bot) | [Website](https://rainbowdashlabs.github.io/reputation-bot/)

**Used Frameworks:** JDA, CJDA-Utils, [SADU](../libraries/sadu.md)

The Reputation Bot was originally developed for the german DevCord community.
The goal was to have a bot which recognizes thank phases like "thank you" or "thx".
The bot should then try to determine the target of the thanking phrase and increase an internal reputation counter for the target.
That is how the name reputation bot was born.
Of course the bot should also assign roles when a certain count of reputation is reached.

Over the time the bot did not only receive contribution by me, but also from other members of the DevCord community.
Some contributors are even from external communities.

Through requests the bot grew, new use cases were found and satisfied.
The bot received multiple major refactorings, nearly changing the whole code base.
It is probably one of my best maintained projects.

It is also probably one of the most configurable bots I have. 
The user can control nearly everything regarding the bot behavior.
Single features can be enabled or disabled and tweaked to a great extent.

## Privacy

Most known reputation bots expose something like a global score on a website or some other way.
The reputation bot doesn't do this. 
A reputation count is only visible when being on the same server as another user.
There is simply no good way to avoid bypassing a global system, so the bot doesn't have one.
The effort required to build a half functioning system would greatly exceed the payback.

## Metrics

Since I provide a public instance of this bot I also collect some [metrics](https://rainbowdashlabs.github.io/reputation-bot/metrics/) to monitor the general usage.
Those metrics are available for everyone and can be even requested via an own [api](https://repbot.chojo.de/docs).
Over the time, the bot has collected hundreds of thousands of reputation and analyzed millions of messages.