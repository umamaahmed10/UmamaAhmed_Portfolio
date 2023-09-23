
/*
Data Exploration of Covid'19  

Used Skills: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


Select * 
From CovidSQLProject..CovidDeaths
Order By 3, 4


-- Selecting data I will be using for this project
Select location, date, total_cases, new_cases, total_deaths, population
From CovidSQLProject.dbo.CovidDeaths
Order by 1, 2


-- Total Deaths VS Total Cases
-- INSIGHT 1: How many casses are there in this country and how many deaths do they have

Select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidSQLProject.dbo.CovidDeaths
Order by 1, 2


-- INSIGHT 2: How many casses are there in Canada and how many deaths do they have
-- shows likelihood of dying if you contract with Covid in your country (My country is Canada)

Select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidSQLProject.dbo.CovidDeaths
Where location like '%anad%'
Order by 1, 2


-- Total cases VS Population
-- INSIGHT 3: What percentage of population got Covid

Select location, date, population, (total_cases/population)*100 as PercentPopulation
From CovidSQLProject.dbo.CovidDeaths
Where location like '%anad%'
Order By 1,2


-- INSIGHT 4: Countries with highest infection rate compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From CovidSQLProject.dbo.CovidDeaths
Group By location, population
Order By PercentPopulationInfected desc


-- INSIGHT 5: Countries with the highest death count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidSQLProject.dbo.CovidDeaths
Where continent is not NULL
Group By location
Order By TotalDeathCount desc


-- Breaking things by Continents
-- INSIGHT 6: Continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidSQLProject.dbo.CovidDeaths
Where continent is not NULL
Group By continent
Order By TotalDeathCount desc


-- INSIGHT 7: Global Numbers
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From CovidSQLProject..CovidDeaths
Where Continent is not Null
Group By date
Order by 1,2


-- INSIGHT 8: Death percentage across the world
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From CovidSQLProject..CovidDeaths
Where Continent is not Null
Order by 1,2


-- Total Population Vs Total Vaccinations
-- INSIGHT 9: Total amount of people in the world that has been vaccinated

-- Using CTE

With PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as (
Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CONVERT(int, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) as RollingPeopleVaccinated
From CovidSQLProject..CovidDeaths d
JOIN CovidSQLProject..CovidVaccinations v
	ON d.location = v.location
	AND d.date = v.date
Where d.continent is NOT NULL
)
Select *, (RollingPeopleVaccinated/Population)*100 
From PopVsVac

-- Using Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated 
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric 
)

INSERT INTO #PercentPopulationVaccinated
Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CONVERT(int, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) as RollingPeopleVaccinated
From CovidSQLProject..CovidDeaths d
JOIN CovidSQLProject..CovidVaccinations v
	ON d.location = v.location
	AND d.date = v.date

Select *, (RollingPeopleVaccinated/Population)*100 
From #PercentPopulationVaccinated


-- Creating View for later Visualizations

Create View PercentPopulationVaccinated as
Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CONVERT(int, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) as RollingPeopleVaccinated
From CovidSQLProject..CovidDeaths d
JOIN CovidSQLProject..CovidVaccinations v
	ON d.location = v.location
	AND d.date = v.date
Where d.continent is NOT NULL

