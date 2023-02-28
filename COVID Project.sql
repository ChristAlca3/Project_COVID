SELECT *
FROM CovidDeaths
WHERE continent is not null
order by 3,4

--SELECT *
--FROM CovidVaccinations
--order by 3,4

-- select dat that we are going to be using

SELECT Location, date, total_cases, new_cases total_deaths, population
WHERE continent is not null
FROM CovidDeaths
order by 1,2

-- Looking at total cases vs total deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE location like '%states%'
and continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM CovidDeaths
--WHERE location like '%states%'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population
order by PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count per Population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location
order by TotalDeathCount DESC


-- LET´S BREAK THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
order by TotalDeathCount DESC

-- GLOBLA NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
--GROUP BY date
order by 1,2

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


-- USE CTE

WITH PopvsVac (continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3


SELECT *
FROM PercentPopulationVaccinated