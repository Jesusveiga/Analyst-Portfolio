-- Seleccionar las primeras 10 filas de la tabla COVID_Deaths ordenadas por la tercera y cuarta columna (Date y Population).
SELECT TOP 10 * FROM [portfolio covid]..COVID_Deaths
ORDER BY 3,4;

-- Seleccionar todas las filas de la tabla COVID_vacunas ordenadas por la tercera y cuarta columna (Date y Population).
SELECT * FROM [portfolio covid]..COVID_vacunas
ORDER BY 3,4;

-- Seleccionar datos específicos de COVID_Deaths (location, date, total_cases, new_cases, total_deaths, population) y ordenar por location y date.
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [portfolio covid]..COVID_Deaths
ORDER BY 1,2;

-- Calcular el porcentaje de muertes en España (o cualquier otro país especificado en el WHERE).
SELECT TOP 100 location, date, total_cases, total_deaths, 
       CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0) * 100 AS porcentaje_muerte
FROM [portfolio covid]..COVID_Deaths
WHERE location LIKE '%spain%'
ORDER BY 1,2;

-- Calcular la incidencia en España (o cualquier otro país especificado en el WHERE) en comparación con la población.
SELECT TOP 100 location, date, population, total_cases, 
       CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0) * 100 AS incidencia
FROM [portfolio covid]..COVID_Deaths
WHERE location LIKE '%spain%'
AND continent IS NOT NULL
ORDER BY 1,2;

-- Calcular la incidencia total en comparación con la población para los países.
SELECT TOP 20 location, population, MAX(total_cases) as maximos_totales, 
       CONVERT(float, MAX(total_cases)) / NULLIF(CONVERT(float, population), 0) * 100 AS incidencia_total
FROM [portfolio covid]..COVID_Deaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY incidencia_total;

-- Calcular el máximo de muertes por país.
SELECT TOP 20 location, MAX(CAST(CAST(total_deaths AS decimal(10,2)) AS int)) AS maximo_muertes
FROM [portfolio covid]..COVID_Deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY maximo_muertes DESC;

-- Calcular el máximo de muertes por ubicación sin especificar el continente.
SELECT TOP 20 location, MAX(CAST(CAST(total_deaths AS decimal(10,2)) AS int)) AS maximo_muertes
FROM [portfolio covid]..COVID_Deaths
WHERE continent IS NULL
GROUP BY location
ORDER BY maximo_muertes DESC;

-- Calcular el ratio por día en el mundo.
SELECT TOP 100
    date,
    SUM(CAST(CAST(new_cases AS decimal(10,2)) AS int)) AS total_casos,
    SUM(CAST(CAST(new_deaths AS decimal(10,2)) AS int)) AS total_muertes,
    CASE
        WHEN COALESCE(SUM(CAST(CAST(new_cases AS decimal(10,2)) AS int)), 0) = 0
        THEN NULL
        ELSE CAST(SUM(CAST(CAST(new_deaths AS decimal(10,2)) AS int)) AS decimal(10,2)) / 
             NULLIF(SUM(CAST(CAST(new_cases AS decimal(10,2)) AS int)), 0)
    END AS porcentaje_muertes
FROM [portfolio covid]..COVID_Deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date, total_casos;

-- Calcular el ratio total hasta la fecha 24/12/2023 en el mundo.
SELECT TOP 100
    SUM(CAST(CAST(new_cases AS decimal(10,2)) AS int)) AS total_casos,
    SUM(CAST(CAST(new_deaths AS decimal(10,2)) AS int)) AS total_muertes,
    CASE
        WHEN COALESCE(SUM(CAST(CAST(new_cases AS decimal(10,2)) AS int)), 0) = 0
        THEN NULL
        ELSE CAST(SUM(CAST(CAST(new_deaths AS decimal(10,2)) AS int)) AS decimal(10,2)) / 
             NULLIF(SUM(CAST(CAST(new_cases AS decimal(10,2)) AS int)), 0)
    END AS porcentaje_muertes
FROM [portfolio covid]..COVID_Deaths
WHERE continent IS NOT NULL;

-- Calcular el total de gente vacunada en el mundo.
SELECT TOP 2000
    mu.continent,
    mu.location,
    mu.date,
    mu.population,
    vac.new_vaccinations,
    SUM(TRY_CAST(vac.new_vaccinations AS decimal(18, 2))) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated,
    (SUM(TRY_CAST(vac.new_vaccinations AS decimal(18, 2))) OVER (PARTITION BY dea.location ORDER BY dea.date) / mu.population) * 100 AS PercentageVaccinated
FROM
    [portfolio covid]..COVID_Deaths mu
JOIN
    [portfolio covid]..COVID_vacunas vac ON mu.location = vac.location AND mu.date = vac.date
WHERE
    mu.continent IS NOT NULL
ORDER BY
    mu.location,
    mu.date;

-- Usar un CTE para realizar cálculos en la partición de la consulta anterior.
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Vacuna_acumulados)
AS
(
    SELECT TOP 100
        mu.continent,
        mu.location,
        mu.date,
        mu.population,
        vac.new_vaccinations,
        SUM(TRY_CAST(vac.new_vaccinations AS decimal(18, 2))) OVER (PARTITION BY mu.Location ORDER BY mu.location, mu.Date) AS Vacuna_acumulados
    FROM
        [portfolio covid]..COVID_Deaths mu
    JOIN
        [portfolio covid]..COVID_vacunas vac ON mu.location = vac.location AND mu.date = vac.date
    WHERE
        mu.continent IS NOT NULL 
    ORDER BY
        mu.location,
        mu.date
)
SELECT TOP 100
    *,
    (Vacuna_acumulados / Population) * 100 AS PorcentajeVacunados
FROM
    PopvsVac;

-- Usar una tabla temporal para realizar cálculos en la partición de la consulta anterior.
DROP TABLE IF EXISTS #PercentPopulationVaccinated;
CREATE TABLE #PercentPopulationVaccinated
(
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_Vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);

INSERT INTO #PercentPopulationVaccinated
SELECT mu.continent, mu.location, mu.date, mu.population, vac.new_vaccinations,
       SUM(TRY_CAST(vac.new_vaccinations AS decimal(18, 2))) OVER (PARTITION BY mu.Location ORDER BY mu.location, mu.Date) AS RollingPeopleVaccinated
FROM [portfolio covid]..COVID_Deaths mu 
JOIN [portfolio covid]..COVID_vacunas vac
    ON mu.location = vac.location
    AND mu.date = vac.date;

-- Seleccionar resultados de la tabla temporal.
SELECT *,
       (RollingPeopleVaccinated / Population) * 100 AS PorcentajeVacunados
FROM #PercentPopulationVaccinated;

-- Crear una vista para almacenar datos para visualizaciones posteriores.
-- Eliminar la vista si ya existe
IF OBJECT_ID('PercentPopulationVaccinated', 'V') IS NOT NULL
    DROP VIEW PercentPopulationVaccinated;

-- Crear una nueva vista
CREATE VIEW PercentPopulationVaccinated AS
SELECT mu.continent, mu.location, mu.date, mu.population, vac.new_vaccinations,
       SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY mu.Location ORDER BY mu.location, mu.Date) AS RollingPeopleVaccinated
FROM [portfolio covid]..COVID_Deaths mu 
JOIN [portfolio covid]..COVID_vacunas vac
    ON mu.location = vac.location
    AND mu.date = vac.date
WHERE mu.continent IS NOT NULL;

