from django.shortcuts import render, redirect
from .forms import PropertySearchForm
from .models import Property
from .scraper import run_scraper
from django.urls import reverse

def search_properties(request):
    if request.method == 'POST':
        form = PropertySearchForm(request.POST)
        if form.is_valid():
            # Extraer los datos del formulario
            city = form.cleaned_data.get('city')
            title = form.cleaned_data.get('title')
            #square_meters = form.cleaned_data.get('square_meters')
            price_range_str = form.cleaned_data.get('price')  # Esto será una cadena como "100-200"
            price_range = None
            if price_range_str:
                min_price, max_price = map(int, price_range_str.split('-'))
                price_range = (min_price, max_price)
            under_construction = form.cleaned_data.get('under_construction')
            #garage = form.cleaned_data.get('garage')
            location = form.cleaned_data.get('location')
            num_matches = form.cleaned_data.get('num_matches')

            # Borra los resultados de las búsquedas anteriores de la base de datos
            Property.objects.all().delete()

            # Pasar los datos a la función run_scraper
            properties_info = run_scraper(city, title, price_range, under_construction, location, num_matches)

            for info in properties_info:
                Property.objects.create(**info)

            # Redirige al usuario a una página de resultados.
            return redirect(reverse('results'))  # Asegúrate de que existe una vista llamada 'results'
    else:
        form = PropertySearchForm()

    return render(request, 'search.html', {'form': form})

def results(request):
    properties = Property.objects.all()  # Obtén todas las propiedades de la base de datos
    return render(request, 'results.html', {'properties': properties})