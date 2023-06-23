# Universalis Java

**Links:** [Source Code](https://github.com/rainbowdashlabs/universalis-java)

**Used Frameworks:** [Jackson](https://github.com/FasterXML/jackson), [NV-Websocket-Client](https://github.com/TakahikoKawasaki/nv-websocket-client), [Apache HttpClient](https://hc.apache.org/httpcomponents-client-5.2.x/), Bson

Universalis Java is a library for requesting crowdsourced market board data of the game [Final Fantasy XIV](https://eu.finalfantasyxiv.com/) from [Universalis](https://universalis.app/).
It also contains a websocket implementation, allowing to subscribe to receive realtime updates from universalis.

This was my first time using web sockets to retrieve and parse data.
It was also my first time providing a complete wrapper for an existing external RESTApi.
Requests to the api are build and send via builders which allow easy configuration of requests.

```java
    public static void main(String[] args) {
        // Create a rest client with default settings.
        UniversalisRest rest = UniversalisRest.builder().build();

        // retrieve valid worlds synchronours
        WorldsResponse worlds = rest.worlds().complete();
        for (World world : worlds) {
            System.out.printf("World %s exists%n", world.name());
        }
        // create a market board request.
        rest.marketBoard()
            // Restrict prices to the european datacenters
            .region(Worlds.europe())
            // Get data for only one item
            .itemsIds(36113)
            // only retrieve high quality prices
            .highQuality()
            // exclude taxes
            .noGst()
            // send the request async
            .queue()
            // handle the result
            .whenComplete((res, err) -> {
                System.out.println("Min hq price is" + res.minPrice().highQuality());
            });
    }
```