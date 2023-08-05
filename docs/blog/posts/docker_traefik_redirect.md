---
date: 2023-08-05
authors:
  - chojo  
categories:
  - docker
  - traefik
---


# Redirecting to an external domain with traefik

[German Version](../de/docker_traefik_redirect.md)

Welcome to another blog post!
This time we will look at how to redirect to an external url using [traefik](https://doc.traefik.io/traefik/) without using a container.
Docker is completely optional, but I run my traefik with docker, so I will refer to that as well.
This should also work with others, but I have not tested or done so yet.

<!-- more -->

## Setting up the file provider

To inject our redirects into traefik we will use the [file provider](https://doc.traefik.io/traefik/providers/file/).
To do this we need to do two things

### Create a file provider directory

Create a new directory `provider` next to your [compose file](https://docs.docker.com/compose/compose-file/compose-file-v3/) and mount it into your container.

```yml
    volumes:
      - "./provider/:/provider/"
```

### Enabling the file provider in the configuration

Now we need to modify our `traefik.yaml` and add a [file provider](https://doc.traefik.io/traefik/providers/file/).

```yml
providers:
  file:
    directory: "/provider/"
    watch: true
```

This will make traefik watch every file in our provider directory.
This allows us to use multiple files to group our providers and keep them more organised.
Traefik will also watch for changes to our providers, so as soon as we edit, create or delete a file, those changes will instantly affect traefik's routing.

!!! warning

    Traefik only monitors files in the root directory, so you cannot use subdirectories.

!!! warning

    Do not forget to restart your traefik container.

## Creating a redirect

To create a redirect we need two things, a `redirectRegex` [middleware](https://doc.traefik.io/traefik/middlewares/http/redirectregex/) and a [router](https://doc.traefik.io/traefik/routing/routers/) to accept the requests.
For this we will create a file `redirect.yml` (the name can be anything) in our new `provider` directory.

!!! note
    
    Alternatively you can create one file for each redirect.
    A shell script for this can be found [below](#using-a-shell-script-to-create-redirects)

### Setting up the redirectRegex middleware

```yaml
http:
  middlewares: # (1)!
    chojo-dev-redirect: # (2)!
      redirectRegex: # (3)!
        regex: "(.*)" # (4)!
        replacement: "https://chojo.dev/" # (5)!
        permanent: false # (6)!
```

1. We create middlewares, so we use the middleware section.
2. Define a new middleware with the name `chojo-dev-redirect`.
3. Define the type of the middleware as `redirectRegex`.
4. Define the regex pattern as `(.*)`, which will basically match anything. 
This is the part of the url we want to replace.
So we really want to replace all of the string.
5. Define the new url we want to redirect to.
6. Mark the redirect as temporary.
This will prevent the browser from caching, and changes to our redirect will take effect immediately.

If you want to know what each line does, look at the comments.

### Setting up the router

Every router needs a service to which it is connected.
Of course, we could use Docker to start a service for each of our redirections, or we could start a single service and reuse it.
Luckily traefik already has us covered and offers a service for exactly this use case called `noop@internal`.

!!! note

    The `middlewares` section is still there, I'm just not showing it.

```yaml
http:
  routers: # (1)!
    chojo-dev-redirect: # (2)!
      service: noop@internal # (3)!
      entrypoints: "https" # (4)!
      rule: "Host(`my.host.com`)" # (5)!
      middlewares: "chojo-dev-redirect" # (6)!
      tls:
        certresolver: my_cert_resolver # (7)!
```

1. We are going to create a router, so we will use the routers section.
2. Define a new router called `chojo-dev-redirect`. I recommend using the same name as the middleware, but it is not required.
3. Add the `noop@internal` service to our router.
4. Assign the `https` `entrypoint`. This may vary depending on your setup.
5. Assign the rule to our host
6. Assign the redirect middleware we defined earlier
7. Assign our cert resolver to the assigned rule

!!! warning

    Make sure you adapt `entrypoint`, `rule` and `certresolver` to your needs!

This will create our service.
Anything matching our rule will now be redirected to the domain defined in the redirect middleware.

## Using a shell script to create redirects.

I use a bash script to create my redirects.


<details>
<summary>Script</summary>

```shell
#!/usr/bin/env sh

read -rp "Enter the name for the router and middleware: " NAME
if [ -z "$NAME" ]; then
    echo "Name cannot be empty. Exiting..."
    exit 1
fi

read -rp "Enter the target URL you want to redirect to: " TARGET
if [ -z "$TARGET" ]; then
    echo "Target URL cannot be empty. Exiting..."
    exit 1
fi

read -rp "Enter the host that should be redirected: " HOST
if [ -z "$HOST" ]; then
    echo "Host cannot be empty. Exiting..."
    exit 1
fi

read -rp "Enter the cert resolver: " CERT
if [ -z "$CERT" ]; then
    echo "Cert resolver cannot be empty. Exiting..."
    exit 1
fi

read -rp "Do you want the redirection to be permanent? [y/N]: " PERMANENT_INPUT
PERMANENT_INPUT=${PERMANENT_INPUT:-n}

PERMANENT=false

if [ "${PERMANENT_INPUT}" = "y" ] || [ "${PERMANENT_INPUT}" = "Y" ]; then
  PERMANENT=true
elif [ "${PERMANENT_INPUT}" != "n" ] && [ "${PERMANENT_INPUT}" != "N" ]; then
  echo "Invalid input for permanent value."
  exit 1
fi

TEXT="http:
  middlewares:
    ${NAME}-redirect:
      redirectRegex:
        regex: \"(.*)\"
        replacement: \"${TARGET}\"
        permanent: ${PERMANENT}
  routers:
    ${NAME}-redirect:
      service: noop@internal
      entrypoints: \"https\"
      rule: \"Host(\`${HOST}\`)\"
      middlewares: \"${NAME}-redirect\"
      tls:
        certresolver: ${CERT}"

echo "$TEXT" > "${NAME}-redirect.yml"
echo "$TEXT"
echo "File ${NAME}-redirect.yml created."
```

</details>

You can get it with

```sh
wget https://chojo.dev/assets/files/redirect.sh && chmod +x redirect.sh
```

!!! warning

    Never run a bash script without looking at them!

The bash script creates a file for each redirect.
This makes them easy to find.
If you want to change it, just create it again with the same name.

## Thank you

Thanks for reading my post.
I hope it helped you!
