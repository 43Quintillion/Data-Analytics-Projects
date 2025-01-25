-- Exploratory Data Analysis Project on 2020-2021 Covid Statistics

SELECT * FROM covid_deaths.covidDeaths
ORDER BY 3,4; 

SELECT * FROM covid_deaths.covidVacs;

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM covid_deaths.covidDeaths
ORDER BY 1,2; 

-- Looking at Total Cases vs Total Deaths
-- Shows probability of dying after contracting covid given you like in Australia
SELECT 
    Location, 
    date, 
    total_cases, 
    total_deaths, 
    ((CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)) * 100) AS death_percentage
FROM covid_deaths.covidDeaths
WHERE location LIKE '%Australia%'
ORDER BY 1, 2;


-- Total Cases vs Population
-- Shows what percentage of population contracted Covid
SELECT 
    Location, 
    date, 
    total_cases,  
	population,
    ((CAST(total_cases AS FLOAT) / CAST(population AS FLOAT)) * 100) AS percentage_infected_population
FROM covid_deaths.covidDeaths
--WHERE location LIKE '%Australia%'
ORDER BY 1, 2;


-- Looking at Countries with Highest Infection Rate compared to Population
SELECT 
    Location, 
	population,
    MAX(total_cases) AS highest_infection_count,  
    MAX(((CAST(total_cases AS FLOAT) / CAST(population AS FLOAT)) * 100)) AS max_prcnt_infected_pop
FROM covid_deaths.covidDeaths
--WHERE location LIKE '%Australia%'
GROUP BY location, population
ORDER BY max_prcnt_infected_pop desc;


-- Showing Countries with Highest Death Count per Population
SELECT 
    location, 
	MAX(total_deaths) AS death_count_total
FROM covid_deaths.covidDeaths
WHERE continent IS NOT NULL AND total_deaths IS NOT NULL
GROUP BY location
ORDER BY death_count_total desc;

-- Continents with Highest Death Count
SELECT
    location, 
	MAX(total_deaths) AS death_count_total
FROM covid_deaths.covidDeaths
WHERE continent IS NULL AND total_deaths IS NOT NULL
GROUP BY location
ORDER BY death_count_total desc;

-- Global Numbers
SELECT
	SUM(new_cases),
	SUM(new_deaths),
	SUM(new_deaths)/SUM(new_cases)*100 AS death_percentage
FROM covid_deaths.covidDeaths
WHERE continent is not null
--GROUP BY date
order by 1, 2; 

-- Showing Total Population vs Vaccinations, Percentage of Population that has recieved at least 1 Covid Vaccine


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS ppl_vaccinatted_rolling_tot
FROM covid_deaths.CovidDeaths dea
JOIN covid_deaths.CovidVacs vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3
;

-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac AS (
    SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations,
        SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date) AS ppl_vaccinated_rolling_tot
    FROM 
        covid_deaths.CovidDeaths dea
    JOIN 
        covid_deaths.CovidVacs vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL
)
SELECT *, (popvsvac.ppl_vaccinated_rolling_tot/population)*100 AS percent_vaccinated_by_population
FROM PopvsVac;



-- Creating Views for Future Visualisations
CREATE VIEW covid_deaths.PercentPopulationVac as
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date) AS ppl_vaccinated_rolling_tot
FROM 
	covid_deaths.CovidDeaths dea
JOIN 
	covid_deaths.CovidVacs vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE 
	dea.continent IS NOT NULL


-- Some of the queried data from this project is used in a Tableau visualisation project
-- Please see here: https://public.tableau.com/app/profile/lam.bui4524/viz/2020-2021CovidStatisticsDashboard/Dashboard1
