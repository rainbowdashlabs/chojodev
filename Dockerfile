FROM python:3.10-bullseye AS base

COPY Pipfile Pipfile.lock /

RUN pip install pipenv && pipenv install

COPY . .

RUN find docs/ -type f -print0 | xargs -0 sed -i 's/★/:material-star:/g'
RUN find docs/ -type f -print0 | xargs -0 sed -i 's/⯪/:material-star-half-full:/g'
RUN find docs/ -type f -print0 | xargs -0 sed -i 's/☆/:material-star-outline:/g'

RUN pipenv run mkdocs build -f mkdocs.yml

FROM nginx:alpine

COPY --from=base /site /usr/share/nginx/html
COPY assets/ /usr/share/nginx/html/assets/

EXPOSE 80
