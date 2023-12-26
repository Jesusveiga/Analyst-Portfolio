-- Consultas utilizadas para el Proyecto Tableau

-- 1. Estadísticas Globales
-- Calcular el ratio por día en el mundo.
SELECT 
    date,
    SUM(CAST(CAST(new_cases AS decimal(10,2)) AS int)) AS total_casos,
    SUM(CAST(CAST(new_deaths AS decimal(10,2)) AS int)) AS total_muertes,
    CASE
        WHEN COALESCE(SUM(CAST(CAST(new_cases AS decimal(10,2)) AS int)), 0) = 0
        THEN NULL
        ELSE CAST(SUM(CAST(CAST(new_deaths AS decimal(10,2)) AS int)) AS decimal(10,2))*100 / 
             NULLIF(SUM(CAST(CAST(new_cases AS decimal(10,2)) AS int)), 0)
    END AS porcentaje_muertes
FROM [portfolio covid]..COVID_Deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date, total_casos;


--En total sin ser por fecha 

SELECT 
    SUM(CAST(CAST(new_cases AS decimal(10,2)) AS int)) AS total_casos,
    SUM(CAST(CAST(new_deaths AS decimal(10,2)) AS int)) AS total_muertes,
    CASE
        WHEN COALESCE(SUM(CAST(CAST(new_cases AS decimal(10,2)) AS int)), 0) = 0
        THEN NULL
        ELSE CAST(SUM(CAST(CAST(new_deaths AS decimal(10,2)) AS int)) AS decimal(10,2))*100 / 
             NULLIF(SUM(CAST(CAST(new_cases AS decimal(10,2)) AS int)), 0)
    END AS porcentaje_muertes
FROM [portfolio covid]..COVID_Deaths
WHERE continent IS NOT NULL
ORDER BY 1,2;



-- 2. Total de Muertes por Ubicación
SELECT location, MAX(CAST(CAST(total_deaths AS decimal(10,2)) AS int)) AS maximo_muertes
FROM [portfolio covid]..COVID_Deaths
Where continent is null 
and location not in ('World', 'European Union', 'International', 'High income','Upper middle income', 'Lower middle income', 'Low income')
GROUP BY location
ORDER BY maximo_muertes DESC;

-- 3. Infecciones y Porcentaje de la Población Infectada

SELECT TOP 20 location, population, MAX(total_cases) as maximos_totales, 
       CONVERT(float, MAX(total_cases)) / NULLIF(CONVERT(float, population), 0) * 100 AS incidencia_total
FROM [portfolio covid]..COVID_Deaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY incidencia_total DESC;

-- 4. Infecciones y Porcentaje de la Población Infectada por Fecha
SELECT 
    Location, 
    Population,
    date, 
    MAX(TRY_CAST(total_cases AS int)) as MayorCantidadInfecciones,  
    MAX(TRY_CAST(total_cases AS decimal(10, 2))) / TRY_CAST(Population AS decimal(18, 2)) * 100 as PorcentajePoblacionInfectada
FROM [portfolio covid]..COVID_Deaths
GROUP BY Location, Population, date
ORDER BY PorcentajePoblacionInfectada DESC;


