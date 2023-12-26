from selenium.webdriver.chrome.options import Options

def run_scraper(city='lisboa', title=None, price_range=None, under_construction=None, location=None, num_matches=None):
    print(f"""Parámetros recibidos: city={city}, title={title}, price={price_range},
          under_construction={under_construction}, location={location}, num_matches={num_matches}""")
    import pandas as pd
    from selenium import webdriver
    from selenium.webdriver.common.by import By
    from selenium.webdriver.chrome.service import Service
    from webdriver_manager.chrome import ChromeDriverManager
    from selenium.common.exceptions import NoSuchElementException, ElementClickInterceptedException
    from selenium.webdriver.support.ui import WebDriverWait
    from selenium.webdriver.support import expected_conditions as EC
    import time

    # Configurar el webdriver para usar Chrome
    webdriver_service = Service(ChromeDriverManager().install())
    
    # Configurar opciones para Chrome
    options = Options()
    options.add_argument("--headless")  # Ejecutar en modo headless
    options.add_argument("user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3")

    driver = webdriver.Chrome(service=webdriver_service, options=options)

    # Abrir la URL en el navegador con el webdriver
    url = f"https://casa.sapo.pt/es-es/comprar-pisos-apartamentos/{city}/"
    driver.get(url)

    # Crear una lista para almacenar la información de cada propiedad
    properties_info = []

    page_number = 1
    found = False

    try:
        while not found:
            # Esperar a que la página se cargue completamente
            time.sleep(5)

            # Extraer la información deseada de los elementos HTML
            properties = driver.find_elements(By.CLASS_NAME, 'property-info')

            for property in properties:
                # Extraer el título
                property_title = property.find_element(By.CLASS_NAME, 'property-type').text.strip()

                # Extraer los metros cuadrados
                features = property.find_element(By.CLASS_NAME, 'property-features-text')
                property_square_meters = None
                property_under_construction = None
                if features:
                    feature_text = features.text.strip()
                    property_square_meters = feature_text.split('·')[1].strip() if '·' in feature_text else None
                    if property_square_meters:
                        property_square_meters = int(property_square_meters.replace('m²', ''))  # Convertir a número
                    property_under_construction = 'En construcción' in feature_text or 'Em construção' in feature_text

                # Extraer el precio
                property_price = property.find_element(By.CLASS_NAME, 'property-price-value').text.strip()
                property_price = property_price.replace('€', '').replace('.', '')
                property_price = float(property_price)

                # Verificar si el precio está dentro de alguno de los rangos
                price_match = not price_range or price_range[0] <= property_price <= price_range[1]

                # Verificar si tiene garaje
                property_garage = False
                try:
                    garage_div = property.find_element(By.XPATH, ".//div[@class='property-features-tag']")
                    garage_element = garage_div.find_element(By.XPATH, ".//span[text()='Com Garagem' or text()='Con Garage']")
                    property_garage = garage_element is not None
                except NoSuchElementException:
                    pass

                # Extraer la ubicación
                property_location = property.find_element(By.CLASS_NAME, 'property-location').text.strip()

                if price_match and \
                    (not title or title in property_title) and \
                    (under_construction is None or (property_under_construction is not None and under_construction == property_under_construction)) and \
                    (not location or str(location) in property_location):
                        # Si todos los criterios coinciden, añadir la propiedad a la lista
                        properties_info.append({
                            'title': property_title,
                            'square_meters': property_square_meters,
                            'price': property_price,
                            'under_construction': property_under_construction,
                            'location': property_location
                        })

                        print(f"Encontrada propiedad: {property_title}, {property_square_meters}, {property_price}, {property_under_construction}, {property_garage}, {property_location}")

                        # Si se ha alcanzado el número deseado de coincidencias, salir del bucle
                        if num_matches is not None and len(properties_info) >= num_matches:
                            found = True
                            break

            print(f"Finalizada página {page_number}. Propiedades encontradas: {len(properties_info)}")

            if found:
                break

            if not found:
                page_number += 1

                # Buscar el enlace a la página siguiente y hacer clic en él
                next_page = WebDriverWait(driver, 10).until(EC.element_to_be_clickable((By.XPATH, f"//a[@href='/es-es/comprar-pisos-apartamentos/{city}/?pn={page_number}']")))
                driver.execute_script("arguments[0].scrollIntoView();", next_page)
                next_page.click()
    except NoSuchElementException:
        # Si no hay enlace a la página siguiente, salir del bucle
        print("No se encontró el enlace a la página siguiente. Finalizando...")
        pass
    except ElementClickInterceptedException:
        # Si el elemento no es clickeable, salir del bucle
        print("El elemento no es clickeable. Finalizando...")
        pass
    finally:
        # Cerrar el navegador
        driver.quit()

    # Devolver la lista de propiedades
    return properties_info