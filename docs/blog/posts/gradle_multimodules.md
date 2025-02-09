---
date: 2025-02-09
draft: true
authors:
  - chojo  
categories:
  - beginner
  - gradle
  - java
---


# Gradle Multimodules - Why using them is nice and not

Multimodules are very nice when you have multiple things depending on the same dependencies that are all managed by you.
They are especially common when you want to provide the same set of features on different platforms. This can be Velocity and Paper that share a custom core api in Minecraft development or when you want to support different databases in your sql lib like it's done in [SADU](https://github.com/rainbowdashlabs/sadu).

Commonly the modules of the multimodule project share the same version. So whenever you change something in a module and make a new release all module versions will be changed. Regardless of the module that was changed. This implies as well that a module will not depend on an older version of another module.

Multimodules not only make sharing your own code inside your project easier, but also sharing dependencies. Usually the modules in a multimodules project are an application or a library or both.

The old way of sharing settings between modules was the buildSrc directory, which provided common set of settings which could be imported into another gradle build file. The new way that we look into will not require this and works on a hierarchical approach, where the root project defines the subprojects.

This blog post requires basic understanding of gradle as explained in my other [blog post](gradle_basics.md). I will not explain things again that I explained over there already.

For the demonstration purposes we will look into a minecraft multimodule project. Our target is to write an api, that is then implemented by a velocity plugin and a paper plugin, which then expose this api on the servers. The api could for example provide core libraries and core logic as well.

The general layout will be:

```
.
├── gradle
│   └── wrapper
│       ├── gradle-wrapper.jar
│       └── gradle-wrapper.properties
├── gradlew
├── gradlew.bat
├── gradle.properties
├── build.gradle.kts
├── settings.gradle.kts
├── api
│   └── build.gradle.kts
├── paper
│   └── build.gradle.kts
└── velocity
    └── build.gradle.kts
```

To create a new module in IntelliJ, right-click on the project root, select "New" and select "Module"
