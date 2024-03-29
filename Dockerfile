###########
# BUILDER #
###########

FROM python:3.8 as builder

WORKDIR /usr/src/app

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# установка зависимостей
RUN apt-get update && apt-get -y upgrade
RUN pip install --upgrade pip

# установка зависимостей
COPY ./requirements.txt .
RUN pip install --upgrade pip
RUN pip install wheel
RUN pip install -r requirements.txt


#########
# FINAL #
#########

FROM python:3.8

# создаем директорию для пользователя
RUN mkdir -p /home/app

# создаем отдельного пользователя
RUN adduser app

# создание каталога для приложения
ENV HOME=/home/app
ENV APP_HOME=/home/app/web
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

# установка зависимостей и копирование из builder
RUN apt-get update

# копирование entrypoint-prod.sh
COPY scripts/entrypoint.prod.sh $APP_HOME

# копирование проекта Django
COPY . $APP_HOME

# изменение прав для пользователя app
RUN chmod -R 755 $APP_HOME
RUN chown -R app:app $APP_HOME

# изменение рабочего пользователя
USER app

ENTRYPOINT ["/home/app/web/entrypoint.prod.sh"]