

use PortfolioProject

SELECT * 
FROM CovidDeaths
ORDER BY 3,4;


-- Cambio el tipo de Dato

EXEC sp_help 'dbo.CovidDeaths';

ALTER TABLE dbo.CovidDeaths
ALTER COLUMN total_deaths float;


-- 

SELECT * 
FROM CovidVaccinations
ORDER BY 3,4;

--  Selecciono los datos que utilizare 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2 ;


-- Total de Casos(Cases) vs. Total de Muertes(Deaths) | Porcentage 
-- Porcentaje total de muertes dependiendo del pais 

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
--WHERE location LIKE '%Dominican%'
ORDER BY 1,2 ;

-- Total Cases vs Population
-- Porcentaje total de casos en cuanto a poblacion

SELECT location, date, total_cases, population,(total_cases/population)*100 as PopulationPercentage
FROM CovidDeaths
WHERE location LIKE '%Dominican%'
ORDER BY 1,2 ;


-- Paises con la tasa mas alta de infeccion en comparacion con su poblacion

SELECT location, population, MAX(total_cases) as MayorCantidadCasos, MAX((total_cases/population))*100 as InfectedPercentage
FROM CovidDeaths
--WHERE location LIKE '%Dominican%'
GROUP BY Location, Population 
ORDER BY InfectedPercentage DESC;


-- Paises con mayor cantidad de muertes

SELECT Location, MAX(Total_deaths) as TotalDeathCount
From CovidDeaths
--WHERE location LIKE '%Dominican%'
WHERE continent IS NOT NULL 
GROUP BY Location
ORDER BY TotalDeathCount DESC;


-- Continentes con mayor cantidad de muertes

SELECT location, MAX(CAST(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
WHERE continent IS NULL AND location NOT IN ('High Income', 'Upper middle income',
'Lower middle income','Low income')
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Continentes con mayor muertes en comparacion con su poblacion

SELECT location, population, MAX(total_deaths) as MayorCantidadMuertes, MAX((total_deaths/population))*100 as DeathPercentage
FROM CovidDeaths
WHERE continent IS NULL
AND location NOT IN ('High Income', 'Upper middle income',
'Lower middle income','Low income')
GROUP BY Location, Population 
ORDER BY DeathPercentage DESC;

-- Porcentage de muertes alrededor del planeta

SELECT 
    MAX(CAST(total_cases AS int)) AS MaxTotalCases, 
    MAX(CAST(total_deaths AS int)) AS MaxTotalDeaths, 
    (MAX(CAST(total_deaths AS int)) * 100.0 / NULLIF(MAX(CAST(total_cases AS int)), 0)) AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY MaxTotalCases, MaxTotalDeaths;


-- Poblacion vs. Vacunados

SELECT dea.continent,
		dea.location,
		dea.date, 
		dea.population, 
		vac.new_vaccinations,
SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.date ) AS VaccCount
FROM CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- Porcentajes de Vacunados (Con Temp Table )

DROP TABLE IF EXISTS #VacunadosPoblacion
CREATE TABLE #VacunadosPoblacion
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
VaccCount numeric
)
INSERT INTO #VacunadosPoblacion
SELECT dea.continent,
		dea.location,
		dea.date, 
		dea.population, 
		vac.new_vaccinations,
SUM(CONVERT(BIGINT, vac.new_vaccinations)) 
OVER (Partition by dea.Location Order by dea.Location, dea.date ) AS VaccCount
FROM CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date
SELECT *, (VaccCount/Population)*100
FROM #VacunadosPoblacion
ORDER BY location, date;




-- *Porcetaje* de Vacunados vs Poblacion


SELECT dea.continent, 
		dea.location,
		dea.date, 
		dea.population,
		vac.total_vaccinations,
		vac.new_vaccinations, 
		vac.people_fully_vaccinated,
		(people_fully_vaccinated/population)*100 AS PorcentajeVacunados
FROM CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
AND vac.location = 'Dominican Republic'
ORDER BY 2,3


-- Crear vista para guardar datos para las visualizaciones 




















