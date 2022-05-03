from django.db.models import Q
from django.shortcuts import render, redirect
from django.views import View
from django.views.generic import DetailView, ListView
from .tasks import worker_test, worker_test2

from .forms import ReviewForm, RatingForm
from .models import Movie, Category, Actor, Genre


class GenreYear:
    """Жанры и года выхода фильмов"""

    def get_genres(self):
        return Genre.objects.all()

    def get_years(self):
        return Movie.objects.filter(draft=False).values("year")


class TestCelery(View):
    def get(self, request):
        # worker_test.apply_async(countdown=10)  # Отложеннный запуск через 10 секунд
        # worker_test.delay()  # Запуск в момент вызова
        # worker_test2.delay(2)
        return render(request, 'base.html', {})


class MoviesView(GenreYear, ListView):  # template_name указывать только в том случае если шаблон оканчивается не на _list
    """Список фильмов"""
    model = Movie
    movies = Movie.objects.filter(draft=False)


class FilterMoviesView(ListView):
    """Фильтр фильмов"""

    def get_queryset(self):
        queryset = Movie.objects.filter(Q(year__in=self.request.GET.getlist("year")) |
                                        Q(genres__in=self.request.GET.getlist("genre")))
        return queryset


class MovieDetailView(GenreYear, DetailView):  # template_name указывать только в том случае если шаблон оканчивается не на _detail
    """Полное описание фильма"""
    model = Movie
    slug_field = "url"  # По какому полю искать запись

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context["start_form"] = RatingForm()
        return context


class AddReview(View):
    """Отзывы"""
    def post(self, request, pk):
        movie = Movie.objects.get(id=pk)
        form = ReviewForm(request.POST)
        if form.is_valid():
            print(request.POST)
            form = form.save(commit=False)
            if request.POST.get("parent", None):
                form.parent_id = int(request.POST.get("parent"))
            form.movie = movie
            form.save()
        return redirect(movie.get_absolute_url())


class ActorView(DetailView):
    model = Actor
    template_name = 'movies/actor.html'
    slug_field = 'name'  # Поле по которому будем искать актеров
