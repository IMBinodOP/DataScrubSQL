SELECT continent
FROM PortfolioProject..CovDeaths$
WHERE continent IS NOT NULL
--ORDER BY 3,4

SELECT * 
FROM PortfolioProject..CovVaccine$
ORDER BY 3,4

--Select Data that we are going to be using

SELECT 
	location, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	Population
FROM PortfolioProject..CovDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2

--Total Cases vs Total_Deaths
--Shows the death percentage
SELECT 
	Location, 
	date, 
	total_cases, 
	total_deaths, 
	(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
FROM PortfolioProject..CovDeaths$
WHERE location like '%india%' AND continent IS NOT NULL
ORDER BY 1,2

--Total cases vs Population
--Shows what percentage of population got infected by covid
SELECT 
	Location, 
	date, 
	population, 
	total_cases, 
	(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 as InfectedPercentage
FROM PortfolioProject..CovDeaths$
--Where location like '%india%'
WHERE continent IS NOT NULL
Order by 1,2

--Countries with highest infected rate in terms of population
SELECT 
	Location, 
	Population, 
	MAX(total_cases) as HighestInfectionCount, 
    (CONVERT(float, MAX(total_cases)) / NULLIF(CONVERT(float, Population), 0))*100 as PercentPopulationInfected
FROM PortfolioProject..CovDeaths$
--WHERE location LIKE '%india%'
WHERE continent IS NOT NULL
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc

--Showing Countries with Highest Death Count as per Population
SELECT 
	Location, 
	MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovDeaths$
--WHERE location LIKE '%india%'
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount desc

--Let's break things down by continent
SELECT 
	continent, 
	MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovDeaths$
--WHERE location LIKE '%india%'
WHERE continent IS not NULL
GROUP BY continent
ORDER BY TotalDeathCount desc

--Global numbers
SELECT 
    --date, 
    SUM(new_cases) as total_cases, 
    SUM(CAST(new_deaths as int)) as total_deaths, 
    CASE 
        WHEN SUM(new_cases) = 0 THEN 0 -- Handle division by zero
        ELSE SUM(CAST(new_deaths as int))/ NULLIF(SUM(new_cases), 0) * 100
    END as DeathPercentage
FROM PortfolioProject..CovDeaths$
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2;

--Looking at Total Population vs Vaccinations
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(ISNULL(CAST(vac.new_vaccinations as bigint), 0)) 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovDeaths$ dea
JOIN PortfolioProject..CovVaccine$ vac
    ON dea.date = vac.date
    AND dea.location = vac.location
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;

--Use CTE
WITH popvsvac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(ISNULL(CAST(vac.new_vaccinations as bigint), 0)) 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovDeaths$ dea
JOIN PortfolioProject..CovVaccine$ vac
    ON dea.date = vac.date
    AND dea.location = vac.location
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)

SELECT *, (RollingPeopleVaccinated/population)*100 as VaccinatedPercentage
FROM popvsvac

--TEMP Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population float,
New_Vaccinations nvarchar(255),
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(ISNULL(CAST(vac.new_vaccinations as bigint), 0)) 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovDeaths$ dea
JOIN PortfolioProject..CovVaccine$ vac
    ON dea.date = vac.date
    AND dea.location = vac.location
--WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/population)*100 as VaccinatedPercentage
FROM #PercentPopulationVaccinated

--Creating a view to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(ISNULL(CAST(vac.new_vaccinations as bigint), 0)) 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovDeaths$ dea
JOIN PortfolioProject..CovVaccine$ vac
    ON dea.date = vac.date
    AND dea.location = vac.location
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *
FROM PercentPopulationVaccinated