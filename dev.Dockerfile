FROM python:3.10

RUN pip install pipenv

EXPOSE 80

WORKDIR /docs

COPY mkdocs.yml mkdocs.yml

COPY .git/ .git/

COPY tools tools
COPY templates templates

COPY Pipfile Pipfile.lock /docs/

RUN pipenv sync

COPY docs/ docs/

COPY code/minecraft_gradle/gradle gradle

RUN pipenv run python tools/build.py

ENTRYPOINT ["pipenv","run","mkdocs", "serve", "-a", "0.0.0.0:80"]
