# Lyna

**Links:** [Github](https://github.com/rainbowdashlabs/lyna/)

**Used Frameworks:** [JDA](https://github.com/discord-jda/JDA), CJDA-Utils, [SADU](../libraries/sadu.md)

I created lyna with the goal to generate license keys, which I can send to users.
Those license keys should initially only allow them to claim a discord role, which grants them access to support channels of the purchased resource.

Since manually creating those keys and sending them out was still a lot of work I implemented a mail client.
This client would read messages received by PayPal on a certain email account.
It would extract the purchased product and email and automatically create and send a license key.

Once this was done, there was something more I wanted to do, which was providing download files.
Not only for people which purchased a resource, but also for my patrons and people who use my free resources.
I already had a bot, which could do something like this, however new versions needed to be uploaded and registered manually.
That was a lot of work and since patrons had access to dev and snapshot builds it would be way to much work to publish each dev build on patreon.
Instead of the manual approach I used my own sonatype nexus.
Once a product is registered, downloads can be added by defining the type, repo and artifact.
The bot then pulls the available versions from the nexus and allows the user to download them via a unique single use link.

Access to a download can be granted via license and roles. 
License and roles can be permitted to download stable, dev and snapshot builds individually.
Products can also be made completely free for everyone to download.

Because people don't really like to buy something without trying it out I decided to also add a trial download.
This trial download allows a single download of a product, which is a regular version.
This way the user can test everything including the configuration, which is not possible on a public test server.
