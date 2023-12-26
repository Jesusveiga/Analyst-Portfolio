from django import forms

class PropertySearchForm(forms.Form):
    CITY_CHOICES = [
        ('lisboa', 'Lisboa'),
        ('porto', 'Porto'),
        ('braga', 'Braga'),
        ('portimao', 'Portimao'),
        ('guimaraes', 'Guimaraes'),
        ('viana-do-castelo', 'Viana do Castelo'),
        # Agrega aquí más ciudades si lo deseas
    ]
    
    PRICE_CHOICES = [
        ('0-100000', '0-100.000'),
        ('100000-150000', '100.000-150.000'),
        ('150000-200000', '150.000-200.000'),
        ('200000-300000', '200.000-300.000'),
        ('300000-400000', '300.000-400.000'),
        ('400000-500000', '400.000-500.000'),
        ('500000-600000', '500.000-600.000'),
        ('600000-1000000', '600.000-1.000.000'),
        ('1000000-1500000', '1.000.000-1.500.000'),
        ('1500000-10000000', '1.500.000-10.000.000'),
        # ... más rangos ...
    ]

    city = forms.ChoiceField(choices=CITY_CHOICES, required=True, label='Ciudad')
    #title = forms.CharField(required=False, label='Título')
    #square_meters = forms.CharField(required=False, label='Metros Cuadrados')
    price = forms.ChoiceField(choices=PRICE_CHOICES, required=False, label='Rango de Precio')
    under_construction = forms.BooleanField(required=False, label='En Construcción')
    #garage = forms.BooleanField(required=False, label='Garaje')
    #location = forms.CharField(required=False, label='Ubicación')
    num_matches = forms.IntegerField(required=True, label='Número de Coincidencias')