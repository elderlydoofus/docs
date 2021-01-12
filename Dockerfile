FROM python:3.8-slim-buster as common-base


EXPOSE 8080
ENV PYTHONUNBUFFERED=1 \
  PORT=8080 \
  POETRY_VERSION=1.1.4


FROM common-base as base-builder
RUN pip install -U pip && pip install "poetry==$POETRY_VERSION"
RUN mkdir -p /build
WORKDIR /build


FROM base-builder as py-builder
COPY pyproject.toml poetry.lock ./
RUN poetry export -f requirements.txt --output requirements.txt
RUN pip install --no-warn-script-location -r requirements.txt


FROM py-builder as docs-builder
COPY docs/  docs
COPY mkdocs.yml .
RUN mkdocs build


FROM nginx:alpine
COPY --from=docs-builder /build/site /usr/share/nginx/html