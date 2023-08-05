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
