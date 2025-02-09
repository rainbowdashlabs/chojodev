FROM python:3.11-bullseye AS base

RUN pip install pipenv

COPY Pipfile Pipfile.lock /

# Hack to speedup pipenv buggy behaviour of being slow af in docker
RUN pipenv requirements > requirements.txt
RUN pip install -r requirements.txt
RUN pipenv sync -v --site-packages

COPY . .

RUN find docs/ -type f -print0 | xargs -0 sed -i 's/★/:material-star:/g'
RUN find docs/ -type f -print0 | xargs -0 sed -i 's/⯪/:material-star-half-full:/g'
RUN find docs/ -type f -print0 | xargs -0 sed -i 's/☆/:material-star-outline:/g'
RUN find docs/ -type f -print0 | xargs -0 sed -i 's/```kts/```js/g'
RUN find docs/ -type f -print0 | xargs -0 sed -i 's/```kt/```js/g'
RUN grep "distributionUrl" code/minecraft_gradle/gradle/wrapper/gradle-wrapper.properties | grep -oP 'gradle-\K.*(?=-bin.zip)' > templates/gradle.md
RUN pipenv run python tools/build.py

RUN pipenv run mkdocs build -f mkdocs.yml

FROM nginx:alpine

COPY --from=base /site /usr/share/nginx/html

EXPOSE 80
