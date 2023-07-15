FROM python:3.10

RUN pip install pipenv

EXPOSE 80

WORKDIR /docs

COPY mkdocs.yml mkdocs.yml

COPY docs/ docs/

COPY .git/ .git/

COPY Pipfile Pipfile.lock /docs/

RUN pipenv install

ENTRYPOINT ["pipenv","run","mkdocs", "serve", "-a", "0.0.0.0:80"]
