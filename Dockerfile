FROM python:3.11-bullseye AS base

WORKDIR /docs

COPY . .
RUN pip install mkdocs-material && pip install mkdocs-git-revision-date-localized-plugin

RUN mkdocs build -f mkdocs.yml

FROM nginx:alpine

COPY --from=base /docs/site /usr/share/nginx/html

EXPOSE 80
