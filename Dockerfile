###########
# BUILDER #
###########

FROM python:3.8.3-alpine as builder

WORKDIR /usr/src/app

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# установка зависимостей
RUN apk update \
    && apk add postgresql-dev gcc python3-dev musl-dev
RUN pip install --upgrade pip

# установка зависимостей
COPY ./requirements.txt .
RUN pip install --upgrade pip
RUN apt-get install -y python3-dev
RUN apt-get install -y libevent-dev
RUN pip install setuptools
RUN pip install pyparser
RUN pip install pyparsing
RUN pip install wheel
RUN pip install -r requirements.txt


#########
# FINAL #
#########

#nginx settings
FROM nginx:latest

COPY ./default.conf  /etc/nginx/conf.d/default.conf

FROM python:3.8.3-alpine

# создаем директорию для пользователя
RUN mkdir -p /home/app

# создаем отдельного пользователя
RUN addgroup -S app && adduser -S app -G app

# создание каталога для приложения
ENV HOME=/home/app
ENV APP_HOME=/home/app/web
RUN mkdir $APP_HOME
RUN mkdir $APP_HOME/static
RUN mkdir $APP_HOME/media
WORKDIR $APP_HOME

# установка зависимостей и копирование из builder
RUN apk update && apk add libpq
COPY --from=builder /usr/src/app/wheels /wheels
COPY --from=builder /usr/src/app/requirements.txt .
RUN pip install --no-cache /wheels/*

# копирование entrypoint-prod.sh
COPY scripts/entrypoint.prod.sh $APP_HOME

# копирование проекта Django
COPY . $APP_HOME

# изменение прав для пользователя app
RUN chown -R app:app $APP_HOME

# изменение рабочего пользователя
USER app

ENTRYPOINT ["/home/app/web/entrypoint.prod.sh"]