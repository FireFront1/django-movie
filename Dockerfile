FROM ubuntu:18.04
FROM python:3.8 as builder

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONNUNBUFFERED 1

RUN apt-get update
RUN apk add postgresql-dev gcc python3-dev musl-dev libc-dev linux-headers

RUN apk add jpeg-dev zlib-dev libjpeg

RUN pip install --upgrade pip
COPY ./requirements.txt .
RUN pip wheel --no-cache-dir --no-deps --wheel-dir /wheels -r req.txt

#### FINAL ####

FROM python:3.8

RUN mkdir /app
COPY . /app
WORKDIR /app

RUN apt-get update && apt-get add libpq
COPY --from=builder ./wheels /wheels
COPY --from=builder ./req.txt .
RUN pip install --no-cache /wheels/*

COPY ./scripts /scripts
RUN chmod +x /scripts/*

RUN mkdir -p /vol/media
RUN mkdir -p /vol/static

RUN chmod -R 755 /vol

ENTRYPOINT ["/scripts/entrypoint.prod.sh"]