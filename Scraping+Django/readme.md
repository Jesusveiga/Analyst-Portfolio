A small web scraping project has been created with Python, culminating with its framework Django.

On the one hand, a scraper was made with Selenium (which later became headless because it was consistent with the app).
We have scraped different web pages of houses in Portugal, obtaining information present in each of them about each house (this is part of the html). Given that in order to obtain certain information it was necessary to do some web crawling,
we had to interact with the JavaScript of the page, and for this reason we used Selenium and not only BeautifulSoup or other libraries.

The scraper has been integrated with Django to offer an interface in which the user can search by exact name of the property, location, price range and can also choose the number of results they want to obtain. 
Internally, the application calls the scraper with these input arguments in the function, the inputs are checked at the filter level and when the set number of results is reached, it is returned to the user in the form of a table in a url.
As a curiosity, we have experimented with a bit of JavaScript in Django to be able to put some interactive content and there has not been any kind of conflict.

Translated with DeepL.com (free version)
