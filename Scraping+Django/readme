Se ha creado un pequeño proyecto de web scraping con Python, culminándolo con su framework de trabajo Django.

Por un lado se ha hecho un scraper con Selenium (que posteriormente ha pasado a ser headless por ser consecuente con la app).
Se han scrapeado diferentes páginas web de viviendas en Portugal, obteniendo información presente en cada una de ellas referente a cada vivienda (esto es parte del html). Dado que para la obtención de cierta infromación se tenía que hacer un poco de web crawling,
se ha tenido que interactuar con JavaScript de la página, y es por este motivo por el que se ha usado Selenium y no únicamente BeautifulSoup u otras librerías.

Se ha integrado el scraper con Django para ofrecer una interfaz en la que el usuario pueda buscar por nombre excato de la vivienda, localización, rango de precios y pueda elegir también el número de resultados que quiere obtener. 
Internamente la aplicación llama al scraper con esos argumentos de entrada en al función, se comprueban los inputs a nivel de filtros y cuando se llegue al número de resultados fijado, se devuelve en forma de tabla en una url al usuario.
A modo de curiosidad se ha experimentado con un poco de JavaScript en el Django para poder meter cierto contenido interactivo y no ha habido ningún tipo de conflicto.
