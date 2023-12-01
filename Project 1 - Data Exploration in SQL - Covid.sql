--Covid Deaths Table Queries:

SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--Select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract Covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
and continent is not null
ORDER BY 1,2

-- Looking at the Total cases vs the Population
-- Shows what percentage of population got Covid

SELECT location, date,population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
and continent is not null
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population 

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
Group by location, population
ORDER BY PercentPopulationInfected desc

-- Showing the Countries with the Higest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
Group by location
ORDER BY TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing Continents with Higest Death Count per Population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
Group by continent
ORDER BY TotalDeathCount desc


-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%states%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- Total Cases and Death Percentage in the World

SELECT SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%states%'
WHERE continent is not null
-- GROUP BY date
ORDER BY 1,2


-- Covid Vaccinations Table Queries:

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
 On dea.location = vac.location
 and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3

-- Use CTE (To enable the column RollingPeopleVaccinated)

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
 On dea.location = vac.location
 and dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- Use TEMP TABLE (To enable the column RollingPeopleVaccinated)


DROP TABLE if exists #PercentPopulationVaccinated 
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric,
)

INSERT into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
 On dea.location = vac.location
 and dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Creating View to store data for later Visualizations

CREATE View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
 On dea.location = vac.location
 and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3

SELECT *
FROM PercentPopulationVaccinated
