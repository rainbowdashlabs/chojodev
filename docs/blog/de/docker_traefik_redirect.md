---
date: 2023-08-05
authors:
  - chojo  
categories:
  - docker
  - traefik
---

# Umleitung auf eine externe Domain mit traefik

[English Version](../posts/docker_traefik_redirect.md)

Willkommen zu einem weiteren Blog-Beitrag!
Diesmal werden wir uns ansehen, wie man mit [traefik](https://doc.traefik.io/traefik/) auf eine externe URL umleitet, ohne einen Container zu verwenden.
Docker ist völlig optional, aber ich betreibe mein traefik mit Docker, also werde ich mich auch darauf beziehen.
Dies sollte auch mit anderen funktionieren, aber ich habe es nicht getestet.

<!-- more -->

## Einrichten des File Providers

Um unsere Weiterleitungen in Traefik einzubinden, werden wir den [File Provider](https://doc.traefik.io/traefik/providers/file/) verwenden.
Hierfür müssen wir zwei Dinge tun

## Ein Verzeichnis für den File Provider erstellen

Erstelle ein neues Verzeichnis `provider` neben deinem [compose file](https://docs.docker.com/compose/compose-file/compose-file-v3/) und mounte es in deinen Container.

```yml
    volumes:
      - "./provider/:/provider/"
```

### Aktivieren des File Providers in der Konfiguration

Jetzt müssen wir unsere `traefik.yaml` ändern und einen [File Provider](https://doc.traefik.io/traefik/providers/file/) hinzufügen.

```yml
providers:
  file:
    directory: "/provider/"
    watch: true
```

Dadurch kann Traefik jede Datei in unserem Provider-Verzeichnis überwachen.
So können wir mehrere Dateien verwenden, um unsere Provider zu gruppieren und sie besser zu organisieren.
Traefik überwacht auch Änderungen an unseren Providern. Sobald wir also eine Datei bearbeiten, erstellen oder löschen, wirken sich diese Änderungen sofort auf das Routing von Traefik aus.

!!! warning "Warnung"

    Traefik überwacht nur Dateien im Hauptverzeichnis, du kannst also keine Unterverzeichnisse verwenden.

!!! warning "Warnung"

    Vergiss nicht, deinen Traefik-Container neu zu starten.

## Einen Redirect erstellen

Um einen Redirect zu erstellen, brauchen wir zwei Dinge: eine `redirectRegex` [middleware](https://doc.traefik.io/traefik/middlewares/http/redirectregex/) und einen [router](https://doc.traefik.io/traefik/routing/routers/), der die Anfragen annimmt.
Dazu erstellen wir eine Datei `redirect.yml` (der Name ist beliebig) in unserem neuen `provider` Verzeichnis.

!!! Hinweis
    
    Du kannst auch eine Datei für jeden Redirect erstellen.
Ein Shell-Skript dafür findest du [unten](#ein-shell-skript-zur-erstellung-von-weiterleitungen-verwenden)

### Einrichten der redirectRegex Middleware

```yaml
http:
  middlewares: # (1)!
    chojo-dev-redirect: # (2)!
      redirectRegex: # (3)!
        regex: "(.*)" # (4)!
        replacement: "https://chojo.dev/" # (5)!
        permanent: false # (6)!
```

1. Wir erstellen Middlewares, also benutzen wir den Middleware-Abschnitt.
2. Definiere eine neue Middleware mit dem Namen `chojo-dev-redirect`.
3. Definiere den Typ der Middleware als `redirectRegex`.
4. Definiere das Regex-Muster als `(.*)`, das im Grunde auf alles passt. 
Dies ist der Teil der URL, den wir ersetzen wollen.
Wir wollen also wirklich die gesamte Zeichenkette ersetzen.
5. Definiere die neue URL, zu der wir umleiten wollen.
6. Markiere die Weiterleitung als temporär.
Dadurch wird verhindert, dass der Browser zwischenspeichert, und die Änderungen an unserer Weiterleitung werden sofort wirksam.

Wenn du wissen willst, was die einzelnen Zeilen bewirken, sieh dir die Kommentare an.

### Einrichten des Routers

Jeder Router braucht einen Dienst, mit dem er verbunden ist.
Natürlich könnten wir Docker verwenden, um für jede unserer Weiterleitungen einen Dienst zu starten, oder wir könnten einen einzigen Dienst starten und ihn wiederverwenden.
Zum Glück hat traefik bereits vorgesorgt und bietet einen Dienst für genau diesen Anwendungsfall namens `noop@internal`.

!!! Hinweis

    Der Abschnitt `Middlewares` ist immer noch da, ich zeige ihn nur nicht.

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

1. Wir werden einen Router erstellen, also benutzen wir den Abschnitt Router.
2. Definiere einen neuen Router namens `chojo-dev-redirect`. Ich empfehle, den gleichen Namen wie die Middleware zu verwenden, aber das ist nicht erforderlich.
3. Füge den Dienst "noop@internal" zu unserem Router hinzu.
4. Weise den `https` `Eintrittspunkt` zu. Dies kann je nach deiner Einrichtung variieren.
5. Weise die Regel unserem Host zu
6. Weise die Redirect Middleware zu, die wir zuvor definiert haben
7. Weise der zugewiesenen Regel unseren Cert Resolver zu

Warnung!

    Achte darauf, dass du `entrypoint`, `rule` und `certresolver` an deine Bedürfnisse anpasst!

Damit wird unser Dienst erstellt.
Alles, was unserer Regel entspricht, wird nun an die in der Redirect Middleware definierte Domain weitergeleitet.

## Ein Shell-Skript zur Erstellung von Weiterleitungen verwenden.

Ich verwende ein Bash-Skript, um meine Weiterleitungen zu erstellen.

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

Lade es mit diesem command direkt auf deinen server

```sh
wget https://chojo.dev/assets/files/redirect.sh && chmod +x redirect.sh
```

!!! warning "Warnung"

    Lade niemals bash scripte runter ohne einen Blick drauf zu werfen bevor du sie ausführts!

Das Bash-Skript erstellt eine Datei für jede Weiterleitung.
Das macht sie leicht zu finden.
Wenn du sie ändern willst, erstellst du sie einfach erneut mit demselben Namen.

## Danke

{{ blog_footer_de }}
