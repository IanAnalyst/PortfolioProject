--PortfolioProject1
--Ian Sweigart 3/31/2023

USE PortfolioProject

--TOTAL CASES VS TOTAL DEATHS
--LIKELIHOOD OF DYING IN USA
SELECT location,date,total_cases,total_deaths,
ROUND((total_deaths/total_cases)*100,2) as DeathPercentage
FROM [PortfolioProject].[dbo].[CovidDeaths$]
Where location LIKE '%states%'
ORDER BY 1,2

--TOTAL CASES vs POPULATION
--SHOWS WHAT % OF POP GOT COVID IN USA
SELECT location,date,total_cases,population,
ROUND((total_cases/population)*100,2) AS InfectPercentage
FROM [PortfolioProject].[dbo].[CovidDeaths$]
WHERE location LIKE '%states%'
ORDER BY 1,2

--COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION
SELECT Location,population,MAX(total_cases) AS HighestInfectionCount,
ROUND(MAX((total_cases/population))*100,2) AS PercentPopulationInfected
FROM [PortfolioProject].[dbo].[CovidDeaths$]
GROUP BY location,population
ORDER BY PercentPopulationInfected DESC

--COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION
SELECT location,MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM [PortfolioProject].[dbo].[CovidDeaths$]
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--LET'S BREAK THINGS DOWN BY CONTINENT

--CONTINENTS WITH THE HIGHEST DEATH COUNT PER POPULATION
SELECT continent,MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM [PortfolioProject].[dbo].[CovidDeaths$]
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS
SELECT SUM(new_cases) AS TotalCases,SUM(CAST(new_deaths AS INT)) AS TotalDeaths,
ROUND(SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100,2) AS DeathPercentage
FROM [PortfolioProject].[dbo].[CovidDeaths$]
WHERE continent IS NOT NULL
ORDER BY 1,2

--TOTAL POPULATION vs TOTAL VACCINATION
--SHOWS LATEST INFORMATION IN DATABASE
SELECT dea.continent,dea.location,dea.date,
dea.population,
SUM(CAST(vac.new_vaccinations AS INT)) OVER 
(PARTITION BY dea.location ORDER BY dea.location,dea.date) 
AS TotalPeopleVaccinated
FROM [PortfolioProject].[dbo].[CovidDeaths$] dea
JOIN [PortfolioProject].[dbo].[CovidVaccinations$] vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL AND dea.date='2021-04-30'
ORDER BY 2

--CTE showing % of population in USA that is vaccinated
WITH PopvsVac (Continent,Location,Date,Population,new_vaccinations,RollingPeopleVaccinated) AS (
SELECT dea.continent,dea.location,dea.date,
dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER 
(PARTITION BY dea.location order BY dea.location,dea.date) 
AS RollingPeopleVaccinated
FROM [PortfolioProject].[dbo].[CovidDeaths$] dea
JOIN [PortfolioProject].[dbo].[CovidVaccinations$] vac
ON dea.location=vac.location
and dea.date=vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *,ROUND((RollingPeopleVaccinated/Population)*100,2) as PercentVaccinated
FROM PopvsVac
WHERE Location LIKE '%states%'
ORDER BY PercentVaccinated DESC

--TEMPORARY TABLE SHOWING PERCENTAGE OF VACCINATIONS IN USA
DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,
dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER 
(partition by dea.location ORDER BY dea.location,dea.date) 
AS RollingPeopleVaccinated
FROM [PortfolioProject].[dbo].[CovidDeaths$] dea
JOIN [PortfolioProject].[dbo].[CovidVaccinations$] vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

SELECT *,CAST((RollingPeopleVaccinated/Population)*100 AS DECIMAL(4,2))
AS PercentageVaccinated
FROM #PercentPopulationVaccinated
WHERE Location LIKE '%states%'
ORDER BY 3 ASC

--CREATE VIEW 1
DROP VIEW IF EXISTS PercentPopulationVaccinated
CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent,dea.location,dea.date,
dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER 
(PARTITION BY dea.location order BY dea.location,dea.date) 
AS RollingPeopleVaccinated
FROM [PortfolioProject].[dbo].[CovidDeaths$] dea
JOIN [PortfolioProject].[dbo].[CovidVaccinations$] vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL

SELECT *, CAST((RollingPeopleVaccinated/population)*100 AS DECIMAL (4,2)) 
AS PercentageVaccinated
FROM PercentPopulationVaccinated
WHERE location LIKE '%states%'

--SECOND VIEW
DROP VIEW IF EXISTS PercentCaseDeaths
CREATE VIEW PercentCaseDeaths AS 
SELECT Location,Date,Total_Cases,Total_Deaths,
CAST((Total_Deaths/Total_Cases)*100 AS DECIMAL (4,2)) AS DeathPercentage
FROM [PortfolioProject].[dbo].[CovidDeaths$]
WHERE location LIKE '%states%'

SELECT *
FROM PercentCaseDeaths
