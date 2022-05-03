from django_movie.celery import app
import requests
import time


@app.task
def worker_test():
    time.sleep(10)
    requests.get("http://127.0.0.1:8000/")


@app.task
def worker_test2(args):
    return args
