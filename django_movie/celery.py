import os

from celery import Celery
from celery.schedules import crontab

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'django_movie.settings')

app = Celery('test_celery')  # set name for celery
app.config_from_object('django.conf:settings', namespace='CELERY')  # config django
app.autodiscover_tasks()


app.conf.beat_schedule = {
    'send-spam-every-10-seconds': {
        'task': 'movies.tasks.worker_test',
        'schedule': crontab(minute='*/1')
    }
}
