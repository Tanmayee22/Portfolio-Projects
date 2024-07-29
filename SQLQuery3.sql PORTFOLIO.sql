SELECT *
FROM CovidDeaths
WHERE Continent is not NULL
ORDER BY 3,4

--SELECT *
--FROM CovidVaccinations
--ORDER BY 3,4

--Select the data that we're going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE Continent is not NULL
ORDER BY 1,2

---Looking at the total cases vs total deaths
--shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location LIKE '%states'
WHERE Continent is not NULL
ORDER BY 1,2


---Looking at the total cases Vs Population
--- Shows what % of population got covid
SELECT Location, date, total_cases, population, (total_cases/population)*100 AS PercentagePopulationInfected
FROM CovidDeaths
WHERE Continent is not NULL
--WHERE location LIKE '%states%'
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS PercentagePopulationInfected
FROM CovidDeaths
WHERE Continent is not NULL
---WHERE location LIKE '%states%'
GROUP BY Location, population
ORDER BY PercentagePopulationInfected DESC

--Showing countries with highest death count per population
SELECT Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
WHERE Continent is not NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

--Let's break things down by continent
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
WHERE Continent is NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--Showing Continent with highest death count per population
SELECT Continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
WHERE Continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global Numbers

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(New_deaths as int))/SUM(New_cases)*100  AS DeathPercentage
FROM CovidDeaths
WHERE Continent is not NULL
ORDER BY 1,2

--- looking at total population Vs Vaccination

SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM CovidDeaths as dea
JOIN CovidVaccinations AS vac
	 ON dea.location = vac.location
	 and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--- use cte

WITH PopVsVac(continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM CovidDeaths as dea
JOIN CovidVaccinations AS vac
	 ON dea.location = vac.location
	 and dea.date = vac.date
WHERE dea.continent is not null

)

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVsVac

--TEMP table
drop table if exist #PercentPopulationVaccinated 
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM CovidDeaths as dea
JOIN CovidVaccinations AS vac
	 ON dea.location = vac.location
	 and dea.date = vac.date
WHERE dea.continent is not null

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

-- creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM CovidDeaths as dea
JOIN CovidVaccinations AS vac
	 ON dea.location = vac.location
	 and dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM PercentPopulationVaccinated
