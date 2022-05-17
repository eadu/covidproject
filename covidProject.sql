-- Total cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT [location], [date], total_cases, total_deaths, (CAST(total_deaths AS float)/CAST(total_cases AS float)) * 100 AS DeathPercentage
FROM [PortfolioProject]..[covidDeaths]
WHERE [total_cases] IS NOT NULL AND [location] LIKE '%state%';


-- Total Cases vs Population
-- Shows what percentage of population got covid
SELECT [location], [date], total_cases, [population], (CAST(total_cases AS float)/CAST(population AS float)) * 100 AS InfectedPopulation
FROM [PortfolioProject]..[covidDeaths]
WHERE [total_cases] IS NOT NULL AND [location] LIKE '%state%';

-- Looking at countries with higherst infection rate compated to population
SELECT [location], max(total_cases) as HighestInfectionCount, [population], MAX(CAST(total_cases AS float)/CAST(population AS float)) * 100 AS InfectedPopulation
FROM [PortfolioProject]..[covidDeaths]
GROUP BY [population], [location]
ORDER BY InfectedPopulation DESC

-- Highest death count per population
SELECT [location], MAX(total_deaths) as TotalDeathCount
FROM [PortfolioProject]..[covidDeaths]
WHERE continent IS NOT NULL
GROUP BY [location]
ORDER BY TotalDeathCount DESC

-- Highest death count per population
SELECT [continent], MAX(total_deaths) as TotalDeathCount
FROM [PortfolioProject]..[covidDeaths]
WHERE continent IS NOT NULL
GROUP BY [continent]
ORDER BY TotalDeathCount DESC

-- Global Numbers
SELECT [date], SUM(new_cases) AS WorldCases, SUM(new_deaths) AS WorldDeaths, SUM(CAST(new_deaths AS float))/SUM(new_cases)*100 AS DeathPercentage
FROM [PortfolioProject]..[covidDeaths]
WHERE [continent] IS NOT NULL AND new_cases IS NOT NULL
GROUP BY [date]
ORDER BY 1

-- Total Global Numbers
SELECT SUM(new_cases) AS WorldCases, SUM(new_deaths) AS WorldDeaths, SUM(CAST(new_deaths AS float))/SUM(new_cases)*100 AS DeathPercentage
FROM [PortfolioProject]..[covidDeaths]
WHERE [continent] IS NOT NULL AND new_cases IS NOT NULL
ORDER BY 1

SELECT * 
FROM [PortfolioProject]..[covidDeaths]
JOIN [PortfolioProject]..[covidVaccinations]
    ON covidDeaths.[location] = covidVaccinations.[location] AND covidDeaths.[date] = covidVaccinations.[date]

-- Total Population vs Vaccinations
-- SUM(CAST(new_vaccinations AS BIGINT)) OVER (PARTITION BY [covidDeaths].[location]) MEANS CALUCULATE THE SUM OF NEW VACSSINATION BY LOCATION
SELECT covidVaccinations.continent, covidVaccinations.[location], covidVaccinations.[date], [population], new_vaccinations, 
SUM(CAST(new_vaccinations AS BIGINT)) OVER (PARTITION BY [covidDeaths].[location] ORDER BY covidDeaths.location, covidDeaths.date) AS RollingPeopleVaccinated
FROM [PortfolioProject]..[covidDeaths]
JOIN [PortfolioProject]..[covidVaccinations]
    ON [covidDeaths].[location] = [covidVaccinations].[location] AND [covidDeaths].[date] = [covidVaccinations].[date]
WHERE [covidVaccinations].continent IS NOT NULL
ORDER BY 2, 3


-- CTE
With PopVac (Continent, Location, Date, Population, NewVaccinations, RollingPeopleVaccinated)
AS (
    SELECT covidVaccinations.continent, covidVaccinations.[location], covidVaccinations.[date], [population], new_vaccinations, 
SUM(CAST(new_vaccinations AS BIGINT)) OVER (PARTITION BY [covidDeaths].[location] ORDER BY covidDeaths.location, covidDeaths.date) AS RollingPeopleVaccinated
FROM [PortfolioProject]..[covidDeaths]
JOIN [PortfolioProject]..[covidVaccinations]
    ON [covidDeaths].[location] = [covidVaccinations].[location] AND [covidDeaths].[date] = [covidVaccinations].[date]
WHERE [covidVaccinations].continent IS NOT NULL
)
SELECT *, (CAST(RollingPeopleVaccinated AS float)/Population)
FROM PopVac


-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated (
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    new_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC,
)

--creating view to store data
USE PortfolioProject
CREATE VIEW [PercentPopulationVaccinated] AS
    SELECT covidVaccinations.continent, covidVaccinations.[location], covidVaccinations.[date], [population], new_vaccinations, 
SUM(CAST(new_vaccinations AS BIGINT)) OVER (PARTITION BY [covidDeaths].[location] ORDER BY covidDeaths.location, covidDeaths.date) AS RollingPeopleVaccinated
FROM [PortfolioProject]..[covidDeaths]
JOIN [PortfolioProject]..[covidVaccinations]
    ON [covidDeaths].[location] = [covidVaccinations].[location] AND [covidDeaths].[date] = [covidVaccinations].[date]
WHERE [covidVaccinations].continent IS NOT NULL
