FROM python:3.10-bullseye AS base

RUN pip install pipenv

COPY Pipfile Pipfile.lock /

RUN pipenv sync

COPY . .

RUN find docs/ -type f -print0 | xargs -0 sed -i 's/★/:material-star:/g'
RUN find docs/ -type f -print0 | xargs -0 sed -i 's/⯪/:material-star-half-full:/g'
RUN find docs/ -type f -print0 | xargs -0 sed -i 's/☆/:material-star-outline:/g'
RUN find docs/ -type f -print0 | xargs -0 sed -i 's/```kts/```js/g'
RUN find docs/ -type f -print0 | xargs -0 sed -i 's/```kt/```js/g'

RUN pipenv run python tools/build.py

RUN pipenv run mkdocs build -f mkdocs.yml

FROM nginx:alpine

COPY --from=base /site /usr/share/nginx/html

EXPOSE 80
